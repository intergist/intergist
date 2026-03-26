<cfscript>
    setting showDebugOutput=false;
    cfheader(name="Content-Type", value="application/json");

    svc = new model.ProjectService();
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

            case "get":
                q = svc.getById(url.id);
                if (q.recordCount) {
                    row = {};
                    for (col in listToArray(q.columnList)) { row[lCase(col)] = q[col][1]; }
                    response["data"] = row;
                } else {
                    response = { "success": false, "message": "Project not found" };
                }
                break;

            case "save":
                data = {
                    project_name: form.project_name,
                    description: form.description ?: "",
                    status: form.status ?: "Active",
                    priority: form.priority ?: "Medium",
                    owner_id: form.owner_id ?: "",
                    start_date: form.start_date ?: "",
                    due_date: form.due_date ?: ""
                };
                if (structKeyExists(form, "project_id") && len(form.project_id)) {
                    svc.update(form.project_id, data);
                    actSvc.log("project", form.project_id, "updated", 'Project "#form.project_name#" updated');
                    response["message"] = "Project updated";
                    response["id"] = form.project_id;
                } else {
                    newId = svc.create(data);
                    actSvc.log("project", newId, "created", 'Project "#form.project_name#" created');
                    response["message"] = "Project created";
                    response["id"] = newId;
                }
                break;

            case "delete":
                projQ = svc.getById(form.project_id);
                svc.delete(form.project_id);
                if (projQ.recordCount) {
                    actSvc.log("project", form.project_id, "deleted", 'Project "#projQ.project_name#" deleted');
                }
                response["message"] = "Project deleted";
                break;

            case "stats":
                q = svc.getStats();
                row = {};
                for (col in listToArray(q.columnList)) { row[lCase(col)] = q[col][1]; }
                response["data"] = row;
                break;

            default:
                response = { "success": false, "message": "Unknown action: #action#" };
        }
    } catch (any e) {
        response = { "success": false, "message": e.message };
    }

    writeOutput(serializeJSON(response));
</cfscript>
