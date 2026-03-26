<cfscript>
    setting showDebugOutput=false;
    cfheader(name="Content-Type", value="application/json");

    propSvc = new model.ProposalService();
    auditSvc = new model.AuditService();
    notifSvc = new model.NotificationService();
    sharedSvc = new model.SharedEventService();

    action = url.action ?: "list";
    response = { "success": true };

    try {
        switch (action) {
            case "listForEvent":
                q = propSvc.getForEvent(url.event_id);
                data = [];
                for (row in q) { arrayAppend(data, row); }
                response["data"] = data;
                break;

            case "activeForEvent":
                q = propSvc.getActiveForEvent(url.event_id);
                data = [];
                for (row in q) { arrayAppend(data, row); }
                response["data"] = data;
                break;

            case "create":
                newId = propSvc.create({
                    shared_event_id: form.event_id,
                    proposer_user_id: session.userId,
                    proposed_start: form.proposed_start,
                    proposed_end: form.proposed_end,
                    message: form.message ?: ""
                });

                // Notify organizer
                evt = sharedSvc.getById(form.event_id);
                if (evt.organizer_user_id != session.userId) {
                    notifSvc.create(evt.organizer_user_id, "proposal_received", "New Time Proposal", "#session.displayName# proposed a new time for ""#evt.title#"".", "shared_event", form.event_id);
                }

                auditSvc.log(session.userId, "proposal_create", "shared_event", form.event_id, "Proposed new time");
                response["message"] = "Proposal submitted";
                response["id"] = newId;
                break;

            case "accept":
                propSvc.accept(form.proposal_id);

                prop = propSvc.getById(form.proposal_id);
                notifSvc.create(prop.proposer_user_id, "proposal_accepted", "Proposal Accepted", "Your time proposal was accepted.", "shared_event", prop.shared_event_id);

                auditSvc.log(session.userId, "proposal_accept", "shared_event", prop.shared_event_id, "Accepted time proposal");
                response["message"] = "Proposal accepted — event time updated, acceptances reset";
                break;

            case "reject":
                propSvc.reject(form.proposal_id);

                prop = propSvc.getById(form.proposal_id);
                notifSvc.create(prop.proposer_user_id, "proposal_rejected", "Proposal Rejected", "Your time proposal was not accepted.", "shared_event", prop.shared_event_id);

                auditSvc.log(session.userId, "proposal_reject", "shared_event", prop.shared_event_id, "Rejected time proposal");
                response["message"] = "Proposal rejected";
                break;

            case "withdraw":
                propSvc.withdraw(form.proposal_id);
                response["message"] = "Proposal withdrawn";
                break;

            default:
                response = { "success": false, "message": "Unknown action" };
        }
    } catch (any e) {
        response = { "success": false, "message": e.message };
    }

    writeOutput(serializeJSON(response));
</cfscript>
