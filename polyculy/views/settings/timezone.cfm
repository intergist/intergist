<cf_main pageTitle="Settings" activePage="settings">

<div class="container" style="max-width:700px;">
    <h2 class="mb-4"><i class="fas fa-cog me-2"></i>Settings</h2>

    <div class="row g-4">
        <!-- Profile -->
        <div class="col-12">
            <div class="polyculy-card card">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-user me-2 text-purple"></i>Profile</h5>
                </div>
                <div class="card-body">
                    <div id="profileMsg" class="alert d-none"></div>
                    <form id="profileForm" onsubmit="return Polyculy.saveProfile();">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label">Display Name</label>
                                <input type="text" class="form-control" id="pref_display_name" value="<cfoutput>#htmlEditFormat(session.displayName ?: '')#</cfoutput>">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Email</label>
                                <input type="email" class="form-control" value="<cfoutput>#htmlEditFormat(session.email ?: '')#</cfoutput>" disabled>
                            </div>
                        </div>
                        <div class="text-end mt-3">
                            <button type="submit" class="btn btn-polyculy"><i class="fas fa-save me-1"></i>Save Profile</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- Timezone & Display -->
        <div class="col-12">
            <div class="polyculy-card card">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-globe me-2 text-purple"></i>Timezone & Display</h5>
                </div>
                <div class="card-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label">Timezone</label>
                            <select class="form-select" id="pref_timezone">
                                <cfoutput>
                                <cfset tz = session.timezone ?: "America/New_York">
                                <option value="America/New_York" #tz eq "America/New_York" ? "selected" : ""#>Eastern (New York)</option>
                                <option value="America/Chicago" #tz eq "America/Chicago" ? "selected" : ""#>Central (Chicago)</option>
                                <option value="America/Denver" #tz eq "America/Denver" ? "selected" : ""#>Mountain (Denver)</option>
                                <option value="America/Los_Angeles" #tz eq "America/Los_Angeles" ? "selected" : ""#>Pacific (Los Angeles)</option>
                                <option value="Europe/London" #tz eq "Europe/London" ? "selected" : ""#>GMT (London)</option>
                                <option value="Europe/Paris" #tz eq "Europe/Paris" ? "selected" : ""#>CET (Paris)</option>
                                <option value="Asia/Tokyo" #tz eq "Asia/Tokyo" ? "selected" : ""#>JST (Tokyo)</option>
                                <option value="Australia/Sydney" #tz eq "Australia/Sydney" ? "selected" : ""#>AEST (Sydney)</option>
                                </cfoutput>
                            </select>
                        </div>
                    </div>
                    <div class="text-end mt-3">
                        <button class="btn btn-polyculy" onclick="Polyculy.saveTimezone()">
                            <i class="fas fa-save me-1"></i>Save Timezone
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Change Password -->
        <div class="col-12">
            <div class="polyculy-card card">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-lock me-2 text-purple"></i>Change Password</h5>
                </div>
                <div class="card-body">
                    <div id="pwMsg" class="alert d-none"></div>
                    <form onsubmit="return Polyculy.changePassword();">
                        <div class="row g-3">
                            <div class="col-md-4">
                                <label class="form-label">Current Password</label>
                                <input type="password" class="form-control" id="pw_current">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">New Password</label>
                                <input type="password" class="form-control" id="pw_new" minlength="6">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Confirm New</label>
                                <input type="password" class="form-control" id="pw_confirm" minlength="6">
                            </div>
                        </div>
                        <div class="text-end mt-3">
                            <button type="submit" class="btn btn-polyculy-outline"><i class="fas fa-key me-1"></i>Change Password</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

</cf_main>
