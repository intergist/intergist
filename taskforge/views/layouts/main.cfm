<cfif thistag.executionMode eq "start">
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TaskForge - <cfoutput>#attributes.pageTitle ?: "Task Manager"#</cfoutput></title>

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
    <!-- TaskForge Custom -->
    <link href="/assets/css/taskforge.css" rel="stylesheet">

    <!-- jQuery 3.7 (load early for inline scripts) -->
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
    <!-- TaskForge JS -->
    <script src="/assets/js/taskforge.js"></script>
</head>
<body>

    <!-- Sidebar -->
    <nav id="sidebar">
        <div class="sidebar-brand">
            <h4><i class="fas fa-bolt me-2" style="color: #818CF8;"></i>TaskForge</h4>
            <small>Project Manager</small>
        </div>
        <ul class="nav flex-column mt-3">
            <li class="nav-item">
                <a class="nav-link<cfoutput>#(attributes.activePage ?: "") eq "dashboard" ? " active" : ""#</cfoutput>"
                   href="/index.cfm">
                    <i class="fas fa-chart-pie"></i> Dashboard
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link<cfoutput>#(attributes.activePage ?: "") eq "tasks" ? " active" : ""#</cfoutput>"
                   href="/views/tasks/list.cfm">
                    <i class="fas fa-tasks"></i> Tasks
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link<cfoutput>#(attributes.activePage ?: "") eq "projects" ? " active" : ""#</cfoutput>"
                   href="/views/projects/list.cfm">
                    <i class="fas fa-folder-open"></i> Projects
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link<cfoutput>#(attributes.activePage ?: "") eq "team" ? " active" : ""#</cfoutput>"
                   href="/views/team/list.cfm">
                    <i class="fas fa-users"></i> Team
                </a>
            </li>
        </ul>
        <div style="position:absolute; bottom:1rem; left:0; right:0; text-align:center;">
            <small style="color: rgba(255,255,255,0.3); font-size: 0.7rem;">
                ColdFusion + Bootstrap + MSSQL
            </small>
        </div>
    </nav>

    <!-- Main Content -->
    <div id="main-content">
        <!-- Mobile toggle -->
        <button class="btn btn-dark d-lg-none position-fixed"
                style="top:10px; left:10px; z-index:1050;"
                onclick="document.getElementById('sidebar').classList.toggle('show')">
            <i class="fas fa-bars"></i>
        </button>

<cfelseif thistag.executionMode eq "end">

        <footer class="app-footer">
            <a href="https://www.perplexity.ai/computer" target="_blank" rel="noopener noreferrer">
                Created with Perplexity Computer
            </a>
            &middot; TaskForge &copy; <cfoutput>#year(now())#</cfoutput>
        </footer>
    </div>



</body>
</html>
</cfif>
