<cfscript>
    setting showDebugOutput=false;
    cfheader(name="Content-Type", value="application/json");

    userSvc = new model.UserService();

    action = url.action ?: "get";
    response = { "success": true };

    try {
        switch (action) {
            case "get":
                q = userSvc.getById(session.userId);
                if (q.recordCount) {
                    response["data"] = {
                        display_name: q.display_name,
                        email: q.email,
                        timezone_id: q.timezone_id,
                        avatar_url: q.avatar_url
                    };
                }
                break;

            case "update":
                userSvc.updateProfile(session.userId, {
                    display_name: form.display_name ?: session.displayName,
                    timezone_id: form.timezone_id ?: "America/New_York"
                });
                session.displayName = form.display_name ?: session.displayName;
                session.timezone = form.timezone_id ?: "America/New_York";
                response["message"] = "Preferences updated";
                break;

            case "changePassword":
                // Verify current password
                q = userSvc.authenticate(session.email, form.current_password);
                if (q.recordCount) {
                    userSvc.changePassword(session.userId, form.new_password);
                    response["message"] = "Password changed";
                } else {
                    response = { "success": false, "message": "Current password is incorrect" };
                }
                break;

            default:
                response = { "success": false, "message": "Unknown action" };
        }
    } catch (any e) {
        response = { "success": false, "message": e.message };
    }

    writeOutput(serializeJSON(response));
</cfscript>
