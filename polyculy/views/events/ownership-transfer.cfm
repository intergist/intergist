<cf_main pageTitle="Ownership Transfer" activePage="calendar">

<div class="container" style="max-width:600px;">
    <div class="polyculy-card card">
        <div class="card-header">
            <h4 class="mb-0"><i class="fas fa-crown me-2 text-purple"></i>Claim Event Ownership</h4>
        </div>
        <div class="card-body">
            <cfoutput>
            <cfset eventId = url.event_id ?: 0>
            </cfoutput>

            <div class="alert alert-warning">
                <i class="fas fa-exclamation-triangle me-2"></i>
                The organizer of this event has been removed. Someone needs to claim ownership or the event will be cancelled when the deadline expires.
            </div>

            <div id="transferEventDetails">
                <div class="text-center py-3"><i class="fas fa-spinner fa-spin text-purple"></i></div>
            </div>

            <div class="text-center mt-4">
                <button class="btn btn-polyculy btn-lg" onclick="Polyculy.claimOwnership(<cfoutput>#eventId#</cfoutput>)">
                    <i class="fas fa-hand-paper me-2"></i>Claim This Event
                </button>
                <p class="text-muted small mt-2">First person to claim becomes the new organizer.</p>
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
            html += '<p><i class="fas fa-clock me-1"></i>' + (d.START_TIME || d.start_time) + '</p>';
            var deadline = d.OWNERSHIP_TRANSFER_DEADLINE || d.ownership_transfer_deadline;
            if (deadline) html += '<p class="text-danger"><i class="fas fa-hourglass-half me-1"></i>Claim by: ' + deadline + '</p>';
            $('#transferEventDetails').html(html);
        });
    }
});
</script>

</cf_main>
