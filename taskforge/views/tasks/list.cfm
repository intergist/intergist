<cf_main pageTitle="Tasks" activePage="tasks">

<div class="page-header">
    <h1><i class="fas fa-tasks me-2 text-primary"></i>Tasks</h1>
    <button class="btn btn-primary" onclick="openTaskModal()">
        <i class="fas fa-plus me-1"></i> New Task
    </button>
</div>

<div class="page-body">

    <!-- Filters -->
    <div class="card mb-4">
        <div class="card-body py-3">
            <form class="row g-2 align-items-end" id="filter-form">
                <div class="col-md-3">
                    <label class="form-label text-muted-sm">Project</label>
                    <select id="filter-project" class="chosen-select" data-placeholder="All Projects">
                        <option value=""></option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label text-muted-sm">Status</label>
                    <select id="filter-status" class="chosen-select" data-placeholder="All Statuses">
                        <option value=""></option>
                        <option>To Do</option>
                        <option>In Progress</option>
                        <option>In Review</option>
                        <option>Done</option>
                        <option>Blocked</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label text-muted-sm">Assignee</label>
                    <select id="filter-assignee" class="chosen-select" data-placeholder="All Members">
                        <option value=""></option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label text-muted-sm">Priority</label>
                    <select id="filter-priority" class="chosen-select" data-placeholder="All Priorities">
                        <option value=""></option>
                        <option>Low</option>
                        <option>Medium</option>
                        <option>High</option>
                        <option>Critical</option>
                    </select>
                </div>
                <div class="col-md-3 d-flex gap-2">
                    <button type="button" class="btn btn-primary" onclick="loadTasks()">
                        <i class="fas fa-filter me-1"></i> Filter
                    </button>
                    <button type="button" class="btn btn-outline-secondary" onclick="clearFilters()">
                        <i class="fas fa-times me-1"></i> Clear
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Tasks Table -->
    <div class="card">
        <div class="card-body">
            <table id="tasks-table" class="table table-hover" style="width:100%">
                <thead>
                    <tr>
                        <th>Title</th>
                        <th>Project</th>
                        <th>Status</th>
                        <th>Priority</th>
                        <th>Assignee</th>
                        <th>Due Date</th>
                        <th style="width:100px">Actions</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </div>
</div>

<!-- Task Modal -->
<div class="modal fade" id="taskModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="taskModalTitle">New Task</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form id="task-form">
                <div class="modal-body">
                    <input type="hidden" id="f-task-id" name="task_id">
                    <div class="row g-3">
                        <div class="col-12">
                            <label class="form-label">Title <span class="text-danger">*</span></label>
                            <input type="text" id="f-title" name="title" class="form-control" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Project <span class="text-danger">*</span></label>
                            <select id="f-project" name="project_id" class="chosen-select" required data-placeholder="Select project">
                                <option value=""></option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Assigned To</label>
                            <select id="f-assignee" name="assigned_to" class="chosen-select" data-placeholder="Unassigned">
                                <option value=""></option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Status</label>
                            <select id="f-status" name="status" class="form-select">
                                <option>To Do</option>
                                <option>In Progress</option>
                                <option>In Review</option>
                                <option>Done</option>
                                <option>Blocked</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Priority</label>
                            <select id="f-priority" name="priority" class="form-select">
                                <option>Low</option>
                                <option selected>Medium</option>
                                <option>High</option>
                                <option>Critical</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Due Date</label>
                            <input type="date" id="f-due-date" name="due_date" class="form-control">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Estimated Hours</label>
                            <input type="number" id="f-est-hours" name="estimated_hours" class="form-control" step="0.5" min="0">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Actual Hours</label>
                            <input type="number" id="f-act-hours" name="actual_hours" class="form-control" step="0.5" min="0">
                        </div>
                        <div class="col-12">
                            <label class="form-label">Description</label>
                            <textarea id="f-description" name="description" class="form-control" rows="3"></textarea>
                        </div>
                        <div class="col-12">
                            <label class="form-label">Tags <small class="text-muted">(comma-separated)</small></label>
                            <input type="text" id="f-tags" name="tags" class="form-control" placeholder="e.g. api, backend, urgent">
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="fas fa-save me-1"></i> Save Task</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Delete Confirm Modal -->
<div class="modal fade" id="deleteModal" tabindex="-1">
    <div class="modal-dialog modal-sm">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Confirm Delete</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">Are you sure you want to delete this task?</div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-danger btn-sm" id="confirm-delete-btn">Delete</button>
            </div>
        </div>
    </div>
</div>

<script>
var tasksTable;
var projects = [], members = [];

