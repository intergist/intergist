<cfif thistag.executionMode eq "start">
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Polyculy - <cfoutput>#attributes.pageTitle ?: "Calendar that keeps up"#</cfoutput></title>

    <!-- Bootstrap 5.3 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome 6 -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <!-- DataTables Bootstrap 5 -->
    <link href="https://cdn.datatables.net/1.13.8/css/dataTables.bootstrap5.min.css" rel="stylesheet">
    <!-- Chosen -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/chosen/1.8.7/chosen.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <!-- Polyculy Custom -->
    <link href="/assets/css/polyculy.css" rel="stylesheet">

    <!-- jQuery 3.7 -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <!-- Bootstrap 5.3 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <!-- DataTables -->
    <script src="https://cdn.datatables.net/1.13.8/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.8/js/dataTables.bootstrap5.min.js"></script>
    <!-- Chosen -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/chosen/1.8.7/chosen.jquery.min.js"></script>
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
    <!-- Polyculy JS -->
    <script src="/assets/js/polyculy.js"></script>
</head>
<body>

    <!-- Top Navbar -->
    <nav class="navbar navbar-expand-lg polyculy-navbar sticky-top">
        <div class="container-fluid">
            <a class="navbar-brand d-flex align-items-center" href="/views/calendar/month.cfm">
                <svg width="32" height="32" viewBox="0 0 40 40" class="me-2">
                    <defs>
                        <linearGradient id="heartGrad1" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" style="stop-color:#7C3AED"/>
                            <stop offset="100%" style="stop-color:#EC4899"/>
                        </linearGradient>
                        <linearGradient id="heartGrad2" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" style="stop-color:#EC4899"/>
                            <stop offset="100%" style="stop-color:#C4B5FD"/>
                        </linearGradient>
                    </defs>
                    <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z" fill="url(#heartGrad1)" transform="translate(2,5) scale(0.8)"/>
                    <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z" fill="url(#heartGrad2)" transform="translate(12,8) scale(0.8)" opacity="0.8"/>
                </svg>
                <span class="brand-text">Polyculy</span>
            </a>

            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>

            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link<cfoutput>#(attributes.activePage ?: "") eq "calendar" ? " active" : ""#</cfoutput>"
                           href="/views/calendar/month.cfm">
                            <i class="fas fa-calendar-alt me-1"></i> Calendar
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link<cfoutput>#(attributes.activePage ?: "") eq "connections" ? " active" : ""#</cfoutput>"
                           href="/views/connections/connect.cfm">
                            <i class="fas fa-heart me-1"></i> Connections
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link<cfoutput>#(attributes.activePage ?: "") eq "settings" ? " active" : ""#</cfoutput>"
                           href="/views/settings/timezone.cfm">
                            <i class="fas fa-cog me-1"></i> Settings
                        </a>
                    </li>
                </ul>

                <ul class="navbar-nav">
                    <!-- Notification Bell -->
                    <li class="nav-item dropdown">
                        <a class="nav-link position-relative" href="#" id="notifBell" data-bs-toggle="dropdown">
                            <i class="fas fa-bell"></i>
                            <span class="badge bg-danger rounded-pill position-absolute top-0 start-100 translate-middle notif-badge" id="notifCount" style="display:none;">0</span>
                        </a>
                        <div class="dropdown-menu dropdown-menu-end notif-dropdown" style="width:350px; max-height:400px; overflow-y:auto;">
                            <div class="d-flex justify-content-between align-items-center px-3 py-2 border-bottom">
                                <strong>Notifications</strong>
                                <a href="#" class="small text-decoration-none" onclick="Polyculy.markAllNotifRead(); return false;">Mark all read</a>
                            </div>
                            <div id="notifList">
                                <div class="text-center text-muted py-3"><small>Loading...</small></div>
                            </div>
                        </div>
                    </li>
                    <!-- User Menu -->
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
                            <i class="fas fa-user-circle me-1"></i>
                            <cfoutput>#session.displayName ?: "User"#</cfoutput>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end">
                            <li><a class="dropdown-item" href="/views/settings/timezone.cfm"><i class="fas fa-cog me-2"></i>Settings</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="#" onclick="Polyculy.logout(); return false;"><i class="fas fa-sign-out-alt me-2"></i>Logout</a></li>
                        </ul>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <div class="main-content">

<cfelseif thistag.executionMode eq "end">

    </div>

    <!-- Toast Container -->
    <div class="position-fixed bottom-0 end-0 p-3" style="z-index: 1055;">
        <div id="appToast" class="toast align-items-center text-white bg-success border-0" role="alert">
            <div class="d-flex">
                <div class="toast-body" id="toastMessage"></div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
            </div>
        </div>
    </div>

    <footer class="app-footer text-center py-2">
        <small class="text-muted">Polyculy &copy; <cfoutput>#year(now())#</cfoutput> &middot; Calendar that keeps up</small>
    </footer>

</body>
</html>
</cfif>
