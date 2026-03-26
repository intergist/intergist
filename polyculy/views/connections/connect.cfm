<cf_main pageTitle="Connections" activePage="connections">

<div class="container-fluid">
    <div class="row">
        <!-- Main Content -->
        <div class="col-lg-8">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2><i class="fas fa-heart me-2"></i>Connect to Your Polycule</h2>
            </div>

            <!-- Invite Form -->
            <div class="polyculy-card card mb-4">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-user-plus me-2 text-purple"></i>Invite Someone</h5>
                </div>
                <div class="card-body">
                    <div id="inviteError" class="alert alert-danger d-none"></div>
                    <div id="inviteSuccess" class="alert alert-success d-none"></div>
                    <form id="inviteForm" onsubmit="return Polyculy.sendInvite();">
                        <div class="row g-3">
                            <div class="col-md-5">
                                <label class="form-label">Email Address</label>
                                <input type="email" class="form-control" id="inviteEmail" placeholder="partner@email.com" required>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Display Name (optional)</label>
                                <input type="text" class="form-control" id="inviteDisplayName" placeholder="How you know them">
                            </div>
                            <div class="col-md-3 d-flex align-items-end">
                                <button type="submit" class="btn btn-polyculy w-100">
                                    <i class="fas fa-paper-plane me-1"></i>Send Invite
                                </button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Pending Requests -->
            <div class="polyculy-card card mb-4" id="pendingSection" style="display:none;">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-clock me-2" style="color:var(--pc-status-awaiting-confirm);"></i>Pending Requests</h5>
                </div>
                <div class="card-body" id="pendingList"></div>
            </div>

            <!-- Gift Licence Section -->
            <div class="polyculy-card card mb-4">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-gift me-2" style="color:var(--pc-pink);"></i>Gift a Licence</h5>
                </div>
                <div class="card-body">
                    <p class="text-muted small mb-3">Help someone join Polyculy by gifting them a licence code.</p>
                    <div id="giftError" class="alert alert-danger d-none"></div>
                    <div id="giftSuccess" class="alert alert-success d-none"></div>
                    <form id="giftForm" onsubmit="return Polyculy.giftLicence();">
                        <div class="row g-3">
                            <div class="col-md-5">
                                <input type="email" class="form-control" id="giftEmail" placeholder="Recipient email" required>
                            </div>
                            <div class="col-md-4">
                                <select class="form-select" id="giftLicenceCode">
                                    <option value="">Select a licence...</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <button type="submit" class="btn btn-polyculy-pink w-100">
                                    <i class="fas fa-gift me-1"></i>Gift
                                </button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- Polycule Sidebar -->
        <div class="col-lg-4">
            <div class="polycule-sidebar" id="polyculeSidebar">
                <h5><i class="fas fa-heart me-2"></i>Your Polycule</h5>
                <div id="connectionsList">
                    <div class="text-center text-muted py-3">
                        <i class="fas fa-spinner fa-spin"></i> Loading...
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
$(function() {
    Polyculy.loadConnections();
    Polyculy.loadPendingRequests();
    Polyculy.loadAvailableLicences();
});
</script>

</cf_main>
