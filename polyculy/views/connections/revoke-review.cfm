<cf_main pageTitle="Revoke Connection" activePage="connections">

<div class="container" style="max-width:800px;">
    <div class="polyculy-card card">
        <div class="card-header">
            <h4 class="mb-0"><i class="fas fa-exclamation-triangle me-2 text-danger"></i>Revoke Connection — Impact Review</h4>
        </div>
        <div class="card-body">
            <cfoutput>
                <p class="text-muted">
                    Review the impact of revoking this connection. Shared events involving both of you may need decisions.
                </p>
            </cfoutput>

            <div id="impactLoading" class="text-center py-4">
                <i class="fas fa-spinner fa-spin fa-2x text-purple"></i>
                <p class="text-muted mt-2">Analyzing impact...</p>
            </div>

            <div id="impactList" style="display:none;"></div>

            <div id="noImpact" class="text-center py-4" style="display:none;">
                <i class="fas fa-check-circle fa-2x text-success"></i>
                <p class="text-muted mt-2">No shared events affected. You can safely revoke.</p>
            </div>

            <hr>
            <div class="d-flex justify-content-between">
                <a href="/views/connections/connect.cfm" class="btn btn-polyculy-outline">
                    <i class="fas fa-arrow-left me-1"></i>Cancel
                </a>
                <button class="btn btn-danger" id="confirmRevokeBtn" onclick="Polyculy.confirmRevocation()">
                    <i class="fas fa-heart-broken me-1"></i>Confirm Revocation
                </button>
            </div>
        </div>
    </div>
</div>

<script>
$(function() {
    var connId = new URLSearchParams(window.location.search).get('connection_id');
    if (connId) {
        $.getJSON('/api/connections.cfm?action=revokeImpact&connection_id=' + connId, function(r) {
            var data = r.DATA || r.data || [];
            $('#impactLoading').hide();
            if (data.length === 0) {
                $('#noImpact').show();
            } else {
                var html = '';
                data.forEach(function(evt) {
                    var eid = evt.SHARED_EVENT_ID || evt.shared_event_id;
                    var title = evt.TITLE || evt.title;
                    var pcount = evt.PARTICIPANT_COUNT || evt.participant_count;
                    html += '<div class="event-card mb-3">';
                    html += '<div class="d-flex justify-content-between align-items-center">';
                    html += '<div><strong>' + title + '</strong><br><small class="text-muted">' + pcount + ' participants</small></div>';
                    html += '<select class="form-select form-select-sm" style="width:180px;" data-event-id="' + eid + '">';
                    if (pcount <= 2) {
                        html += '<option value="cancel">Cancel Event</option>';
                    } else {
                        html += '<option value="keep">Keep (no action)</option>';
                        html += '<option value="remove_self">Remove Myself</option>';
                        html += '<option value="remove_other">Remove Other Person</option>';
                        html += '<option value="cancel">Cancel Event</option>';
                    }
                    html += '</select>';
                    html += '</div></div>';
                });
                $('#impactList').html(html).show();
            }
        });
    }
});
</script>

</cf_main>
