component {

    function getConnectionsForUser(required numeric userId) {
        return queryExecute(
            "SELECT c.connection_id, c.user_id_1, c.user_id_2, c.status, c.invited_email,
                    c.invited_display_name, c.initiated_by, c.created_at,
                    CASE WHEN c.user_id_1 = :uid THEN c.user_id_2 ELSE c.user_id_1 END AS other_user_id,
                    u.display_name AS other_display_name, u.email AS other_email,
                    u.avatar_url AS other_avatar_url,
                    dp.nickname, dp.calendar_color
             FROM connections c
             LEFT JOIN users u ON u.user_id = CASE WHEN c.user_id_1 = :uid2 THEN c.user_id_2 ELSE c.user_id_1 END
             LEFT JOIN connection_display_preferences dp ON dp.user_id = :uid3 AND dp.target_user_id = u.user_id
             WHERE (c.user_id_1 = :uid4 OR c.user_id_2 = :uid5)
             ORDER BY
                CASE c.status
                    WHEN 'connected' THEN 1
                    WHEN 'awaiting_confirmation' THEN 2
                    WHEN 'awaiting_signup' THEN 3
                    WHEN 'licence_gifted_awaiting_signup' THEN 4
                    WHEN 'revoked' THEN 5
                END, u.display_name",
            {
                uid:  { value: arguments.userId, cfsqltype: "cf_sql_integer" },
                uid2: { value: arguments.userId, cfsqltype: "cf_sql_integer" },
                uid3: { value: arguments.userId, cfsqltype: "cf_sql_integer" },
                uid4: { value: arguments.userId, cfsqltype: "cf_sql_integer" },
                uid5: { value: arguments.userId, cfsqltype: "cf_sql_integer" }
            },
            { datasource: "polyculy" }
        );
    }

    function getConnectedUsers(required numeric userId) {
        return queryExecute(
            "SELECT u.user_id, u.display_name, u.email, u.avatar_url,
                    dp.nickname, dp.calendar_color
             FROM connections c
             JOIN users u ON u.user_id = CASE WHEN c.user_id_1 = :uid THEN c.user_id_2 ELSE c.user_id_1 END
             LEFT JOIN connection_display_preferences dp ON dp.user_id = :uid2 AND dp.target_user_id = u.user_id
             WHERE (c.user_id_1 = :uid3 OR c.user_id_2 = :uid4) AND c.status = 'connected'
             ORDER BY u.display_name",
            {
                uid:  { value: arguments.userId, cfsqltype: "cf_sql_integer" },
                uid2: { value: arguments.userId, cfsqltype: "cf_sql_integer" },
                uid3: { value: arguments.userId, cfsqltype: "cf_sql_integer" },
                uid4: { value: arguments.userId, cfsqltype: "cf_sql_integer" }
            },
            { datasource: "polyculy" }
        );
    }

    function invite(required numeric fromUserId, required string email, string displayName = "") {
        // Check if user exists
        var existingUser = queryExecute(
            "SELECT user_id FROM users WHERE email = :email",
            { email: { value: arguments.email, cfsqltype: "cf_sql_varchar" } },
            { datasource: "polyculy" }
        );

        // Check if connection already exists
        if (existingUser.recordCount) {
            var existingConn = queryExecute(
                "SELECT connection_id FROM connections
                 WHERE ((user_id_1 = :uid1 AND user_id_2 = :uid2) OR (user_id_1 = :uid2b AND user_id_2 = :uid1b))
                   AND status != 'revoked'",
                {
                    uid1:  { value: arguments.fromUserId, cfsqltype: "cf_sql_integer" },
                    uid2:  { value: existingUser.user_id, cfsqltype: "cf_sql_integer" },
                    uid2b: { value: existingUser.user_id, cfsqltype: "cf_sql_integer" },
                    uid1b: { value: arguments.fromUserId, cfsqltype: "cf_sql_integer" }
                },
                { datasource: "polyculy" }
            );
            if (existingConn.recordCount) {
                return { success: false, message: "Connection already exists" };
            }

            queryExecute(
                "INSERT INTO connections (user_id_1, user_id_2, status, initiated_by)
                 VALUES (:uid1, :uid2, 'awaiting_confirmation', :initiated)",
                {
                    uid1:      { value: arguments.fromUserId, cfsqltype: "cf_sql_integer" },
                    uid2:      { value: existingUser.user_id, cfsqltype: "cf_sql_integer" },
                    initiated: { value: arguments.fromUserId, cfsqltype: "cf_sql_integer" }
                },
                { datasource: "polyculy", result: "qResult" }
            );
            return { success: true, status: "awaiting_confirmation", connectionId: listFirst(qResult.generatedKey) };
        } else {
            queryExecute(
                "INSERT INTO connections (user_id_1, user_id_2, status, invited_email, invited_display_name, initiated_by)
                 VALUES (:uid1, NULL, 'awaiting_signup', :email, :dname, :initiated)",
                {
                    uid1:      { value: arguments.fromUserId, cfsqltype: "cf_sql_integer" },
                    email:     { value: arguments.email, cfsqltype: "cf_sql_varchar" },
                    dname:     { value: arguments.displayName, cfsqltype: "cf_sql_varchar" },
                    initiated: { value: arguments.fromUserId, cfsqltype: "cf_sql_integer" }
                },
                { datasource: "polyculy", result: "qResult" }
            );
            return { success: true, status: "awaiting_signup", connectionId: listFirst(qResult.generatedKey) };
        }
    }

    function acceptConnection(required numeric connectionId, required numeric userId) {
        queryExecute(
            "UPDATE connections SET status = 'connected', updated_at = CURRENT_TIMESTAMP
             WHERE connection_id = :cid AND (user_id_2 = :uid) AND status = 'awaiting_confirmation'",
            {
                cid: { value: arguments.connectionId, cfsqltype: "cf_sql_integer" },
                uid: { value: arguments.userId, cfsqltype: "cf_sql_integer" }
            },
            { datasource: "polyculy" }
        );
    }

    function revokeConnection(required numeric connectionId, required numeric userId) {
        queryExecute(
            "UPDATE connections SET status = 'revoked', updated_at = CURRENT_TIMESTAMP
             WHERE connection_id = :cid AND (user_id_1 = :uid OR user_id_2 = :uid2)",
            {
                cid:  { value: arguments.connectionId, cfsqltype: "cf_sql_integer" },
                uid:  { value: arguments.userId, cfsqltype: "cf_sql_integer" },
                uid2: { value: arguments.userId, cfsqltype: "cf_sql_integer" }
            },
            { datasource: "polyculy" }
        );
    }

    function getById(required numeric connectionId) {
        return queryExecute(
            "SELECT connection_id, user_id_1, user_id_2, status, invited_email, invited_display_name, initiated_by
             FROM connections WHERE connection_id = :cid",
            { cid: { value: arguments.connectionId, cfsqltype: "cf_sql_integer" } },
            { datasource: "polyculy" }
        );
    }

    function getPendingForUser(required numeric userId) {
        return queryExecute(
            "SELECT c.connection_id, c.user_id_1, c.initiated_by, c.created_at,
                    u.display_name AS from_display_name, u.email AS from_email
             FROM connections c
             JOIN users u ON u.user_id = c.user_id_1
             WHERE c.user_id_2 = :uid AND c.status = 'awaiting_confirmation'
             ORDER BY c.created_at DESC",
            { uid: { value: arguments.userId, cfsqltype: "cf_sql_integer" } },
            { datasource: "polyculy" }
        );
    }

    function updateDisplayPreferences(required numeric userId, required numeric targetUserId, string nickname = "", string calendarColor = "") {
        var existing = queryExecute(
            "SELECT pref_id FROM connection_display_preferences WHERE user_id = :uid AND target_user_id = :tid",
            {
                uid: { value: arguments.userId, cfsqltype: "cf_sql_integer" },
                tid: { value: arguments.targetUserId, cfsqltype: "cf_sql_integer" }
            },
            { datasource: "polyculy" }
        );

        if (existing.recordCount) {
            queryExecute(
                "UPDATE connection_display_preferences SET nickname = :nick, calendar_color = :color
                 WHERE user_id = :uid AND target_user_id = :tid",
                {
                    uid:   { value: arguments.userId, cfsqltype: "cf_sql_integer" },
                    tid:   { value: arguments.targetUserId, cfsqltype: "cf_sql_integer" },
                    nick:  { value: arguments.nickname, cfsqltype: "cf_sql_varchar", null: !len(arguments.nickname) },
                    color: { value: arguments.calendarColor, cfsqltype: "cf_sql_varchar" }
                },
                { datasource: "polyculy" }
            );
        } else {
            queryExecute(
                "INSERT INTO connection_display_preferences (user_id, target_user_id, nickname, calendar_color)
                 VALUES (:uid, :tid, :nick, :color)",
                {
                    uid:   { value: arguments.userId, cfsqltype: "cf_sql_integer" },
                    tid:   { value: arguments.targetUserId, cfsqltype: "cf_sql_integer" },
                    nick:  { value: arguments.nickname, cfsqltype: "cf_sql_varchar", null: !len(arguments.nickname) },
                    color: { value: arguments.calendarColor, cfsqltype: "cf_sql_varchar" }
                },
                { datasource: "polyculy" }
            );
        }
    }

}
