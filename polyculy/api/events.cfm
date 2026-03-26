<cfscript>
    setting showDebugOutput=false;
    cfheader(name="Content-Type", value="application/json");

    eventSvc = new model.EventService();
    auditSvc = new model.AuditService();

    action = url.action ?: "list";
    response = { "success": true };

    try {
        switch (action) {
            case "list":
                q = eventSvc.getPersonalEventsForUser(session.userId, url.start_date ?: "", url.end_date ?: "");
                data = [];
                for (row in q) { arrayAppend(data, row); }
                response["data"] = data;
                break;

            case "get":
                q = eventSvc.getById(url.id);
                if (q.recordCount) {
                    row = {};
                    for (col in listToArray(q.columnList)) { row[lCase(col)] = q[col][1]; }
                    // Get visibility data
                    vis = eventSvc.getVisibilityForEvent(url.id);
                    visData = [];
                    for (v in vis) { arrayAppend(visData, v); }
                    row["visibility"] = visData;
                    response["data"] = row;
                } else {
                    response = { "success": false, "message": "Event not found" };
                }
                break;

            case "save":
                data = {
                    owner_user_id: session.userId,
                    title: form.title,
                    start_time: form.start_time,
                    end_time: form.end_time,
                    all_day: form.all_day ?: false,
                    timezone_id: form.timezone_id ?: session.timezone ?: "America/New_York",
                    event_details: form.event_details ?: "",
                    address: form.address ?: "",
                    reminder_minutes: form.reminder_minutes ?: "",
                    visibility_tier: form.visibility_tier ?: "invisible"
                };

                if (structKeyExists(form, "event_id") && len(form.event_id)) {
                    eventSvc.update(form.event_id, data);
                    auditSvc.log(session.userId, "event_update", "personal_event", form.event_id, "Updated personal event: #form.title#");
                    response["message"] = "Event updated";
                    response["id"] = form.event_id;
                } else {
                    newId = eventSvc.create(data);
                    auditSvc.log(session.userId, "event_create", "personal_event", newId, "Created personal event: #form.title#");
                    response["message"] = "Event created";
                    response["id"] = newId;
                }
                break;

            case "setVisibility":
                visData = deserializeJSON(form.visibility_data);
                eventSvc.setVisibility(form.event_id, visData);
                auditSvc.log(session.userId, "event_visibility_update", "personal_event", form.event_id, "Updated event visibility");
                response["message"] = "Visibility updated";
                break;

            case "cancel":
                eventSvc.cancel(form.event_id);
                auditSvc.log(session.userId, "event_cancel", "personal_event", form.event_id, "Cancelled personal event");
                response["message"] = "Event cancelled";
                break;

            default:
                response = { "success": false, "message": "Unknown action" };
        }
    } catch (any e) {
        response = { "success": false, "message": e.message };
    }

    writeOutput(serializeJSON(response));
</cfscript>
