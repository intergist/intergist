<cf_main pageTitle="Indirect Invitation" activePage="calendar">

<div class="container" style="max-width:600px;">
    <div class="polyculy-card card">
        <div class="card-header">
            <h4 class="mb-0"><i class="fas fa-paper-plane me-2 text-purple"></i>Indirect Invitation</h4>
        </div>
        <div class="card-body">
            <cfoutput>
            <cfset eventId = url.event_id ?: 0>
            </cfoutput>

            <div class="alert alert-info">
                <i class="fas fa-info-circle me-2"></i>
                This invitation was extended to you through a one-hop connection.
                A person you're connected to has consented to pass this invitation to you.
            </div>

            <div id="indirectEventDetails">
                <div class="text-center py-3"><i class="fas fa-spinner fa-spin text-purple"></i></div>
            </div>

            <div class="text-center mt-3">
                <button class="btn btn-success me-2" onclick="Polyculy.respondToInvite(<cfoutput>#eventId#</cfoutput>, 'accepted')">
                    <i class="fas fa-check me-1"></i>Accept
                </button>
                <button class="btn btn-polyculy-outline me-2" onclick="Polyculy.respondToInvite(<cfoutput>#eventId#</cfoutput>, 'maybe')">
                    <i class="fas fa-question me-1"></i>Maybe
                </button>
                <button class="btn btn-outline-danger" onclick="Polyculy.respondToInvite(<cfoutput>#eventId#</cfoutput>, 'declined')">
                    <i class="fas fa-times me-1"></i>Decline
                </button>
            </div>
        </div>
    </div>
</div>

<script>
$(function() {
    var eid = <cfoutput>#url.event_id ?: 0#</cfoutput>;
    if (eid) {
        $.getJSON('/api/shared-events.cfm?action=get&id=' + eid, function(r) {
            var d = r.DATA || r.data || {};
            var html = '<h5>' + (d.TITLE || d.title) + '</h5>';
            html += '<p><i class="fas fa-clock me-1"></i>' + (d.START_TIME || d.start_time) + ' — ' + (d.END_TIME || d.end_time) + '</p>';
            if (d.ADDRESS || d.address) html += '<p><i class="fas fa-map-marker-alt me-1"></i>' + (d.ADDRESS || d.address) + '</p>';
            $('#indirectEventDetails').html(html);
        });
    }
});
</script>

</cf_main>
