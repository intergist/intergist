component {

    function log(required numeric actorUserId, required string actionType, required string entityType, required numeric entityId, string details = "") {
        queryExecute(
            "INSERT INTO audit_log (actor_user_id, action_type, entity_type, entity_id, details)
             VALUES (:actor, :action, :etype, :eid, :details)",
            {
                actor:   { value: arguments.actorUserId, cfsqltype: "cf_sql_integer" },
                action:  { value: arguments.actionType, cfsqltype: "cf_sql_varchar" },
                etype:   { value: arguments.entityType, cfsqltype: "cf_sql_varchar" },
                eid:     { value: arguments.entityId, cfsqltype: "cf_sql_integer" },
                details: { value: arguments.details, cfsqltype: "cf_sql_varchar" }
            },
            { datasource: "polyculy" }
        );
    }

    function getByEntity(required string entityType, required numeric entityId) {
        return queryExecute(
            "SELECT al.audit_id, al.action_type, al.entity_type, al.entity_id, al.details, al.created_at,
                    u.display_name AS actor_name
             FROM audit_log al
             JOIN users u ON u.user_id = al.actor_user_id
             WHERE al.entity_type = :etype AND al.entity_id = :eid
             ORDER BY al.created_at DESC",
            {
                etype: { value: arguments.entityType, cfsqltype: "cf_sql_varchar" },
                eid:   { value: arguments.entityId, cfsqltype: "cf_sql_integer" }
            },
            { datasource: "polyculy" }
        );
    }

    function getRecent(numeric limit = 50) {
        return queryExecute(
            "SELECT TOP :lim al.audit_id, al.action_type, al.entity_type, al.entity_id, al.details, al.created_at,
                    u.display_name AS actor_name
             FROM audit_log al
             JOIN users u ON u.user_id = al.actor_user_id
             ORDER BY al.created_at DESC",
            { lim: { value: arguments.limit, cfsqltype: "cf_sql_integer" } },
            { datasource: "polyculy" }
        );
    }

}
