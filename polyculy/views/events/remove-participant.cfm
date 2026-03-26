<cf_main pageTitle="Remove Participant" activePage="calendar">

<div class="container" style="max-width:500px;">
    <div class="polyculy-card card">
        <div class="card-header">
            <h4 class="mb-0"><i class="fas fa-user-minus me-2 text-danger"></i>Remove Participant</h4>
        </div>
        <div class="card-body text-center py-4">
            <cfoutput>
            <cfset eventId = url.event_id ?: 0>
            <cfset participantName = url.participant_name ?: "this participant">
            <cfset participantId = url.participant_id ?: 0>
            </cfoutput>

            <div class="alert alert-warning">
                <i class="fas fa-exclamation-triangle me-2"></i>
                Are you sure you want to remove <strong><cfoutput>#htmlEditFormat(participantName)#</cfoutput></strong> from this event?
            </div>

            <p class="text-muted small">
                They will be notified and their response will be cleared.
                If they're the organizer, an ownership transfer will be triggered.
            </p>

            <div class="d-flex justify-content-center gap-3 mt-4">
                <a href="javascript:history.back()" class="btn btn-polyculy-outline">
                    <i class="fas fa-arrow-left me-1"></i>Cancel
                </a>
                <button class="btn btn-danger" onclick="Polyculy.removeParticipant(<cfoutput>#eventId#</cfoutput>, <cfoutput>#participantId#</cfoutput>)">
                    <i class="fas fa-user-minus me-1"></i>Remove
                </button>
            </div>
        </div>
    </div>
</div>

</cf_main>
