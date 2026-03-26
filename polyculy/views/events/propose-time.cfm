<cf_main pageTitle="Propose New Time" activePage="calendar">
<!-- This screen is primarily a modal embedded in shared.cfm and invitation-card.cfm.
     This page provides a standalone fallback. -->

<div class="container" style="max-width:500px;">
    <div class="polyculy-card card">
        <div class="card-header">
            <h4 class="mb-0"><i class="fas fa-clock me-2 text-purple"></i>Propose New Time</h4>
        </div>
        <div class="card-body">
            <cfoutput>
            <p class="text-muted">Suggest a better time for event ID: <strong>#url.event_id ?: "N/A"#</strong></p>
            </cfoutput>
            <div class="mb-3">
                <label class="form-label">Proposed Start</label>
                <input type="datetime-local" class="form-control" id="prop_start">
            </div>
            <div class="mb-3">
                <label class="form-label">Proposed End</label>
                <input type="datetime-local" class="form-control" id="prop_end">
            </div>
            <div class="mb-3">
                <label class="form-label">Message</label>
                <textarea class="form-control" id="prop_message" rows="3" placeholder="Why this time works better..."></textarea>
            </div>
            <button class="btn btn-polyculy w-100" onclick="Polyculy.submitProposal(<cfoutput>#url.event_id ?: 0#</cfoutput>)">
                <i class="fas fa-paper-plane me-1"></i>Submit Proposal
            </button>
        </div>
    </div>
</div>

</cf_main>