$(document).ready(function() {
    // Load lookup data
    $.when(
        TaskForge.apiGet('/api/projects.cfm', { action: 'list' }),
        TaskForge.apiGet('/api/team.cfm', { action: 'active' })
    ).done(function(projResp, memResp) {
        projects = TaskForge.lk(projResp[0].data || []);
        members = TaskForge.lk(memResp[0].data || []);

        // Populate filter dropdowns
        projects.forEach(function(p) {
            $('#filter-project, #f-project').append('<option value="' + p.project_id + '">' + p.project_name + '</option>');
        });
        members.forEach(function(m) {
            var name = m.first_name + ' ' + m.last_name;
            $('#filter-assignee, #f-assignee').append('<option value="' + m.member_id + '">' + name + '</option>');
        });

        // Re-init Chosen after populating
        $('.chosen-select').trigger('chosen:updated');

        // Init DataTable
        tasksTable = $('#tasks-table').DataTable({
            pageLength: 25,
            order: [],
            language: { emptyTable: 'No tasks found', search: '_INPUT_', searchPlaceholder: 'Search tasks...' },
            dom: '<"d-flex justify-content-between align-items-center mb-3"lf>rtip'
        });

        loadTasks();
    });

    // Form submit
    $('#task-form').on('submit', function(e) {
        e.preventDefault();
        var formData = $(this).serialize();
        TaskForge.apiPost('/api/tasks.cfm?action=save', formData).done(function(resp) {
            if (resp.success) {
                bootstrap.Modal.getInstance(document.getElementById('taskModal')).hide();
                TaskForge.showToast(resp.message);
                loadTasks();
            } else {
                TaskForge.showToast(resp.message || 'Error saving task', 'error');
            }
        });
    });
});

function loadTasks() {
    var params = {
        action: 'list',
        project_id: $('#filter-project').val() || '',
        status: $('#filter-status').val() || '',
        assigned_to: $('#filter-assignee').val() || '',
        priority: $('#filter-priority').val() || ''
    };

    TaskForge.apiGet('/api/tasks.cfm', params).done(function(resp) {
        tasksTable.clear();
        TaskForge.lk(resp.data || []).forEach(function(t) {
            var title = t.title;
            var project = t.project_name;
            var status = t.status;
            var priority = t.priority;
            var assignee = t.assignee_name || '';
            var color = t.assignee_color || '#4F46E5';
            var due = t.due_date || '';
            var id = t.task_id;
            var tags = t.tags || '';

            var titleHtml = '<div><strong>' + title + '</strong></div>';
            if (tags) titleHtml += '<div class="mt-1">' + TaskForge.tagsHtml(tags) + '</div>';

            var assigneeHtml = assignee ? TaskForge.avatarHtml(assignee, color) + ' <span class="ms-1">' + assignee + '</span>' : '<span class="text-muted">Unassigned</span>';

            var actions = '<div class="btn-group btn-group-sm">' +
                '<button class="btn btn-outline-primary" onclick="editTask(' + id + ')" title="Edit"><i class="fas fa-edit"></i></button>' +
                '<button class="btn btn-outline-danger" onclick="deleteTask(' + id + ')" title="Delete"><i class="fas fa-trash"></i></button></div>';

            tasksTable.row.add([titleHtml, project, TaskForge.statusBadge(status), TaskForge.priorityBadge(priority), assigneeHtml, TaskForge.formatDate(due), actions]);
        });
        tasksTable.draw();
    });
}

function clearFilters() {
    $('#filter-project, #filter-status, #filter-assignee, #filter-priority').val('').trigger('chosen:updated');
    loadTasks();
}

function openTaskModal(data) {
    var form = document.getElementById('task-form');
    form.reset();
    if (data) {
        $('#taskModalTitle').text('Edit Task');
        $('#f-task-id').val(data.task_id);
        $('#f-title').val(data.title);
        $('#f-project').val(data.project_id).trigger('chosen:updated');
        $('#f-assignee').val(data.assigned_to || '').trigger('chosen:updated');
        $('#f-status').val(data.status);
        $('#f-priority').val(data.priority);
        $('#f-due-date').val(data.due_date ? data.due_date.substring(0, 10) : '');
        $('#f-est-hours').val(data.estimated_hours || '');
        $('#f-act-hours').val(data.actual_hours || '');
        $('#f-description').val(data.description || '');
        $('#f-tags').val(data.tags || '');
    } else {
        $('#taskModalTitle').text('New Task');
        $('#f-task-id').val('');
        $('#f-project, #f-assignee').val('').trigger('chosen:updated');
    }
    new bootstrap.Modal(document.getElementById('taskModal')).show();
}

function editTask(id) {
    TaskForge.apiGet('/api/tasks.cfm', { action: 'get', id: id }).done(function(resp) {
        if (resp.success) {
            openTaskModal(TaskForge.lk(resp.data));
        }
    });
}

var deleteId = null;
function deleteTask(id) {
    deleteId = id;
    new bootstrap.Modal(document.getElementById('deleteModal')).show();
}

$('#confirm-delete-btn').on('click', function() {
    if (deleteId) {
        TaskForge.apiPost('/api/tasks.cfm?action=delete', { task_id: deleteId }).done(function(resp) {
            bootstrap.Modal.getInstance(document.getElementById('deleteModal')).hide();
            TaskForge.showToast('Task deleted');
            loadTasks();
            deleteId = null;
        });
    }
});
</script>

</cf_main>
