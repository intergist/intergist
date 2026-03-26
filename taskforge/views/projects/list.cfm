<cf_main pageTitle="Projects" activePage="projects">

<div class="page-header">
    <h1><i class="fas fa-folder-open me-2 text-primary"></i>Projects</h1>
    <button class="btn btn-primary" onclick="openProjectModal()">
        <i class="fas fa-plus me-1"></i> New Project
    </button>
</div>

<div class="page-body">

    <!-- Project Cards -->
    <div class="row g-4" id="project-grid">
        <div class="col-12 text-center text-muted py-5">
            <i class="fas fa-spinner fa-spin fa-2x"></i>
            <p class="mt-2">Loading projects...</p>
        </div>
    </div>

</div>

<!-- Project Modal -->
<div class="modal fade" id="projectModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="projectModalTitle">New Project</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form id="project-form">
                <div class="modal-body">
                    <input type="hidden" id="pf-project-id" name="project_id">
                    <div class="row g-3">
                        <div class="col-12">
                            <label class="form-label">Project Name <span class="text-danger">*</span></label>
                            <input type="text" id="pf-name" name="project_name" class="form-control" required>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Status</label>
                            <select id="pf-status" name="status" class="form-select">
                                <option selected>Active</option>
                                <option>On Hold</option>
                                <option>Completed</option>
                                <option>Archived</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Priority</label>
                            <select id="pf-priority" name="priority" class="form-select">
                                <option>Low</option>
                                <option selected>Medium</option>
                                <option>High</option>
                                <option>Critical</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Owner</label>
                            <select id="pf-owner" name="owner_id" class="chosen-select" data-placeholder="Select owner">
                                <option value=""></option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Start Date</label>
                            <input type="date" id="pf-start" name="start_date" class="form-control">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Due Date</label>
                            <input type="date" id="pf-due" name="due_date" class="form-control">
                        </div>
                        <div class="col-12">
                            <label class="form-label">Description</label>
                            <textarea id="pf-desc" name="description" class="form-control" rows="3"></textarea>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="fas fa-save me-1"></i> Save Project</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Delete Confirm Modal -->
<div class="modal fade" id="deleteProjectModal" tabindex="-1">
    <div class="modal-dialog modal-sm">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Confirm Delete</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">Delete this project and all its tasks?</div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-danger btn-sm" id="confirm-delete-project-btn">Delete</button>
            </div>
        </div>
    </div>
</div>

<script>
var members = [];

$(document).ready(function() {
    TaskForge.apiGet('/api/team.cfm', { action: 'active' }).done(function(resp) {
        members = TaskForge.lk(resp.data || []);
        members.forEach(function(m) {
            var name = m.first_name + ' ' + m.last_name;
            $('#pf-owner').append('<option value="' + m.member_id + '">' + name + '</option>');
        });
        $('.chosen-select').trigger('chosen:updated');
    });

    loadProjects();

    $('#project-form').on('submit', function(e) {
        e.preventDefault();
        TaskForge.apiPost('/api/projects.cfm?action=save', $(this).serialize()).done(function(resp) {
            if (resp.success) {
                bootstrap.Modal.getInstance(document.getElementById('projectModal')).hide();
                TaskForge.showToast(resp.message);
                loadProjects();
            } else {
                TaskForge.showToast(resp.message || 'Error', 'error');
            }
        });
    });
});

