component {

    function getRecent(numeric limit = 15) {
        return queryExecute(
            "SELECT TOP(:lim) a.log_id, a.entity_type, a.entity_id, a.action, a.description, a.created_at,
                    CONCAT(m.first_name, ' ', m.last_name) AS actor_name,
                    m.avatar_color AS actor_color
             FROM activity_log a
             LEFT JOIN team_members m ON a.actor_id = m.member_id
             ORDER BY a.created_at DESC",
            { lim: { value: arguments.limit, cfsqltype: "cf_sql_integer" } }
        );
    }

    function log(required string entityType, required numeric entityId, required string action,
                 required string description, numeric actorId) {
        queryExecute(
            "INSERT INTO activity_log (entity_type, entity_id, action, description, actor_id)
             VALUES (:etype, :eid, :action, :desc, :actor)",
            {
                etype:  { value: arguments.entityType, cfsqltype: "cf_sql_varchar" },
                eid:    { value: arguments.entityId, cfsqltype: "cf_sql_integer" },
                action: { value: arguments.action, cfsqltype: "cf_sql_varchar" },
                desc:   { value: arguments.description, cfsqltype: "cf_sql_varchar" },
                actor:  { value: arguments.actorId ?: "", cfsqltype: "cf_sql_integer", null: !structKeyExists(arguments, "actorId") }
            }
        );
    }

}
