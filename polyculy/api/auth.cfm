<cfscript>
    setting showDebugOutput=false;
    cfheader(name="Content-Type", value="application/json");

    userSvc = new model.UserService();
    licSvc = new model.LicenceService();
    auditSvc = new model.AuditService();

    action = url.action ?: "login";
    response = { "success": true };

    try {
        switch (action) {
            case "login":
                q = userSvc.authenticate(form.email, form.password);
                if (q.recordCount) {
                    session.isLoggedIn = true;
                    session.userId = q.user_id;
                    session.displayName = q.display_name;
                    session.email = q.email;
                    session.timezone = q.timezone_id;
                    session.calendarCreated = q.calendar_created;
                    session.csrfToken = hash(createUUID() & now());
                    response["data"] = {
                        user_id: q.user_id,
                        display_name: q.display_name,
                        email: q.email,
                        calendar_created: q.calendar_created,
                        csrf_token: session.csrfToken
                    };
                    response["message"] = "Login successful";
                    response["redirect"] = q.calendar_created ? "/views/calendar/month.cfm" : "/views/calendar/setup.cfm";
                } else {
                    response = { "success": false, "message": "Invalid email or password" };
                }
                break;

            case "signup":
                // Validate licence code
                licQ = licSvc.validate(form.licence_code);
                if (!licQ.recordCount) {
                    response = { "success": false, "message": "Invalid or already redeemed licence code" };
                    break;
                }

                // Check if email already exists
                existingUser = userSvc.getByEmail(form.email);
                if (existingUser.recordCount) {
                    response = { "success": false, "message": "An account with this email already exists" };
                    break;
                }

                // Create user
                newUserId = userSvc.create({
                    email: form.email,
                    password: form.password,
                    display_name: form.display_name,
                    timezone_id: form.timezone_id ?: "America/New_York"
                });

                // Redeem licence
                licSvc.redeem(form.licence_code, newUserId);

                // Auto-login
                session.isLoggedIn = true;
                session.userId = newUserId;
                session.displayName = form.display_name;
                session.email = form.email;
                session.timezone = form.timezone_id ?: "America/New_York";
                session.calendarCreated = false;
                session.csrfToken = hash(createUUID() & now());

                auditSvc.log(newUserId, "user_signup", "user", newUserId, "New user signed up: #form.display_name#");

                // Activate any pending connections for this email
                queryExecute(
                    "UPDATE connections SET user_id_2 = :uid, status = 'awaiting_confirmation', updated_at = CURRENT_TIMESTAMP
                     WHERE invited_email = :email AND status IN ('awaiting_signup','licence_gifted_awaiting_signup')",
                    {
                        uid: { value: newUserId, cfsqltype: "cf_sql_integer" },
                        email: { value: form.email, cfsqltype: "cf_sql_varchar" }
                    },
                    { datasource: "polyculy" }
                );

                response["data"] = { user_id: newUserId, csrf_token: session.csrfToken };
                response["message"] = "Account created successfully";
                response["redirect"] = "/views/calendar/setup.cfm";
                break;

            case "logout":
                structClear(session);
                session.isLoggedIn = false;
                response["message"] = "Logged out";
                response["redirect"] = "/index.cfm";
                break;

            case "getCsrfToken":
                response["data"] = { csrf_token: session.csrfToken ?: "" };
                break;

            default:
                response = { "success": false, "message": "Unknown action" };
        }
    } catch (any e) {
        response = { "success": false, "message": e.message };
    }

    writeOutput(serializeJSON(response));
</cfscript>
