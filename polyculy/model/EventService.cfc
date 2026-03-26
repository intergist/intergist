component {

    function getPersonalEventsForUser(required numeric userId, string startDate = "", string endDate = "") {
        var sql = "SELECT e.event_id, e.title, e.start_time, e.end_time, e.all_day, e.timezone_id,
                          e.event_details, e.address, e.reminder_minutes, e.visibility_tier, e.is_cancelled
                   FROM personal_events e
                   WHERE e.owner_user_id = :uid AND e.is_cancelled = FALSE";
        var params = { uid: { value: arguments.userId, cfsqltype: "cf_sql_integer" } };

        if (len(arguments.startDate)) {
            sql &= " AND e.end_time >= :sdate";
            params["sdate"] = { value: arguments.startDate, cfsqltype: "cf_sql_timestamp" };
        }
        if (len(arguments.endDate)) {
            sql &= " AND e.start_time <= :edate";
            params["edate"] = { value: arguments.endDate, cfsqltype: "cf_sql_timestamp" };
        }

        sql &= " ORDER BY e.start_time ASC";
        return queryExecute(sql, params, { datasource: "polyculy" });
    }

    function getVisibleEventsForViewer(required numeric ownerUserId, required numeric viewerUserId, string startDate = "", string endDate = "") {
        var sql = "SELECT e.event_id, e.title, e.start_time, e.end_time, e.all_day, e.timezone_id,
                          e.event_details, e.address, e.visibility_tier,
                          pev.visibility_type
                   FROM personal_events e
                   JOIN personal_event_visibility pev ON pev.event_id = e.event_id AND pev.target_user_id = :vid
                   WHERE e.owner_user_id = :oid AND e.is_cancelled = FALSE";
        var params = {
            vid: { value: arguments.viewerUserId, cfsqltype: "cf_sql_integer" },
            oid: { value: arguments.ownerUserId, cfsqltype: "cf_sql_integer" }
        };

        if (len(arguments.startDate)) {
            sql &= " AND e.end_time >= :sdate";
            params["sdate"] = { value: arguments.startDate, cfsqltype: "cf_sql_timestamp" };
        }
        if (len(arguments.endDate)) {
            sql &= " AND e.start_time <= :edate";
            params["edate"] = { value: arguments.endDate, cfsqltype: "cf_sql_timestamp" };
        }

        sql &= " ORDER BY e.start_time ASC";
        return queryExecute(sql, params, { datasource: "polyculy" });
    }

    function getById(required numeric eventId) {
        return queryExecute(
            "SELECT e.*, u.display_name AS owner_name
             FROM personal_events e
             JOIN users u ON u.user_id = e.owner_user_id
             WHERE e.event_id = :eid",
            { eid: { value: arguments.eventId, cfsqltype: "cf_sql_integer" } },
            { datasource: "polyculy" }
        );
    }

    function create(required struct data) {
        queryExecute(
            "INSERT INTO personal_events (owner_user_id, title, start_time, end_time, all_day, timezone_id,
                    event_details, address, reminder_minutes, visibility_tier)
             VALUES (:uid, :title, :stime, :etime, :allday, :tz, :details, :addr, :reminder, :vis)",
            {
                uid:      { value: data.owner_user_id, cfsqltype: "cf_sql_integer" },
                title:    { value: data.title, cfsqltype: "cf_sql_varchar" },
                stime:    { value: data.start_time, cfsqltype: "cf_sql_timestamp" },
                etime:    { value: data.end_time, cfsqltype: "cf_sql_timestamp" },
                allday:   { value: data.all_day ?: false, cfsqltype: "cf_sql_bit" },
                tz:       { value: data.timezone_id ?: "America/New_York", cfsqltype: "cf_sql_varchar" },
                details:  { value: data.event_details ?: "", cfsqltype: "cf_sql_varchar" },
                addr:     { value: data.address ?: "", cfsqltype: "cf_sql_varchar" },
                reminder: { value: data.reminder_minutes ?: "", cfsqltype: "cf_sql_integer", null: !len(data.reminder_minutes ?: "") },
                vis:      { value: data.visibility_tier ?: "invisible", cfsqltype: "cf_sql_varchar" }
            },
            { datasource: "polyculy", result: "qResult" }
        );
        return listFirst(qResult.generatedKey);
    }

    function update(required numeric eventId, required struct data) {
        queryExecute(
            "UPDATE personal_events SET title = :title, start_time = :stime, end_time = :etime,
                    all_day = :allday, timezone_id = :tz, event_details = :details, address = :addr,
                    reminder_minutes = :reminder, visibility_tier = :vis, updated_at = CURRENT_TIMESTAMP
             WHERE event_id = :eid",
            {
                eid:      { value: arguments.eventId, cfsqltype: "cf_sql_integer" },
                title:    { value: data.title, cfsqltype: "cf_sql_varchar" },
                stime:    { value: data.start_time, cfsqltype: "cf_sql_timestamp" },
                etime:    { value: data.end_time, cfsqltype: "cf_sql_timestamp" },
                allday:   { value: data.all_day ?: false, cfsqltype: "cf_sql_bit" },
                tz:       { value: data.timezone_id ?: "America/New_York", cfsqltype: "cf_sql_varchar" },
                details:  { value: data.event_details ?: "", cfsqltype: "cf_sql_varchar" },
                addr:     { value: data.address ?: "", cfsqltype: "cf_sql_varchar" },
                reminder: { value: data.reminder_minutes ?: "", cfsqltype: "cf_sql_integer", null: !len(data.reminder_minutes ?: "") },
                vis:      { value: data.visibility_tier ?: "invisible", cfsqltype: "cf_sql_varchar" }
            },
            { datasource: "polyculy" }
        );
    }

    function cancel(required numeric eventId) {
        queryExecute(
            "UPDATE personal_events SET is_cancelled = TRUE, updated_at = CURRENT_TIMESTAMP WHERE event_id = :eid",
            { eid: { value: arguments.eventId, cfsqltype: "cf_sql_integer" } },
            { datasource: "polyculy" }
        );
    }

    function setVisibility(required numeric eventId, required array visibilityData) {
        // Clear existing visibility
        queryExecute(
            "DELETE FROM personal_event_visibility WHERE event_id = :eid",
            { eid: { value: arguments.eventId, cfsqltype: "cf_sql_integer" } },
            { datasource: "polyculy" }
        );

        // Insert new visibility entries
        for (var entry in arguments.visibilityData) {
            queryExecute(
                "INSERT INTO personal_event_visibility (event_id, target_user_id, visibility_type)
                 VALUES (:eid, :tid, :vtype)",
                {
                    eid:   { value: arguments.eventId, cfsqltype: "cf_sql_integer" },
                    tid:   { value: entry.target_user_id, cfsqltype: "cf_sql_integer" },
                    vtype: { value: entry.visibility_type, cfsqltype: "cf_sql_varchar" }
                },
                { datasource: "polyculy" }
            );
        }
    }

    function getVisibilityForEvent(required numeric eventId) {
        return queryExecute(
            "SELECT pev.visibility_id, pev.target_user_id, pev.visibility_type,
                    u.display_name AS target_name
             FROM personal_event_visibility pev
             JOIN users u ON u.user_id = pev.target_user_id
             WHERE pev.event_id = :eid",
            { eid: { value: arguments.eventId, cfsqltype: "cf_sql_integer" } },
            { datasource: "polyculy" }
        );
    }

}
