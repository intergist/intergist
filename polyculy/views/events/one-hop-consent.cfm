<cf_main pageTitle="One-Hop Consent" activePage="calendar">

<div class="container" style="max-width:550px;">
    <div class="polyculy-card card">
        <div class="card-header text-center">
            <h4 class="mb-0"><i class="fas fa-link me-2 text-purple"></i>One-Hop Invitation Consent</h4>
        </div>
        <div class="card-body text-center py-4">
            <cfoutput>
            <cfset eventId = url.event_id ?: 0>
            <cfset downstreamName = url.downstream_name ?: "someone">

            <p class="mb-3">
                The organizer would like to invite <strong>#htmlEditFormat(downstreamName)#</strong>
                to this event through your connection.
            </p>
            <p class="text-muted small mb-4">
                If you consent, <strong>#htmlEditFormat(downstreamName)#</strong> will receive an invitation.
                Your acceptance or decline of the event is independent of this consent.
            </p>

            <div class="d-flex justify-content-center gap-3">
                <button class="btn btn-success" onclick="Polyculy.oneHopConsent(#eventId#, true, true)">
                    <i class="fas fa-check me-1"></i>Accept & Allow
                </button>
                <button class="btn btn-polyculy-outline" onclick="Polyculy.oneHopConsent(#eventId#, true, false)">
                    <i class="fas fa-user-check me-1"></i>Accept Without Allowing
                </button>
                <button class="btn btn-outline-danger" onclick="Polyculy.oneHopConsent(#eventId#, false, false)">
                    <i class="fas fa-times me-1"></i>Cancel
                </button>
            </div>
            </cfoutput>
        </div>
    </div>
</div>

</cf_main>
