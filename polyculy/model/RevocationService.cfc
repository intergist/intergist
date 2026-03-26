component {

    function getImpactedEvents(required numeric userId1, required numeric userId2) {
        return queryExecute(
            "SELECT se.shared_event_id, se.title, se.start_time, se.end_time, se.organizer_user_id,
                    se.global_state, u.display_name AS organizer_name,
                    (SELECT COUNT(*) FROM shared_event_participants WHERE shared_event_id = se.shared_event_id AND is_removed = FALSE) AS participant_count
             FROM shared_events se
             JOIN users u ON u.user_id = se.organizer_user_id
             WHERE se.global_state != 'cancelled'
               AND se.shared_event_id IN (
                   SELECT shared_event_id FROM shared_event_participants WHERE user_id = :uid1 AND is_removed = FALSE
               )
               AND se.shared_event_id IN (
                   SELECT shared_event_id FROM shared_event_participants WHERE user_id = :uid2 AND is_removed = FALSE
               )
             ORDER BY se.start_time ASC",
            {
                uid1: { value: arguments.userId1, cfsqltype: "cf_sql_integer" },
                uid2: { value: arguments.userId2, cfsqltype: "cf_sql_integer" }
            },
            { datasource: "polyculy" }
        );
    }

    function processRevocation(required numeric connectionId, required numeric revokerUserId, required array eventDecisions) {
        var connSvc = new model.ConnectionService();
        var sharedSvc = new model.SharedEventService();
        var auditSvc = new model.AuditService();
        var notifSvc = new model.NotificationService();

        var conn = connSvc.getById(arguments.connectionId);
        var otherUserId = (conn.user_id_1 == arguments.revokerUserId) ? conn.user_id_2 : conn.user_id_1;

        // Process each event decision
        for (var decision in arguments.eventDecisions) {
            var eventId = decision.event_id;
            var action = decision.action; // "cancel", "remove_self", "remove_other", "keep"

            switch (action) {
                case "cancel":
                    sharedSvc.cancelEvent(eventId, "Connection revoked");
                    auditSvc.log(arguments.revokerUserId, "event_cancelled_revocation", "shared_event", eventId, "Event cancelled due to connection revocation");
                    break;

                case "remove_self":
                    sharedSvc.removeParticipant(eventId, arguments.revokerUserId);
                    auditSvc.log(arguments.revokerUserId, "participant_removed_revocation", "shared_event", eventId, "Self-removed from event due to revocation");
                    break;

                case "remove_other":
                    sharedSvc.removeParticipant(eventId, otherUserId);
                    auditSvc.log(arguments.revokerUserId, "participant_removed_revocation", "shared_event", eventId, "Removed other party from event due to revocation");
                    break;

                case "keep":
                    // No action needed
                    break;
            }
        }

        // Revoke the connection
        connSvc.revokeConnection(arguments.connectionId, arguments.revokerUserId);
        auditSvc.log(arguments.revokerUserId, "connection_revoke", "connection", arguments.connectionId, "Connection revoked");

        // Notify the other user
        notifSvc.create(otherUserId, "connection_revoked", "Connection Revoked", "A connection has been revoked.", "connection", arguments.connectionId);
    }

}
