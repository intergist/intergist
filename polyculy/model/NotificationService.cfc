component {

    function getForUser(required numeric userId, boolean unreadOnly = false) {
        var sql = "SELECT notification_id, notification_type, title, message,
                          related_entity_type, related_entity_id, is_read, created_at
                   FROM notifications WHERE user_id = :uid";
        var params = { uid: { value: arguments.userId, cfsqltype: "cf_sql_integer" } };

        if (arguments.unreadOnly) {
            sql &= " AND is_read = FALSE";
        }

        sql &= " ORDER BY created_at DESC";
        return queryExecute(sql, params, { datasource: "polyculy" });
    }

    function getUnreadCount(required numeric userId) {
        var q = queryExecute(
            "SELECT COUNT(*) AS cnt FROM notifications WHERE user_id = :uid AND is_read = FALSE",
            { uid: { value: arguments.userId, cfsqltype: "cf_sql_integer" } },
            { datasource: "polyculy" }
        );
        return q.cnt;
    }

    function markAsRead(required numeric notificationId, required numeric userId) {
        queryExecute(
            "UPDATE notifications SET is_read = TRUE WHERE notification_id = :nid AND user_id = :uid",
            {
                nid: { value: arguments.notificationId, cfsqltype: "cf_sql_integer" },
                uid: { value: arguments.userId, cfsqltype: "cf_sql_integer" }
            },
            { datasource: "polyculy" }
        );
    }

    function markAllAsRead(required numeric userId) {
        queryExecute(
            "UPDATE notifications SET is_read = TRUE WHERE user_id = :uid AND is_read = FALSE",
            { uid: { value: arguments.userId, cfsqltype: "cf_sql_integer" } },
            { datasource: "polyculy" }
        );
    }

    function create(required numeric userId, required string notificationType, required string title, required string message, string relatedEntityType = "", numeric relatedEntityId = 0) {
        queryExecute(
            "INSERT INTO notifications (user_id, notification_type, title, message, related_entity_type, related_entity_id)
             VALUES (:uid, :ntype, :title, :msg, :etype, :eid)",
            {
                uid:   { value: arguments.userId, cfsqltype: "cf_sql_integer" },
                ntype: { value: arguments.notificationType, cfsqltype: "cf_sql_varchar" },
                title: { value: arguments.title, cfsqltype: "cf_sql_varchar" },
                msg:   { value: arguments.message, cfsqltype: "cf_sql_varchar" },
                etype: { value: arguments.relatedEntityType, cfsqltype: "cf_sql_varchar", null: !len(arguments.relatedEntityType) },
                eid:   { value: arguments.relatedEntityId, cfsqltype: "cf_sql_integer", null: arguments.relatedEntityId == 0 }
            },
            { datasource: "polyculy" }
        );
    }

    function getPreferences(required numeric userId) {
        return queryExecute(
            "SELECT pref_id, notification_type, is_enabled, delivery_mode, quiet_hours_start, quiet_hours_end
             FROM notification_preferences WHERE user_id = :uid ORDER BY notification_type",
            { uid: { value: arguments.userId, cfsqltype: "cf_sql_integer" } },
            { datasource: "polyculy" }
        );
    }

    function updatePreference(required numeric userId, required string notificationType, required boolean isEnabled, string deliveryMode = "instant") {
        var existing = queryExecute(
            "SELECT pref_id FROM notification_preferences WHERE user_id = :uid AND notification_type = :ntype",
            {
                uid:   { value: arguments.userId, cfsqltype: "cf_sql_integer" },
                ntype: { value: arguments.notificationType, cfsqltype: "cf_sql_varchar" }
            },
            { datasource: "polyculy" }
        );

        if (existing.recordCount) {
            queryExecute(
                "UPDATE notification_preferences SET is_enabled = :enabled, delivery_mode = :dmode
                 WHERE user_id = :uid AND notification_type = :ntype",
                {
                    uid:     { value: arguments.userId, cfsqltype: "cf_sql_integer" },
                    ntype:   { value: arguments.notificationType, cfsqltype: "cf_sql_varchar" },
                    enabled: { value: arguments.isEnabled, cfsqltype: "cf_sql_bit" },
                    dmode:   { value: arguments.deliveryMode, cfsqltype: "cf_sql_varchar" }
                },
                { datasource: "polyculy" }
            );
        } else {
            queryExecute(
                "INSERT INTO notification_preferences (user_id, notification_type, is_enabled, delivery_mode)
                 VALUES (:uid, :ntype, :enabled, :dmode)",
                {
                    uid:     { value: arguments.userId, cfsqltype: "cf_sql_integer" },
                    ntype:   { value: arguments.notificationType, cfsqltype: "cf_sql_varchar" },
                    enabled: { value: arguments.isEnabled, cfsqltype: "cf_sql_bit" },
                    dmode:   { value: arguments.deliveryMode, cfsqltype: "cf_sql_varchar" }
                },
                { datasource: "polyculy" }
            );
        }
    }

}
