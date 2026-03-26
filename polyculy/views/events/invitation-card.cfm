<cf_main pageTitle="Event Invitation" activePage="calendar">
<cfscript>
    sharedSvc = new model.SharedEventService();
    eventId = url.id ?: 0;
    evt = sharedSvc.getById(eventId);
    participants = sharedSvc.getParticipants(eventId);
</cfscript>

<div class="container" style="max-width:600px;">
    <cfif evt.recordCount>
        <cfoutput>
        <div class="invitation-card">
            <div class="text-center mb-3">
                <i class="fas fa-envelope-open-text fa-2x" style="color:var(--pc-primary-dark);"></i>
                <h3 class="mt-2" style="color:var(--pc-primary-dark);">You're Invited!</h3>
            </div>

            <div class="bg-white rounded-3 p-4 mb-3">
                <h4 class="text-purple">#htmlEditFormat(evt.title)#</h4>
                <p class="mb-2">
                    <i class="fas fa-clock text-purple me-2"></i>
                    #dateFormat(evt.start_time, 'dddd, mmmm dd, yyyy')# at #timeFormat(evt.start_time, 'h:mm tt')#
                </p>
                <cfif len(evt.address)>
                <p class="mb-2">
                    <i class="fas fa-map-marker-alt text-purple me-2"></i>
                    #htmlEditFormat(evt.address)#
                </p>
                </cfif>
                <p class="mb-2">
                    <i class="fas fa-user text-purple me-2"></i>
                    Organized by <strong>#htmlEditFormat(evt.organizer_name)#</strong>
                </p>

                <cfif evt.participant_visibility eq "visible">
                <hr>
                <p class="text-muted small mb-2">Participants:</p>
                <div class="participant-avatars d-flex">
                    <cfloop query="participants">
                        <cfif !participants.is_removed>
                        <div class="participant-avatar" style="background:var(--pc-primary);" title="#htmlEditFormat(participants.display_name)# (#participants.response_status#)">
                            #uCase(left(participants.display_name, 1))#
                        </div>
                        </cfif>
                    </cfloop>
                </div>
                </cfif>
            </div>

            <div class="text-center">
                <span class="badge badge-#evt.global_state eq 'tentative' ? 'tentative' : 'active-event'# mb-3" style="font-size:0.85rem;">
                    #evt.global_state#
                </span>

                <div class="d-flex justify-content-center gap-2">
                    <button class="btn btn-success btn-lg" onclick="Polyculy.respondToInvite(#evt.shared_event_id#, 'accepted')">
                        <i class="fas fa-check me-1"></i>Accept
                    </button>
                    <button class="btn btn-polyculy-outline btn-lg" onclick="Polyculy.respondToInvite(#evt.shared_event_id#, 'maybe')">
                        <i class="fas fa-question me-1"></i>Maybe
                    </button>
                    <button class="btn btn-outline-danger btn-lg" onclick="Polyculy.respondToInvite(#evt.shared_event_id#, 'declined')">
                        <i class="fas fa-times me-1"></i>Decline
                    </button>
                </div>

                <div class="mt-3">
                    <a href="#" class="btn btn-polyculy-ghost" onclick="$('##proposeTimeModal').modal('show'); return false;">
                        <i class="fas fa-clock me-1"></i>Propose Different Time
                    </a>
                </div>
            </div>
        </div>
        </cfoutput>
    <cfelse>
        <div class="empty-state">
            <i class="fas fa-calendar-times"></i>
            <h4>Invitation Not Found</h4>
        </div>
    </cfif>
</div>

</cf_main>
