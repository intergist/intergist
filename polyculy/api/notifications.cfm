<cfscript>
    setting showDebugOutput=false;
    cfheader(name="Content-Type", value="application/json");

    notifSvc = new model.NotificationService();

    action = url.action ?: "list";
    response = { "success": true };

    try {
        switch (action) {
            case "list":
                q = notifSvc.getForUser(session.userId, url.unread_only ?: false);
                data = [];
                for (row in q) { arrayAppend(data, row); }
                response["data"] = data;
                response["unread_count"] = notifSvc.getUnreadCount(session.userId);
                break;

            case "unreadCount":
                response["data"] = { count: notifSvc.getUnreadCount(session.userId) };
                break;

            case "markRead":
                notifSvc.markAsRead(form.notification_id, session.userId);
                response["message"] = "Marked as read";
                break;

            case "markAllRead":
                notifSvc.markAllAsRead(session.userId);
                response["message"] = "All marked as read";
                break;

            case "preferences":
                q = notifSvc.getPreferences(session.userId);
                data = [];
                for (row in q) { arrayAppend(data, row); }
                response["data"] = data;
                break;

            case "updatePreference":
                notifSvc.updatePreference(session.userId, form.notification_type, form.is_enabled, form.delivery_mode ?: "instant");
                response["message"] = "Preference updated";
                break;

            default:
                response = { "success": false, "message": "Unknown action" };
        }
    } catch (any e) {
        response = { "success": false, "message": e.message };
    }

    writeOutput(serializeJSON(response));
</cfscript>
