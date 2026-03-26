<cf_main pageTitle="Invitation Results" activePage="connections">

<div class="container" style="max-width:700px;">
    <div class="polyculy-card card">
        <div class="card-header text-center">
            <h4 class="mb-0"><i class="fas fa-check-circle me-2 text-purple"></i>Invitation Sent</h4>
        </div>
        <div class="card-body text-center py-4">
            <cfoutput>
                <cfset resultStatus = url.status ?: "awaiting_signup">
                <cfset resultEmail = url.email ?: "">

                <cfif resultStatus eq "awaiting_confirmation">
                    <div class="mb-3">
                        <span class="status-badge status-awaiting_confirmation" style="font-size:1rem; padding:0.5rem 1.25rem;">
                            <span class="status-dot"></span> Awaiting Confirmation
                        </span>
                    </div>
                    <p class="text-muted">
                        <strong>#htmlEditFormat(resultEmail)#</strong> is already on Polyculy.<br>
                        They'll see your connection request next time they log in.
                    </p>
                <cfelseif resultStatus eq "awaiting_signup">
                    <div class="mb-3">
                        <span class="status-badge status-awaiting_signup" style="font-size:1rem; padding:0.5rem 1.25rem;">
                            <span class="status-dot"></span> Awaiting Signup
                        </span>
                    </div>
                    <p class="text-muted">
                        <strong>#htmlEditFormat(resultEmail)#</strong> doesn't have a Polyculy account yet.<br>
                        They'll need a licence code to sign up. Want to gift one?
                    </p>
                    <a href="/views/connections/connect.cfm" class="btn btn-polyculy-pink me-2">
                        <i class="fas fa-gift me-1"></i>Gift a Licence
                    </a>
                <cfelse>
                    <p class="text-muted">Invitation status: #htmlEditFormat(resultStatus)#</p>
                </cfif>
            </cfoutput>

            <a href="/views/connections/connect.cfm" class="btn btn-polyculy-outline">
                <i class="fas fa-arrow-left me-1"></i>Back to Connections
            </a>
        </div>
    </div>
</div>

</cf_main>
