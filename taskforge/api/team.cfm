<cfscript>
    setting showDebugOutput=false;
    cfheader(name="Content-Type", value="application/json");

    svc = new model.TeamMemberService();
    actSvc = new model.ActivityService();

    action = url.action ?: "list";
    response = { "success": true };

    try {
        switch (action) {
            case "list":
                q = svc.getAll();
                data = [];
                for (row in q) { arrayAppend(data, row); }
                response["data"] = data;
                break;

            case "active":
                q = svc.getActive();
                data = [];
                for (row in q) { arrayAppend(data, row); }
                response["data"] = data;
                break;

            case "get":
                q = svc.getById(url.id);
                if (q.recordCount) {
                    row = {};
                    for (col in listToArray(q.columnList)) { row[lCase(col)] = q[col][1]; }
                    response["data"] = row;
                } else {
                    response = { "success": false, "message": "Member not found" };
                }
                break;

            case "save":
                data = {
                    first_name: form.first_name,
                    last_name: form.last_name,
                    email: form.email,
                    role: form.role ?: "Developer",
                    avatar_color: form.avatar_color ?: "##4F46E5",
                    is_active: form.is_active ?: true
                };
                if (structKeyExists(form, "member_id") && len(form.member_id)) {
                    svc.update(form.member_id, data);
                    response["message"] = "Member updated";
                    response["id"] = form.member_id;
                } else {
                    newId = svc.create(data);
                    response["message"] = "Member created";
                    response["id"] = newId;
                }
                break;

            case "delete":
                svc.delete(form.member_id);
                response["message"] = "Member deleted";
                break;

            default:
                response = { "success": false, "message": "Unknown action: #action#" };
        }
    } catch (any e) {
        response = { "success": false, "message": e.message };
    }

    writeOutput(serializeJSON(response));
</cfscript>