function loadProjects() {
    TaskForge.apiGet('/api/projects.cfm', { action: 'list' }).done(function(resp) {
        var html = '';
        TaskForge.lk(resp.data || []).forEach(function(p) {
            var name = p.project_name;
            var desc = p.description || '';
            var status = p.status;
            var priority = p.priority;
            var owner = p.owner_name || 'Unassigned';
            var id = p.project_id;
            var taskCount = p.task_count || 0;
            var doneCount = p.done_count || 0;
            var pct = taskCount > 0 ? Math.round((doneCount / taskCount) * 100) : 0;
            var due = p.due_date || '';

            html += '<div class="col-md-6 col-xl-4">' +
                '<div class="card hover-shadow h-100">' +
                '<div class="card-body">' +
                '<div class="d-flex justify-content-between align-items-start mb-2">' +
                '<h6 class="fw-bold mb-0">' + name + '</h6>' +
                '<div class="dropdown">' +
                '<button class="btn btn-sm btn-light" data-bs-toggle="dropdown"><i class="fas fa-ellipsis-v"></i></button>' +
                '<ul class="dropdown-menu dropdown-menu-end">' +
                '<li><a class="dropdown-item" href="javascript:void(0)" onclick="editProject(' + id + ')"><i class="fas fa-edit me-2"></i>Edit</a></li>' +
                '<li><a class="dropdown-item text-danger" href="javascript:void(0)" onclick="deleteProject(' + id + ')"><i class="fas fa-trash me-2"></i>Delete</a></li>' +
                '</ul></div></div>' +
                '<div class="mb-2">' + TaskForge.projectStatusBadge(status) + ' ' + TaskForge.priorityBadge(priority) + '</div>' +
                '<p class="text-muted-sm mb-3" style="line-height:1.4">' + (desc.length > 120 ? desc.substring(0,120) + '...' : desc) + '</p>' +
                '<div class="d-flex justify-content-between text-muted-sm mb-2">' +
                '<span><i class="fas fa-user me-1"></i>' + owner + '</span>' +
                '<span><i class="fas fa-calendar me-1"></i>' + TaskForge.formatDate(due) + '</span>' +
                '</div>' +
                '<div class="d-flex justify-content-between align-items-center">' +
                '<small class="text-muted-sm">' + doneCount + '/' + taskCount + ' tasks</small>' +
                '<small class="text-muted-sm">' + pct + '%</small>' +
                '</div>' +
                '<div class="progress mt-1"><div class="progress-bar" style="width:' + pct + '%; background:var(--tf-primary);"></div></div>' +
                '</div></div></div>';
        });
        $('#project-grid').html(html || '<div class="col-12 text-center text-muted py-5">No projects yet.</div>');
    });
}

function openProjectModal(data) {
    var form = document.getElementById('project-form');
    form.reset();
    if (data) {
        $('#projectModalTitle').text('Edit Project');
        $('#pf-project-id').val(data.project_id);
        $('#pf-name').val(data.project_name);
        $('#pf-status').val(data.status);
        $('#pf-priority').val(data.priority);
        $('#pf-owner').val(data.owner_id || '').trigger('chosen:updated');
        $('#pf-start').val(data.start_date ? data.start_date.substring(0, 10) : '');
        $('#pf-due').val(data.due_date ? data.due_date.substring(0, 10) : '');
        $('#pf-desc').val(data.description || '');
    } else {
        $('#projectModalTitle').text('New Project');
        $('#pf-project-id').val('');
        $('#pf-owner').val('').trigger('chosen:updated');
    }
    new bootstrap.Modal(document.getElementById('projectModal')).show();
}

function editProject(id) {
    TaskForge.apiGet('/api/projects.cfm', { action: 'get', id: id }).done(function(resp) {
        if (resp.success) {
            openProjectModal(TaskForge.lk(resp.data));
        }
    });
}

var deleteProjectId = null;
function deleteProject(id) {
    deleteProjectId = id;
    new bootstrap.Modal(document.getElementById('deleteProjectModal')).show();
}

$('#confirm-delete-project-btn').on('click', function() {
    if (deleteProjectId) {
        TaskForge.apiPost('/api/projects.cfm?action=delete', { project_id: deleteProjectId }).done(function(resp) {
            bootstrap.Modal.getInstance(document.getElementById('deleteProjectModal')).hide();
            TaskForge.showToast('Project deleted');
            loadProjects();
            deleteProjectId = null;
        });
    }
});
</script>

</cf_main>
