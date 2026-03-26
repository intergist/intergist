<cfscript>
    setting showDebugOutput=false;
    cfheader(name="Content-Type", value="application/json");

    svc = new model.TaskService();
    actSvc = new model.ActivityService();

    action = url.action ?: "list";
    response = { "success": true };

    try {
        switch (action) {
            case "list":
                q = svc.getAll(url.project_id ?: "", url.status ?: "", url.assigned_to ?: "", url.priority ?: "");
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
                    response = { "success": false, "message": "Task not found" };
                }
                break;

            case "save":
                data = {
                    project_id: form.project_id,
                    title: form.title,
                    description: form.description ?: "",
                    status: form.status ?: "To Do",
                    priority: form.priority ?: "Medium",
                    assigned_to: form.assigned_to ?: "",
                    due_date: form.due_date ?: "",
                    estimated_hours: form.estimated_hours ?: "",
                    actual_hours: form.actual_hours ?: "",
                    tags: form.tags ?: ""
                };
                if (structKeyExists(form, "task_id") && len(form.task_id)) {
                    svc.update(form.task_id, data);
                    actSvc.log("task", form.task_id, "updated", 'Task "#form.title#" updated');
                    response["message"] = "Task updated";
                    response["id"] = form.task_id;
                } else {
                    newId = svc.create(data);
                    actSvc.log("task", newId, "created", 'Task "#form.title#" created');
                    response["message"] = "Task created";
                    response["id"] = newId;
                }
                break;

            case "updateStatus":
                svc.updateStatus(form.task_id, form.status);
                actSvc.log("task", form.task_id, "status_change", 'Task status changed to #form.status#');
                response["message"] = "Status updated";
                break;

            case "delete":
                taskQ = svc.getById(form.task_id);
                svc.delete(form.task_id);
                if (taskQ.recordCount) {
                    actSvc.log("task", form.task_id, "deleted", 'Task "#taskQ.title#" deleted');
                }
                response["message"] = "Task deleted";
                break;

            case "comments":
                q = svc.getComments(url.task_id);
                data = [];
                for (row in q) { arrayAppend(data, row); }
                response["data"] = data;
                break;

            case "addComment":
                svc.addComment(form.task_id, form.author_id, form.comment_text);
                response["message"] = "Comment added";
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
