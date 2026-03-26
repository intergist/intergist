<cf_main pageTitle="Review Proposals" activePage="calendar">

<div class="container" style="max-width:700px;">
    <h2 class="mb-4"><i class="fas fa-calendar-check me-2"></i>Proposal Review</h2>
    <cfoutput>
    <p class="text-muted">Review time proposals for event ID: <strong>#url.event_id ?: "N/A"#</strong></p>
    </cfoutput>

    <div id="proposalReviewList">
        <div class="text-center py-4"><i class="fas fa-spinner fa-spin fa-2x text-purple"></i></div>
    </div>

    <a href="javascript:history.back()" class="btn btn-polyculy-outline mt-3">
        <i class="fas fa-arrow-left me-1"></i>Back
    </a>
</div>

<script>
$(function() {
    var eid = new URLSearchParams(window.location.search).get('event_id');
    if (!eid) return;

    $.getJSON('/api/proposals.cfm?action=listForEvent&event_id=' + eid, function(r) {
        var data = r.DATA || r.data || [];
        var html = '';
        if (data.length === 0) {
            html = '<div class="empty-state"><i class="fas fa-inbox"></i><h5>No Proposals</h5></div>';
        } else {
            data.forEach(function(p) {
                var pid = p.PROPOSAL_ID || p.proposal_id;
                var name = p.PROPOSER_NAME || p.proposer_name;
                var status = p.STATUS || p.status;
                var msg = p.MESSAGE || p.message || '';
                var pstart = p.PROPOSED_START || p.proposed_start;
                var pend = p.PROPOSED_END || p.proposed_end;

                html += '<div class="event-card mb-3">';
                html += '<div class="d-flex justify-content-between align-items-start">';
                html += '<div>';
                html += '<h5 class="mb-1">' + name + '</h5>';
                html += '<p class="mb-1"><i class="fas fa-clock me-1"></i>' + pstart + ' — ' + pend + '</p>';
                if (msg) html += '<p class="text-muted small mb-0">"' + msg + '"</p>';
                html += '</div>';
                html += '<span class="badge badge-' + (status === 'active' ? 'tentative' : status === 'accepted' ? 'active-event' : 'cancelled') + '">' + status + '</span>';
                html += '</div>';

                if (status === 'active') {
                    html += '<div class="mt-3 text-end">';
                    html += '<button class="btn btn-success me-2" onclick="Polyculy.acceptProposal(' + pid + ')"><i class="fas fa-check me-1"></i>Accept</button>';
                    html += '<button class="btn btn-danger" onclick="Polyculy.rejectProposal(' + pid + ')"><i class="fas fa-times me-1"></i>Reject</button>';
                    html += '</div>';
                }
                html += '</div>';
            });
        }
        $('#proposalReviewList').html(html);
    });
});
</script>

</cf_main>
