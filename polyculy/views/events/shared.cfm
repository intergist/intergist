<cf_main pageTitle="Shared Event" activePage="calendar">
<cfscript>
    sharedSvc = new model.SharedEventService();
    eventId = url.id ?: 0;
    evt = sharedSvc.getById(eventId);
</cfscript>

<div class="container" style="max-width:800px;">
    <cfif evt.recordCount>
        <cfoutput>
        <div class="polyculy-card card mb-3">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h4 class="mb-0"><i class="fas fa-users me-2 text-purple"></i>#htmlEditFormat(evt.title)#</h4>
                <span class="badge badge-#evt.global_state eq 'tentative' ? 'tentative' : (evt.global_state eq 'active' ? 'active-event' : 'cancelled')#">
                    #evt.global_state#
                </span>
            </div>
            <div class="card-body">
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label text-muted"><i class="fas fa-clock me-1"></i>Start</label>
                        <p>#dateFormat(evt.start_time, 'mmm dd, yyyy')# #timeFormat(evt.start_time, 'h:mm tt')#</p>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label text-muted"><i class="fas fa-clock me-1"></i>End</label>
                        <p>#dateFormat(evt.end_time, 'mmm dd, yyyy')# #timeFormat(evt.end_time, 'h:mm tt')#</p>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label text-muted"><i class="fas fa-user me-1"></i>Organizer</label>
                        <p>#htmlEditFormat(evt.organizer_name)#</p>
                    </div>
                    <cfif len(evt.address)>
                    <div class="col-md-6">
                        <label class="form-label text-muted"><i class="fas fa-map-marker-alt me-1"></i>Location</label>
                        <p>#htmlEditFormat(evt.address)#</p>
                    </div>
                    </cfif>
                    <cfif len(evt.event_details)>
                    <div class="col-12">
                        <label class="form-label text-muted"><i class="fas fa-info-circle me-1"></i>Details</label>
                        <p>#htmlEditFormat(evt.event_details)#</p>
                    </div>
                    </cfif>
                </div>

                <!-- Participants -->
                <hr>
                <h6 class="text-purple"><i class="fas fa-users me-2"></i>Participants</h6>
                <div id="participantList">Loading...</div>

                <!-- Proposals -->
                <hr>
                <h6 class="text-purple"><i class="fas fa-calendar-check me-2"></i>Time Proposals</h6>
                <div id="proposalList">Loading...</div>
            </div>
            <div class="card-footer d-flex justify-content-between">
                <a href="/views/calendar/month.cfm" class="btn btn-polyculy-outline">
                    <i class="fas fa-arrow-left me-1"></i>Back
                </a>
                <div>
                    <cfif evt.organizer_user_id eq session.userId>
                        <button class="btn btn-polyculy-outline" onclick="Polyculy.editSharedEvent(#evt.shared_event_id#)">
                            <i class="fas fa-edit me-1"></i>Edit
                        </button>
                    <cfelse>
                        <button class="btn btn-polyculy-outline" data-bs-toggle="modal" data-bs-target="##proposeTimeModal">
                            <i class="fas fa-clock me-1"></i>Propose New Time
                        </button>
                    </cfif>
                    <cfif evt.global_state neq "cancelled">
                        <cfif evt.organizer_user_id eq session.userId>
                            <button class="btn btn-danger" onclick="if(confirm('Cancel this event for all participants?')) Polyculy.cancelSharedEvent(#evt.shared_event_id#)">
                                <i class="fas fa-times me-1"></i>Cancel Event
                            </button>
                        </cfif>
                    </cfif>
                </div>
            </div>
        </div>

        <!-- Ownership Transfer Banner -->
        <cfif evt.ownership_transfer_active>
            <div class="alert alert-warning">
                <i class="fas fa-crown me-2"></i>
                <strong>This event needs a new organizer!</strong>
                Claim it before #dateFormat(evt.ownership_transfer_deadline, 'mmm dd, yyyy')# #timeFormat(evt.ownership_transfer_deadline, 'h:mm tt')#.
                <button class="btn btn-sm btn-polyculy ms-2" onclick="Polyculy.claimOwnership(#evt.shared_event_id#)">
                    <i class="fas fa-hand-paper me-1"></i>Claim
                </button>
            </div>
        </cfif>
        </cfoutput>
    <cfelse>
        <div class="empty-state">
            <i class="fas fa-calendar-times"></i>
            <h4>Event Not Found</h4>
            <a href="/views/calendar/month.cfm" class="btn btn-polyculy mt-2">Back to Calendar</a>
        </div>
    </cfif>
