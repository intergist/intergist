<cf_main pageTitle="Send Info Email" activePage="calendar">

<div class="container" style="max-width:550px;">
    <div class="polyculy-card card">
        <div class="card-header">
            <h4 class="mb-0"><i class="fas fa-envelope me-2 text-purple"></i>Send Informational Email</h4>
        </div>
        <div class="card-body">
            <cfoutput>
            <cfset eventId = url.event_id ?: 0>
            </cfoutput>

            <p class="text-muted small mb-3">
                Send event details to someone who isn't on Polyculy. They'll receive an informational email with a link to claim the event if they sign up.
            </p>

            <div class="mb-3">
                <label class="form-label">Recipient Name</label>
                <input type="text" class="form-control" id="ie_name" placeholder="Their name">
            </div>
            <div class="mb-3">
                <label class="form-label">Recipient Email</label>
                <input type="email" class="form-control" id="ie_email" placeholder="them@email.com" required>
            </div>
            <div class="mb-3">
                <label class="form-label">Personal Note</label>
                <textarea class="form-control" id="ie_note" rows="3" placeholder="Hey! Here are the details for..."></textarea>
            </div>

            <button class="btn btn-polyculy w-100" onclick="Polyculy.sendInfoEmail(<cfoutput>#eventId#</cfoutput>)">
                <i class="fas fa-paper-plane me-1"></i>Send Email
            </button>
        </div>
    </div>
</div>

</cf_main>
