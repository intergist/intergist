<cf_main pageTitle="Dashboard" activePage="dashboard">

<div class="page-header">
    <h1><i class="fas fa-chart-pie me-2 text-primary"></i>Dashboard</h1>
    <span class="text-muted-sm">Overview of all projects and tasks</span>
</div>

<div class="page-body">

    <!-- KPI Row -->
    <div class="row g-3 mb-4" id="kpi-row">
        <div class="col-md-3 col-6">
            <div class="stat-card">
                <div class="d-flex justify-content-between align-items-start">
                    <div>
                        <div class="stat-value" id="kpi-total-tasks">-</div>
                        <div class="stat-label mt-1">Total Tasks</div>
                    </div>
                    <div class="stat-icon" style="background:#EEF2FF; color:#4F46E5;">
                        <i class="fas fa-tasks"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-3 col-6">
            <div class="stat-card">
                <div class="d-flex justify-content-between align-items-start">
                    <div>
                        <div class="stat-value" id="kpi-in-progress">-</div>
                        <div class="stat-label mt-1">In Progress</div>
                    </div>
                    <div class="stat-icon" style="background:#DBEAFE; color:#1D4ED8;">
                        <i class="fas fa-spinner"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-3 col-6">
            <div class="stat-card">
                <div class="d-flex justify-content-between align-items-start">
                    <div>
                        <div class="stat-value" id="kpi-done">-</div>
                        <div class="stat-label mt-1">Completed</div>
                    </div>
                    <div class="stat-icon" style="background:#D1FAE5; color:#059669;">
                        <i class="fas fa-check-circle"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-3 col-6">
            <div class="stat-card">
                <div class="d-flex justify-content-between align-items-start">
                    <div>
                        <div class="stat-value text-danger" id="kpi-overdue">-</div>
                        <div class="stat-label mt-1">Overdue</div>
                    </div>
                    <div class="stat-icon" style="background:#FEE2E2; color:#DC2626;">
                        <i class="fas fa-exclamation-triangle"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-4">
        <!-- Task Distribution Chart -->
        <div class="col-lg-5">
            <div class="card h-100">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <span><i class="fas fa-chart-doughnut me-2"></i>Task Distribution</span>
                </div>
                <div class="card-body d-flex align-items-center justify-content-center">
                    <canvas id="statusChart" style="max-height: 280px;"></canvas>
                </div>
            </div>
        </div>

        <!-- Project Summary -->
        <div class="col-lg-3">
            <div class="card h-100">
                <div class="card-header">
                    <i class="fas fa-folder-open me-2"></i>Projects
                </div>
                <div class="card-body" id="project-summary">
                    <div class="text-center text-muted py-4">
                        <i class="fas fa-spinner fa-spin"></i> Loading...
                    </div>
                </div>
            </div>
        </div>

        <!-- Recent Activity -->
        <div class="col-lg-4">
            <div class="card h-100">
                <div class="card-header">
                    <i class="fas fa-clock me-2"></i>Recent Activity
                </div>
                <div class="card-body p-0" style="max-height:360px; overflow-y:auto;" id="activity-feed">
                    <div class="text-center text-muted py-4">
                        <i class="fas fa-spinner fa-spin"></i> Loading...
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Priority Breakdown -->
    <div class="row g-3 mt-2">
        <div class="col-md-4">
            <div class="stat-card">
                <div class="d-flex align-items-center">
                    <div class="stat-icon me-3" style="background:#FEE2E2; color:#DC2626;">
                        <i class="fas fa-fire"></i>
                    </div>
                    <div>
                        <div class="stat-value fs-4" id="kpi-critical">-</div>
                        <div class="stat-label">Critical Priority</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stat-card">
                <div class="d-flex align-items-center">
                    <div class="stat-icon me-3" style="background:#FFEDD5; color:#9A3412;">
                        <i class="fas fa-arrow-up"></i>
                    </div>
                    <div>
                        <div class="stat-value fs-4" id="kpi-high">-</div>
                        <div class="stat-label">High Priority</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stat-card">
                <div class="d-flex align-items-center">
                    <div class="stat-icon me-3" style="background:#FEE2E2; color:#DC2626;">
                        <i class="fas fa-ban"></i>
                    </div>
                    <div>
                        <div class="stat-value fs-4" id="kpi-blocked">-</div>
                        <div class="stat-label">Blocked Tasks</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

