component {

    function getById(required numeric eventId) {
        return queryExecute(
            "SELECT se.*, u.display_name AS organizer_name
             FROM shared_events se
             JOIN users u ON u.user_id = se.organizer_user_id
             WHERE se.shared_event_id = :eid",
            { eid: { value: arguments.eventId, cfsqltype: "cf_sql_integer" } },
            { datasource: "polyculy" }
        );
    }

    function getForUser(required numeric userId, string startDate = "", string endDate = "") {
        var sql = "SELECT DISTINCT se.shared_event_id, se.title, se.start_time, se.end_time, se.all_day,
                          se.timezone_id, se.event_details, se.address, se.global_state,
                          se.organizer_user_id, u.display_name AS organizer_name,
                          sep.response_status, sep.attendance_type
                   FROM shared_events se
                   JOIN shared_event_participants sep ON sep.shared_event_id = se.shared_event_id
                   JOIN users u ON u.user_id = se.organizer_user_id
                   WHERE sep.user_id = :uid AND sep.is_removed = FALSE AND se.global_state != 'cancelled'";
        var params = { uid: { value: arguments.userId, cfsqltype: "cf_sql_integer" } };

        if (len(arguments.startDate)) {
            sql &= " AND se.end_time >= :sdate";
            params["sdate"] = { value: arguments.startDate, cfsqltype: "cf_sql_timestamp" };
        }
        if (len(arguments.endDate)) {
            sql &= " AND se.start_time <= :edate";
            params["edate"] = { value: arguments.endDate, cfsqltype: "cf_sql_timestamp" };
        }

        sql &= " ORDER BY se.start_time ASC";
        return queryExecute(sql, params, { datasource: "polyculy" });
    }

    function create(required struct data) {
        queryExecute(
            "INSERT INTO shared_events (organizer_user_id, title, start_time, end_time, all_day, timezone_id,
                    event_details, address, reminder_minutes, reminder_scope, participant_visibility, global_state)
             VALUES (:org, :title, :stime, :etime, :allday, :tz, :details, :addr, :reminder, :rscope, :pvis, 'tentative')",
            {
                org:      { value: data.organizer_user_id, cfsqltype: "cf_sql_integer" },
                title:    { value: data.title, cfsqltype: "cf_sql_varchar" },
                stime:    { value: data.start_time, cfsqltype: "cf_sql_timestamp" },
                etime:    { value: data.end_time, cfsqltype: "cf_sql_timestamp" },
                allday:   { value: data.all_day ?: false, cfsqltype: "cf_sql_bit" },
                tz:       { value: data.timezone_id ?: "America/New_York", cfsqltype: "cf_sql_varchar" },
                details:  { value: data.event_details ?: "", cfsqltype: "cf_sql_varchar" },
                addr:     { value: data.address ?: "", cfsqltype: "cf_sql_varchar" },
                reminder: { value: data.reminder_minutes ?: "", cfsqltype: "cf_sql_integer", null: !len(data.reminder_minutes ?: "") },
                rscope:   { value: data.reminder_scope ?: "me", cfsqltype: "cf_sql_varchar" },
                pvis:     { value: data.participant_visibility ?: "visible", cfsqltype: "cf_sql_varchar" }
            },
            { datasource: "polyculy", result: "qResult" }
        );

        var eventId = listFirst(qResult.generatedKey);

        // Add organizer as accepted participant
        addParticipant(eventId, data.organizer_user_id, "required", "accepted");

        return eventId;
    }

    function updateMinor(required numeric eventId, required struct data) {
        queryExecute(
            "UPDATE shared_events SET title = :title, event_details = :details,
                    participant_visibility = :pvis, updated_at = CURRENT_TIMESTAMP
             WHERE shared_event_id = :eid",
            {
                eid:     { value: arguments.eventId, cfsqltype: "cf_sql_integer" },
                title:   { value: data.title, cfsqltype: "cf_sql_varchar" },
                details: { value: data.event_details ?: "", cfsqltype: "cf_sql_varchar" },
                pvis:    { value: data.participant_visibility ?: "visible", cfsqltype: "cf_sql_varchar" }
            },
            { datasource: "polyculy" }
        );
    }

    function updateMaterial(required numeric eventId, required struct data) {
        queryExecute(
            "UPDATE shared_events SET title = :title, start_time = :stime, end_time = :etime,
                    all_day = :allday, timezone_id = :tz, event_details = :details, address = :addr,
                    updated_at = CURRENT_TIMESTAMP
             WHERE shared_event_id = :eid",
            {
                eid:    { value: arguments.eventId, cfsqltype: "cf_sql_integer" },
                title:  { value: data.title, cfsqltype: "cf_sql_varchar" },
                stime:  { value: data.start_time, cfsqltype: "cf_sql_timestamp" },
                etime:  { value: data.end_time, cfsqltype: "cf_sql_timestamp" },
                allday: { value: data.all_day ?: false, cfsqltype: "cf_sql_bit" },
                tz:     { value: data.timezone_id ?: "America/New_York", cfsqltype: "cf_sql_varchar" },
                details: { value: data.event_details ?: "", cfsqltype: "cf_sql_varchar" },
                addr:   { value: data.address ?: "", cfsqltype: "cf_sql_varchar" }
            },
            { datasource: "polyculy" }
        );

        // Reset non-organizer acceptances to pending
        var evt = getById(arguments.eventId);
        queryExecute(
            "UPDATE shared_event_participants SET response_status = 'pending', updated_at = CURRENT_TIMESTAMP
             WHERE shared_event_id = :eid AND user_id != :org",
            {
                eid: { value: arguments.eventId, cfsqltype: "cf_sql_integer" },
                org: { value: evt.organizer_user_id, cfsqltype: "cf_sql_integer" }
            },
            { datasource: "polyculy" }
        );

        // Check if event should revert to tentative
        updateGlobalState(arguments.eventId);
    }

    function cancelEvent(required numeric eventId, string reason = "") {
        queryExecute(
            "UPDATE shared_events SET global_state = 'cancelled', cancellation_reason = :reason,
                    updated_at = CURRENT_TIMESTAMP
             WHERE shared_event_id = :eid",
            {
                eid:    { value: arguments.eventId, cfsqltype: "cf_sql_integer" },
                reason: { value: arguments.reason, cfsqltype: "cf_sql_varchar" }
            },
            { datasource: "polyculy" }
        );
    }

    function addParticipant(required numeric eventId, required numeric userId, string attendanceType = "required", string responseStatus = "pending", boolean isOneHop = false, numeric linkPersonUserId = 0) {
        queryExecute(
            "INSERT INTO shared_event_participants (shared_event_id, user_id, attendance_type, response_status, is_one_hop, link_person_user_id)
             VALUES (:eid, :uid, :atype, :rstatus, :onehop, :linkperson)",
            {
                eid:        { value: arguments.eventId, cfsqltype: "cf_sql_integer" },
                uid:        { value: arguments.userId, cfsqltype: "cf_sql_integer" },
                atype:      { value: arguments.attendanceType, cfsqltype: "cf_sql_varchar" },
                rstatus:    { value: arguments.responseStatus, cfsqltype: "cf_sql_varchar" },
                onehop:     { value: arguments.isOneHop, cfsqltype: "cf_sql_bit" },
                linkperson: { value: arguments.linkPersonUserId, cfsqltype: "cf_sql_integer", null: arguments.linkPersonUserId == 0 }
            },
            { datasource: "polyculy" }
        );
    }

    function respondToInvitation(required numeric eventId, required numeric userId, required string response) {
        queryExecute(
            "UPDATE shared_event_participants SET response_status = :resp, updated_at = CURRENT_TIMESTAMP
             WHERE shared_event_id = :eid AND user_id = :uid AND is_removed = FALSE",
            {
                eid:  { value: arguments.eventId, cfsqltype: "cf_sql_integer" },
                uid:  { value: arguments.userId, cfsqltype: "cf_sql_integer" },
                resp: { value: arguments.response, cfsqltype: "cf_sql_varchar" }
            },
            { datasource: "polyculy" }
        );

        updateGlobalState(arguments.eventId);
    }

    function removeParticipant(required numeric eventId, required numeric userId) {
        queryExecute(
            "UPDATE shared_event_participants SET is_removed = TRUE, updated_at = CURRENT_TIMESTAMP
             WHERE shared_event_id = :eid AND user_id = :uid",
            {
                eid: { value: arguments.eventId, cfsqltype: "cf_sql_integer" },
                uid: { value: arguments.userId, cfsqltype: "cf_sql_integer" }
            },
            { datasource: "polyculy" }
        );

        updateGlobalState(arguments.eventId);
    }

    function getParticipants(required numeric eventId) {
        return queryExecute(
            "SELECT sep.participant_id, sep.user_id, sep.attendance_type, sep.response_status,
                    sep.is_one_hop, sep.link_person_user_id, sep.one_hop_consent_given, sep.one_hop_activated,
                    sep.is_removed,
                    u.display_name, u.email, u.avatar_url
             FROM shared_event_participants sep
             JOIN users u ON u.user_id = sep.user_id
             WHERE sep.shared_event_id = :eid
             ORDER BY sep.created_at ASC",
            { eid: { value: arguments.eventId, cfsqltype: "cf_sql_integer" } },
            { datasource: "polyculy" }
        );
    }

    function getActiveParticipantCount(required numeric eventId) {
        var q = queryExecute(
            "SELECT COUNT(*) AS cnt FROM shared_event_participants
             WHERE shared_event_id = :eid AND is_removed = FALSE",
            { eid: { value: arguments.eventId, cfsqltype: "cf_sql_integer" } },
            { datasource: "polyculy" }
        );
        return q.cnt;
    }

    function updateGlobalState(required numeric eventId) {
        var evt = getById(arguments.eventId);
        if (evt.global_state == "cancelled") return;

        var acceptedCount = queryExecute(
            "SELECT COUNT(*) AS cnt FROM shared_event_participants
             WHERE shared_event_id = :eid AND response_status = 'accepted' AND is_removed = FALSE
               AND user_id != :org",
            {
                eid: { value: arguments.eventId, cfsqltype: "cf_sql_integer" },
                org: { value: evt.organizer_user_id, cfsqltype: "cf_sql_integer" }
            },
            { datasource: "polyculy" }
        );

        var newState = (acceptedCount.cnt > 0) ? "active" : "tentative";
        queryExecute(
            "UPDATE shared_events SET global_state = :state, updated_at = CURRENT_TIMESTAMP
             WHERE shared_event_id = :eid",
            {
                eid:   { value: arguments.eventId, cfsqltype: "cf_sql_integer" },
                state: { value: newState, cfsqltype: "cf_sql_varchar" }
            },
            { datasource: "polyculy" }
        );
    }

    function checkConflicts(required numeric userId, required string startTime, required string endTime, numeric excludeEventId = 0) {
        var conflicts = [];

        // Check personal events
        var personalConflicts = queryExecute(
            "SELECT event_id, title, start_time, end_time, 'personal' AS event_type
             FROM personal_events
             WHERE owner_user_id = :uid AND is_cancelled = FALSE
               AND start_time < :etime AND end_time > :stime",
            {
                uid:   { value: arguments.userId, cfsqltype: "cf_sql_integer" },
                stime: { value: arguments.startTime, cfsqltype: "cf_sql_timestamp" },
                etime: { value: arguments.endTime, cfsqltype: "cf_sql_timestamp" }
            },
            { datasource: "polyculy" }
        );
        for (var row in personalConflicts) { arrayAppend(conflicts, row); }

        // Check shared events (accepted only)
        var sharedSql = "SELECT se.shared_event_id AS event_id, se.title, se.start_time, se.end_time, 'shared' AS event_type
             FROM shared_events se
             JOIN shared_event_participants sep ON sep.shared_event_id = se.shared_event_id
             WHERE sep.user_id = :uid AND sep.response_status = 'accepted' AND sep.is_removed = FALSE
               AND se.global_state != 'cancelled'
               AND se.start_time < :etime AND se.end_time > :stime";
        var params = {
            uid:   { value: arguments.userId, cfsqltype: "cf_sql_integer" },
            stime: { value: arguments.startTime, cfsqltype: "cf_sql_timestamp" },
            etime: { value: arguments.endTime, cfsqltype: "cf_sql_timestamp" }
        };

        if (arguments.excludeEventId > 0) {
            sharedSql &= " AND se.shared_event_id != :exid";
            params["exid"] = { value: arguments.excludeEventId, cfsqltype: "cf_sql_integer" };
        }

        var sharedConflicts = queryExecute(sharedSql, params, { datasource: "polyculy" });
        for (var row in sharedConflicts) { arrayAppend(conflicts, row); }

        return conflicts;
    }

    function transferOwnership(required numeric eventId, required numeric newOwnerId) {
        queryExecute(
            "UPDATE shared_events SET organizer_user_id = :newOwner,
                    ownership_transfer_active = FALSE, ownership_transfer_deadline = NULL,
                    updated_at = CURRENT_TIMESTAMP
             WHERE shared_event_id = :eid AND ownership_transfer_active = TRUE",
            {
                eid:      { value: arguments.eventId, cfsqltype: "cf_sql_integer" },
                newOwner: { value: arguments.newOwnerId, cfsqltype: "cf_sql_integer" }
            },
            { datasource: "polyculy" }
        );
    }

    function initiateOwnershipTransfer(required numeric eventId, required string deadline) {
        queryExecute(
            "UPDATE shared_events SET ownership_transfer_active = TRUE, ownership_transfer_deadline = :deadline,
                    updated_at = CURRENT_TIMESTAMP
             WHERE shared_event_id = :eid",
            {
                eid:      { value: arguments.eventId, cfsqltype: "cf_sql_integer" },
                deadline: { value: arguments.deadline, cfsqltype: "cf_sql_timestamp" }
            },
            { datasource: "polyculy" }
        );
    }

}
