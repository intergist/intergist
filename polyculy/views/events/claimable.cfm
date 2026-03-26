<cf_main pageTitle="Claimable Event" activePage="calendar">

<div class="container" style="max-width:600px;">
    <div class="polyculy-card card">
        <div class="card-header">
            <h4 class="mb-0"><i class="fas fa-gift me-2 text-purple"></i>Claimable Event</h4>
        </div>
        <div class="card-body text-center py-4">
            <cfoutput>
            <cfset eventId = url.event_id ?: 0>
            </cfoutput>

            <i class="fas fa-calendar-check fa-3x text-purple mb-3"></i>
            <h5>Someone sent you event details!</h5>
            <p class="text-muted">
                An existing Polyculy user shared this event with you via informational email.
                If you sign up, you can claim this event and join as a participant.
            </p>

            <div id="claimableDetails" class="text-start bg-purple-light rounded-3 p-3 mb-3">
                <div class="text-center py-2"><i class="fas fa-spinner fa-spin text-purple"></i></div>
            </div>

            <a href="/views/auth/signup.cfm" class="btn btn-polyculy btn-lg">
                <i class="fas fa-user-plus me-1"></i>Sign Up to Claim
            </a>
        </div>
    </div>
</div>

</cf_main>
