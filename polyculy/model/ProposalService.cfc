component {

    function create(required struct data) {
        // Check for existing active proposal from this user
        var existing = queryExecute(
            "SELECT proposal_id FROM proposals
             WHERE shared_event_id = :eid AND proposer_user_id = :uid AND status = 'active'",
            {
                eid: { value: data.shared_event_id, cfsqltype: "cf_sql_integer" },
                uid: { value: data.proposer_user_id, cfsqltype: "cf_sql_integer" }
            },
            { datasource: "polyculy" }
        );

        // Withdraw existing active proposal
        if (existing.recordCount) {
            withdraw(existing.proposal_id);
        }

        queryExecute(
            "INSERT INTO proposals (shared_event_id, proposer_user_id, proposed_start, proposed_end, message, status)
             VALUES (:eid, :uid, :pstart, :pend, :msg, 'active')",
            {
                eid:    { value: data.shared_event_id, cfsqltype: "cf_sql_integer" },
                uid:    { value: data.proposer_user_id, cfsqltype: "cf_sql_integer" },
                pstart: { value: data.proposed_start, cfsqltype: "cf_sql_timestamp" },
                pend:   { value: data.proposed_end, cfsqltype: "cf_sql_timestamp" },
                msg:    { value: data.message ?: "", cfsqltype: "cf_sql_varchar" }
            },
            { datasource: "polyculy", result: "qResult" }
        );
        return listFirst(qResult.generatedKey);
    }

    function getById(required numeric proposalId) {
        return queryExecute(
            "SELECT p.*, u.display_name AS proposer_name
             FROM proposals p
             JOIN users u ON u.user_id = p.proposer_user_id
             WHERE p.proposal_id = :pid",
            { pid: { value: arguments.proposalId, cfsqltype: "cf_sql_integer" } },
            { datasource: "polyculy" }
        );
    }

    function getForEvent(required numeric eventId) {
        return queryExecute(
            "SELECT p.proposal_id, p.proposer_user_id, p.proposed_start, p.proposed_end,
                    p.message, p.status, p.created_at,
                    u.display_name AS proposer_name
             FROM proposals p
             JOIN users u ON u.user_id = p.proposer_user_id
             WHERE p.shared_event_id = :eid
             ORDER BY p.created_at DESC",
            { eid: { value: arguments.eventId, cfsqltype: "cf_sql_integer" } },
            { datasource: "polyculy" }
        );
    }

    function getActiveForEvent(required numeric eventId) {
        return queryExecute(
            "SELECT p.proposal_id, p.proposer_user_id, p.proposed_start, p.proposed_end,
                    p.message, p.created_at,
                    u.display_name AS proposer_name
             FROM proposals p
             JOIN users u ON u.user_id = p.proposer_user_id
             WHERE p.shared_event_id = :eid AND p.status = 'active'
             ORDER BY p.created_at DESC",
            { eid: { value: arguments.eventId, cfsqltype: "cf_sql_integer" } },
            { datasource: "polyculy" }
        );
    }

    function accept(required numeric proposalId) {
        var proposal = getById(arguments.proposalId);
        if (!proposal.recordCount) return;

        // Update proposal status
        queryExecute(
            "UPDATE proposals SET status = 'accepted', updated_at = CURRENT_TIMESTAMP WHERE proposal_id = :pid",
            { pid: { value: arguments.proposalId, cfsqltype: "cf_sql_integer" } },
            { datasource: "polyculy" }
        );

        // Apply the proposed times to the shared event (material edit)
        var sharedSvc = new model.SharedEventService();
        var evt = sharedSvc.getById(proposal.shared_event_id);
        sharedSvc.updateMaterial(proposal.shared_event_id, {
            title: evt.title,
            start_time: proposal.proposed_start,
            end_time: proposal.proposed_end,
            all_day: evt.all_day,
            timezone_id: evt.timezone_id,
            event_details: evt.event_details,
            address: evt.address
        });

        // Reject all other active proposals for this event
        queryExecute(
            "UPDATE proposals SET status = 'rejected', updated_at = CURRENT_TIMESTAMP
             WHERE shared_event_id = :eid AND status = 'active' AND proposal_id != :pid",
            {
                eid: { value: proposal.shared_event_id, cfsqltype: "cf_sql_integer" },
                pid: { value: arguments.proposalId, cfsqltype: "cf_sql_integer" }
            },
            { datasource: "polyculy" }
        );
    }

    function reject(required numeric proposalId) {
        queryExecute(
            "UPDATE proposals SET status = 'rejected', updated_at = CURRENT_TIMESTAMP WHERE proposal_id = :pid",
            { pid: { value: arguments.proposalId, cfsqltype: "cf_sql_integer" } },
            { datasource: "polyculy" }
        );
    }

    function withdraw(required numeric proposalId) {
        queryExecute(
            "UPDATE proposals SET status = 'withdrawn', updated_at = CURRENT_TIMESTAMP WHERE proposal_id = :pid",
            { pid: { value: arguments.proposalId, cfsqltype: "cf_sql_integer" } },
            { datasource: "polyculy" }
        );
    }

}
