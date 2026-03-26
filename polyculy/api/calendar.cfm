<cfscript>
    setting showDebugOutput=false;
    cfheader(name="Content-Type", value="application/json");

    calSvc = new model.CalendarService();
    userSvc = new model.UserService();

    action = url.action ?: "getData";
    response = { "success": true };

    try {
        switch (action) {
            case "getData":
                calData = calSvc.getCalendarData(
                    session.userId,
                    url.view_type ?: "month",
                    url.start_date,
                    url.end_date,
                    url.mode ?: "mine",
                    url.enabled_user_ids ?: ""
                );
                response["data"] = calData;
                break;

            case "getMembers":
                members = calSvc.getPolyculeMembers(session.userId);
                response["data"] = members;
                break;

            case "setup":
                userSvc.setCalendarCreated(session.userId);
                session.calendarCreated = true;
                response["message"] = "Calendar created";
                response["redirect"] = "/views/calendar/month.cfm";
                break;

            default:
                response = { "success": false, "message": "Unknown action" };
        }
    } catch (any e) {
        response = { "success": false, "message": e.message };
    }

    writeOutput(serializeJSON(response));
</cfscript>
