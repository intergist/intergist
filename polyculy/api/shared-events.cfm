<cfscript>
    setting showDebugOutput=false;
    cfheader(name="Content-Type", value="application/json");

    sharedSvc = new model.SharedEventService();
    auditSvc = new model.AuditService();
    notifSvc = new model.NotificationService();

    action = url.action ?: "list";
    response = { "success": true };

    try {
        switch (action) {
            case "list":
                q = sharedSvc.getForUser(session.userId, url.start_date ?: "", url.end_date ?: "");
                data = [];
                for (row in q) { arrayAppend(data, row); }
                response["data"] = data;
                break;

            case "get":
                q = sharedSvc.getById(url.id);
                if (q.recordCount) {
                    row = {};
                    for (col in listToArray(q.columnList)) { row[lCase(col)] = q[col][1]; }
                    participants = sharedSvc.getParticipants(url.id);
                    pData = [];
                    for (p in participants) { arrayAppend(pData, p); }
                    row["participants"] = pData;
                    response["data"] = row;
                } else {
                    response = { "success": false, "message": "Event not found" };
                }
                break;

            case "create":
                data = {
                    organizer_user_id: session.userId,
                    title: form.title,
                    start_time: form.start_time,
                    end_time: form.end_time,
                    all_day: form.all_day ?: false,
                    timezone_id: form.timezone_id ?: session.timezone ?: "America/New_York",
                    event_details: form.event_details ?: "",
                    address: form.address ?: "",
                    reminder_minutes: form.reminder_minutes ?: "",
                    reminder_scope: form.reminder_scope ?: "me",
                    participant_visibility: form.participant_visibility ?: "visible"
                };

                newId = sharedSvc.create(data);

                // Add invited participants
                if (structKeyExists(form, "participants") && len(form.participants)) {
                    var participantIds = listToArray(form.participants);
                    for (var pid in participantIds) {
                        sharedSvc.addParticipant(newId, pid, form["attendance_#pid#"] ?: "required");
                        notifSvc.create(pid, "shared_event_invite", "New Shared Event Invite", "#session.displayName# invited you to #form.title#.", "shared_event", newId);
                    }
                }

                auditSvc.log(session.userId, "event_create", "shared_event", newId, "Created shared event: #form.title#");
                response["message"] = "Shared event created";
                response["id"] = newId;
                break;

            case "updateMinor":
                sharedSvc.updateMinor(form.event_id, {
                    title: form.title,
                    event_details: form.event_details ?: "",
                    participant_visibility: form.participant_visibility ?: "visible"
                });
                auditSvc.log(session.userId, "event_update_minor", "shared_event", form.event_id, "Minor edit to: #form.title#");
                response["message"] = "Event updated (minor)";
                break;

            case "updateMaterial":
                sharedSvc.updateMaterial(form.event_id, {
                    title: form.title,
                    start_time: form.start_time,
                    end_time: form.end_time,
                    all_day: form.all_day ?: false,
                    timezone_id: form.timezone_id ?: "America/New_York",
                    event_details: form.event_details ?: "",
                    address: form.address ?: ""
                });

                // Notify participants of material change
                participants = sharedSvc.getParticipants(form.event_id);
                for (var p in participants) {
                    if (p.user_id != session.userId && !p.is_removed) {
                        notifSvc.create(p.user_id, "event_material_change", "Event Time Changed", "The time/location for ""#form.title#"" has changed. Please review.", "shared_event", form.event_id);
                    }
                }

                auditSvc.log(session.userId, "event_update_material", "shared_event", form.event_id, "Material edit to: #form.title#");
                response["message"] = "Event updated (material change — acceptances reset)";
                break;

            case "respond":
                sharedSvc.respondToInvitation(form.event_id, session.userId, form.response);

                // Notify organizer
                evt = sharedSvc.getById(form.event_id);
                if (evt.organizer_user_id != session.userId) {
                    notifSvc.create(evt.organizer_user_id, "event_#form.response#", "Event Response", "#session.displayName# #form.response# your event ""#evt.title#"".", "shared_event", form.event_id);
                }

                auditSvc.log(session.userId, "event_respond", "shared_event", form.event_id, "Responded #form.response# to shared event");
                response["message"] = "Response recorded";
                break;

            case "addParticipant":
                sharedSvc.addParticipant(form.event_id, form.user_id, form.attendance_type ?: "required", "pending", form.is_one_hop ?: false, form.link_person_user_id ?: 0);
                notifSvc.create(form.user_id, "shared_event_invite", "New Shared Event Invite", "You've been invited to a shared event.", "shared_event", form.event_id);
                response["message"] = "Participant added";
                break;

            case "removeParticipant":
                sharedSvc.removeParticipant(form.event_id, form.user_id);
                evt = sharedSvc.getById(form.event_id);

                // Check if organizer was removed — trigger ownership transfer
                if (form.user_id == evt.organizer_user_id) {
                    var ownerSvc = new model.OwnershipTransferService();
                    var transferResult = ownerSvc.initiateTransfer(form.event_id, form.user_id);
                    response["transfer"] = transferResult;
                }

                auditSvc.log(session.userId, "participant_remove", "shared_event", form.event_id, "Removed participant from shared event");
                response["message"] = "Participant removed";
                break;

            case "cancel":
                sharedSvc.cancelEvent(form.event_id, form.reason ?: "");

                // Notify all participants
                participants = sharedSvc.getParticipants(form.event_id);
                for (var p in participants) {
                    if (p.user_id != session.userId && !p.is_removed) {
                        notifSvc.create(p.user_id, "event_cancelled", "Event Cancelled", "The event has been cancelled.", "shared_event", form.event_id);
                    }
                }

                auditSvc.log(session.userId, "event_cancel", "shared_event", form.event_id, "Cancelled shared event");
                response["message"] = "Event cancelled";
                break;

            case "checkConflicts":
                conflicts = sharedSvc.checkConflicts(url.user_id ?: session.userId, url.start_time, url.end_time, url.exclude_event_id ?: 0);
                response["data"] = conflicts;
                break;

            case "claimOwnership":
                var ownerSvc = new model.OwnershipTransferService();
                claimResult = ownerSvc.claimOwnership(form.event_id, session.userId);
                response["success"] = claimResult.success;
                response["message"] = claimResult.message;
                break;

            case "oneHopConsent":
                // Direct invitee consents for one-hop downstream invite
                queryExecute(
                    "UPDATE shared_event_participants SET one_hop_consent_given = :consent, updated_at = CURRENT_TIMESTAMP
                     WHERE shared_event_id = :eid AND user_id = :uid",
                    {
                        eid: { value: form.event_id, cfsqltype: "cf_sql_integer" },
                        uid: { value: session.userId, cfsqltype: "cf_sql_integer" },
                        consent: { value: form.consent ?: true, cfsqltype: "cf_sql_bit" }
                    },
                    { datasource: "polyculy" }
                );

                // If consented, activate the one-hop invite
                if (form.consent ?: true) {
                    queryExecute(
                        "UPDATE shared_event_participants SET one_hop_activated = TRUE, updated_at = CURRENT_TIMESTAMP
                         WHERE shared_event_id = :eid AND link_person_user_id = :uid AND is_one_hop = TRUE",
                        {
                            eid: { value: form.event_id, cfsqltype: "cf_sql_integer" },
                            uid: { value: session.userId, cfsqltype: "cf_sql_integer" }
                        },
                        { datasource: "polyculy" }
                    );
                }

                response["message"] = "Consent recorded";
                break;

            default:
                response = { "success": false, "message": "Unknown action" };
        }
    } catch (any e) {
        response = { "success": false, "message": e.message };
    }

    writeOutput(serializeJSON(response));
</cfscript>