</div>

<!-- Propose Time Modal -->
<div class="modal fade" id="proposeTimeModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-clock me-2"></i>Propose New Time</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label">Proposed Start</label>
                    <input type="datetime-local" class="form-control" id="prop_start">
                </div>
                <div class="mb-3">
                    <label class="form-label">Proposed End</label>
                    <input type="datetime-local" class="form-control" id="prop_end">
                </div>
                <div class="mb-3">
                    <label class="form-label">Message (optional)</label>
                    <textarea class="form-control" id="prop_message" rows="2" placeholder="Why this time works better..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-polyculy-outline" data-bs-dismiss="modal">Cancel</button>
                <button class="btn btn-polyculy" onclick="Polyculy.submitProposal(<cfoutput>#eventId#</cfoutput>)">
                    <i class="fas fa-paper-plane me-1"></i>Submit Proposal
                </button>
            </div>
        </div>
    </div>
</div>

<cfif evt.recordCount>
<script>
$(function() {
    var eid = <cfoutput>#eventId#</cfoutput>;
    // Load participants
    $.getJSON('/api/shared-events.cfm?action=get&id=' + eid, function(r) {
        var data = r.DATA || r.data || {};
        var parts = data.participants || data.PARTICIPANTS || [];
        var html = '';
        parts.forEach(function(p) {
            var name = p.DISPLAY_NAME || p.display_name;
            var status = p.RESPONSE_STATUS || p.response_status;
            var removed = p.IS_REMOVED || p.is_removed;
            if (removed) return;
            var statusClass = 'response-' + status;
            var icon = status === 'accepted' ? 'fa-check-circle' : status === 'declined' ? 'fa-times-circle' : status === 'maybe' ? 'fa-question-circle' : 'fa-hourglass-half';
            html += '<div class="d-flex align-items-center gap-2 mb-2">';
            html += '<i class="fas ' + icon + ' ' + statusClass + '"></i> ';
            html += '<strong>' + name + '</strong> <span class="text-muted small">(' + status + ')</span>';
            html += '</div>';
        });
        $('#participantList').html(html || '<p class="text-muted">No participants yet.</p>');
    });

    // Load proposals
    $.getJSON('/api/proposals.cfm?action=listForEvent&event_id=' + eid, function(r) {
        var data = r.DATA || r.data || [];
        var html = '';
        if (data.length === 0) {
            html = '<p class="text-muted">No proposals yet.</p>';
        } else {
            data.forEach(function(p) {
                var pid = p.PROPOSAL_ID || p.proposal_id;
                var pname = p.PROPOSER_NAME || p.proposer_name;
                var status = p.STATUS || p.status;
                var pstart = p.PROPOSED_START || p.proposed_start;
                var pend = p.PROPOSED_END || p.proposed_end;
                var msg = p.MESSAGE || p.message || '';
                html += '<div class="event-card mb-2">';
                html += '<div class="d-flex justify-content-between">';
                html += '<div><strong>' + pname + '</strong> proposed: ' + pstart + ' — ' + pend;
                if (msg) html += '<br><small class="text-muted">' + msg + '</small>';
                html += '</div>';
                html += '<span class="badge badge-' + (status === 'active' ? 'tentative' : status === 'accepted' ? 'active-event' : 'cancelled') + '">' + status + '</span>';
                html += '</div>';
                if (status === 'active') {
                    html += '<div class="mt-2 text-end">';
                    html += '<button class="btn btn-sm btn-success me-1" onclick="Polyculy.acceptProposal(' + pid + ')"><i class="fas fa-check me-1"></i>Accept</button>';
                    html += '<button class="btn btn-sm btn-danger" onclick="Polyculy.rejectProposal(' + pid + ')"><i class="fas fa-times me-1"></i>Reject</button>';
                    html += '</div>';
                }
                html += '</div>';
            });
        }
        $('#proposalList').html(html);
    });
});
</script>
</cfif>

</cf_main>
