<cf_main pageTitle="Team" activePage="team">

<div class="page-header">
    <h1><i class="fas fa-users me-2 text-primary"></i>Team</h1>
    <button class="btn btn-primary" onclick="openMemberModal()">
        <i class="fas fa-user-plus me-1"></i> Add Member
    </button>
</div>

<div class="page-body">

    <div class="card">
        <div class="card-body">
            <table id="team-table" class="table table-hover" style="width:100%">
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Role</th>
                        <th>Status</th>
                        <th style="width:100px">Actions</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </div>
</div>

<!-- Member Modal -->
<div class="modal fade" id="memberModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="memberModalTitle">Add Member</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form id="member-form">
                <div class="modal-body">
                    <input type="hidden" id="mf-id" name="member_id">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label">First Name <span class="text-danger">*</span></label>
                            <input type="text" id="mf-fname" name="first_name" class="form-control" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Last Name <span class="text-danger">*</span></label>
                            <input type="text" id="mf-lname" name="last_name" class="form-control" required>
                        </div>
                        <div class="col-12">
                            <label class="form-label">Email <span class="text-danger">*</span></label>
                            <input type="email" id="mf-email" name="email" class="form-control" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Role</label>
                            <select id="mf-role" name="role" class="form-select">
                                <option>Developer</option>
                                <option>Senior Developer</option>
                                <option>Project Lead</option>
                                <option>QA Engineer</option>
                                <option>Designer</option>
                                <option>DevOps Engineer</option>
                                <option>Product Manager</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Avatar Color</label>
                            <input type="color" id="mf-color" name="avatar_color" class="form-control form-control-color" value="#4F46E5">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Active</label>
                            <select id="mf-active" name="is_active" class="form-select">
                                <option value="true" selected>Yes</option>
                                <option value="false">No</option>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="fas fa-save me-1"></i> Save</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Delete Confirm -->
<div class="modal fade" id="deleteMemberModal" tabindex="-1">
    <div class="modal-dialog modal-sm">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Confirm Delete</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">Remove this team member?</div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-danger btn-sm" id="confirm-delete-member-btn">Delete</button>
            </div>
        </div>
    </div>
</div>

<script>
var teamTable;

$(document).ready(function() {
    teamTable = $('#team-table').DataTable({
        pageLength: 25,
        order: [[0, 'asc']],
        language: { emptyTable: 'No team members', search: '_INPUT_', searchPlaceholder: 'Search team...' },
        dom: '<"d-flex justify-content-between align-items-center mb-3"lf>rtip'
    });

    loadTeam();

    $('#member-form').on('submit', function(e) {
        e.preventDefault();
        TaskForge.apiPost('/api/team.cfm?action=save', $(this).serialize()).done(function(resp) {
            if (resp.success) {
                bootstrap.Modal.getInstance(document.getElementById('memberModal')).hide();
                TaskForge.showToast(resp.message);
                loadTeam();
            } else {
                TaskForge.showToast(resp.message || 'Error', 'error');
            }
        });
    });
});

function loadTeam() {
    TaskForge.apiGet('/api/team.cfm', { action: 'list' }).done(function(resp) {
        teamTable.clear();
        TaskForge.lk(resp.data || []).forEach(function(m) {
            var fullName = m.first_name + ' ' + m.last_name;
            var email = m.email;
            var role = m.role;
            var color = m.avatar_color || '#4F46E5';
            var active = m.is_active;
            var id = m.member_id;

            var nameHtml = '<div class="d-flex align-items-center gap-2">' +
                TaskForge.avatarHtml(fullName, color, 'md') +
                '<div><strong>' + fullName + '</strong></div></div>';

            var statusHtml = active ?
                '<span class="badge badge-status badge-active">Active</span>' :
                '<span class="badge badge-status badge-archived">Inactive</span>';

            var actions = '<div class="btn-group btn-group-sm">' +
                '<button class="btn btn-outline-primary" onclick="editMember(' + id + ')"><i class="fas fa-edit"></i></button>' +
                '<button class="btn btn-outline-danger" onclick="deleteMember(' + id + ')"><i class="fas fa-trash"></i></button></div>';

            teamTable.row.add([nameHtml, email, role, statusHtml, actions]);
        });
        teamTable.draw();
    });
}

function openMemberModal(data) {
    var form = document.getElementById('member-form');
    form.reset();
    if (data) {
        $('#memberModalTitle').text('Edit Member');
        $('#mf-id').val(data.member_id);
        $('#mf-fname').val(data.first_name);
        $('#mf-lname').val(data.last_name);
        $('#mf-email').val(data.email);
        $('#mf-role').val(data.role);
        $('#mf-color').val(data.avatar_color);
        $('#mf-active').val(data.is_active ? 'true' : 'false');
    } else {
        $('#memberModalTitle').text('Add Member');
        $('#mf-id').val('');
    }
    new bootstrap.Modal(document.getElementById('memberModal')).show();
}

function editMember(id) {
    TaskForge.apiGet('/api/team.cfm', { action: 'get', id: id }).done(function(resp) {
        if (resp.success) {
            openMemberModal(TaskForge.lk(resp.data));
        }
    });
}

var deleteMemberId = null;
function deleteMember(id) {
    deleteMemberId = id;
    new bootstrap.Modal(document.getElementById('deleteMemberModal')).show();
}

$('#confirm-delete-member-btn').on('click', function() {
    if (deleteMemberId) {
        TaskForge.apiPost('/api/team.cfm?action=delete', { member_id: deleteMemberId }).done(function(resp) {
            bootstrap.Modal.getInstance(document.getElementById('deleteMemberModal')).hide();
            TaskForge.showToast('Member removed');
            loadTeam();
            deleteMemberId = null;
        });
    }
});
</script>

</cf_main>
