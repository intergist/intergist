<cfscript>
    setting showDebugOutput=false;
    cfheader(name="Content-Type", value="application/json");

    connSvc = new model.ConnectionService();
    auditSvc = new model.AuditService();
    notifSvc = new model.NotificationService();

    action = url.action ?: "list";
    response = { "success": true };

    try {
        switch (action) {
            case "list":
                q = connSvc.getConnectionsForUser(session.userId);
                data = [];
                for (row in q) { arrayAppend(data, row); }
                response["data"] = data;
                break;

            case "connected":
                q = connSvc.getConnectedUsers(session.userId);
                data = [];
                for (row in q) { arrayAppend(data, row); }
                response["data"] = data;
                break;

            case "pending":
                q = connSvc.getPendingForUser(session.userId);
                data = [];
                for (row in q) { arrayAppend(data, row); }
                response["data"] = data;
                break;

            case "invite":
                result = connSvc.invite(session.userId, form.email, form.display_name ?: "");
                if (result.success) {
                    auditSvc.log(session.userId, "connection_invite", "connection", result.connectionId, "Invited #form.email# to connect");
                    response["data"] = result;
                    response["message"] = "Invitation sent";
                } else {
                    response = { "success": false, "message": result.message };
                }
                break;

            case "accept":
                connSvc.acceptConnection(form.connection_id, session.userId);
                conn = connSvc.getById(form.connection_id);
                auditSvc.log(session.userId, "connection_accept", "connection", form.connection_id, "Accepted connection");
                notifSvc.create(conn.user_id_1, "connection_accepted", "Connection Accepted", "#session.displayName# accepted your connection request.", "connection", form.connection_id);
                response["message"] = "Connection accepted";
                break;

            case "revoke":
                connSvc.revokeConnection(form.connection_id, session.userId);
                auditSvc.log(session.userId, "connection_revoke", "connection", form.connection_id, "Connection revoked");
                response["message"] = "Connection revoked";
                break;

            case "updatePreferences":
                connSvc.updateDisplayPreferences(session.userId, form.target_user_id, form.nickname ?: "", form.calendar_color ?: "");
                response["message"] = "Preferences updated";
                break;

            case "revokeImpact":
                conn = connSvc.getById(url.connection_id);
                otherUserId = (conn.user_id_1 == session.userId) ? conn.user_id_2 : conn.user_id_1;
                revSvc = new model.RevocationService();
                impacted = revSvc.getImpactedEvents(session.userId, otherUserId);
                data = [];
                for (row in impacted) { arrayAppend(data, row); }
                response["data"] = data;
                break;

            default:
                response = { "success": false, "message": "Unknown action" };
        }
    } catch (any e) {
        response = { "success": false, "message": e.message };
    }

    writeOutput(serializeJSON(response));
</cfscript>