</div>

<script>
$(document).ready(function() {
    var statusChart = null;

    // Recursively lowercase all keys in an object/array
    function lk(obj) {
        if (Array.isArray(obj)) return obj.map(lk);
        if (obj && typeof obj === 'object') {
            var out = {};
            Object.keys(obj).forEach(function(k) { out[k.toLowerCase()] = lk(obj[k]); });
            return out;
        }
        return obj;
    }

    TaskForge.apiGet('/api/dashboard.cfm').done(function(resp) {
        if (!resp.success) return;
        var d = lk(resp.data);

        // KPIs
        $('#kpi-total-tasks').text(d.tasks.total);
        $('#kpi-in-progress').text(d.tasks.in_progress);
        $('#kpi-done').text(d.tasks.done);
        $('#kpi-overdue').text(d.tasks.overdue);
        $('#kpi-critical').text(d.tasks.critical);
        $('#kpi-high').text(d.tasks.high_priority);
        $('#kpi-blocked').text(d.tasks.blocked);

        // Project summary
        var phtml = '<div class="mb-3">' +
            '<div class="d-flex justify-content-between mb-1"><span class="fw-semibold fs-3">' + d.projects.total + '</span><span class="text-muted-sm">Total</span></div>' +
            '</div>' +
            '<div class="d-flex justify-content-between py-2 border-bottom"><span><span class="badge badge-active me-1">&bull;</span> Active</span><strong>' + d.projects.active + '</strong></div>' +
            '<div class="d-flex justify-content-between py-2 border-bottom"><span><span class="badge badge-onhold me-1">&bull;</span> On Hold</span><strong>' + d.projects.on_hold + '</strong></div>' +
            '<div class="d-flex justify-content-between py-2"><span><span class="badge badge-completed me-1">&bull;</span> Completed</span><strong>' + d.projects.completed + '</strong></div>';
        $('#project-summary').html(phtml);

        // Chart
        var labels = [], values = [], colors = [];
        var colorMap = {
            'To Do': '#818CF8', 'In Progress': '#3B82F6', 'In Review': '#F59E0B',
            'Done': '#10B981', 'Blocked': '#EF4444'
        };
        (d.status_distribution || []).forEach(function(s) {
            labels.push(s.STATUS || s.status);
            values.push(s.CNT || s.cnt);
            colors.push(colorMap[s.STATUS || s.status] || '#94A3B8');
        });

        var ctx = document.getElementById('statusChart').getContext('2d');
        statusChart = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: labels,
                datasets: [{ data: values, backgroundColor: colors, borderWidth: 0, hoverOffset: 8 }]
            },
            options: {
                responsive: true,
                cutout: '65%',
                plugins: {
                    legend: { position: 'bottom', labels: { padding: 16, usePointStyle: true, pointStyle: 'circle' } }
                }
            }
        });

        // Activity feed
        var ahtml = '';
        var iconMap = {
            'status_change': '<i class="fas fa-exchange-alt"></i>',
            'created': '<i class="fas fa-plus"></i>',
            'updated': '<i class="fas fa-edit"></i>',
            'deleted': '<i class="fas fa-trash"></i>',
            'comment': '<i class="fas fa-comment"></i>'
        };
        var bgMap = {
            'status_change': 'background:#DBEAFE; color:#1D4ED8;',
            'created': 'background:#D1FAE5; color:#059669;',
            'updated': 'background:#FEF3C7; color:#92400E;',
            'deleted': 'background:#FEE2E2; color:#DC2626;',
            'comment': 'background:#EDE9FE; color:#7C3AED;'
        };
        (d.recent_activity || []).forEach(function(a) {
            var action = (a.ACTION || a.action);
            ahtml += '<div class="activity-item px-3">' +
                '<div class="activity-icon" style="' + (bgMap[action] || '') + '">' + (iconMap[action] || '<i class="fas fa-circle"></i>') + '</div>' +
                '<div><div class="activity-text">' + (a.DESCRIPTION || a.description) + '</div>' +
                '<div class="activity-time">' + (a.ACTOR_NAME || a.actor_name || 'System') + '</div></div></div>';
        });
        $('#activity-feed').html(ahtml || '<div class="text-center text-muted py-4">No recent activity</div>');
    });
});
</script>

</cf_main>
