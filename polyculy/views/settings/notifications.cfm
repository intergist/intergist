<cf_main pageTitle="Notification Preferences" activePage="settings">

<div class="container" style="max-width:700px;">
    <h2 class="mb-4"><i class="fas fa-bell me-2"></i>Notification Preferences</h2>

    <div class="polyculy-card card">
        <div class="card-header d-flex justify-content-between align-items-center">
            <h5 class="mb-0">Notification Types</h5>
            <a href="/views/settings/timezone.cfm" class="btn btn-sm btn-polyculy-outline">
                <i class="fas fa-arrow-left me-1"></i>Back to Settings
            </a>
        </div>
        <div class="card-body">
            <p class="text-muted small mb-4">Control which notifications you receive and how they're delivered.</p>

            <div id="notifPrefList">
                <div class="text-center py-3"><i class="fas fa-spinner fa-spin text-purple"></i></div>
            </div>
        </div>
    </div>
</div>

<script>
$(function() {
    var types = [
        { type: 'connection_accepted', label: 'Connection Accepted', icon: 'fa-heart' },
        { type: 'connection_revoked', label: 'Connection Revoked', icon: 'fa-heart-broken' },
        { type: 'shared_event_invite', label: 'Shared Event Invitation', icon: 'fa-calendar-plus' },
        { type: 'event_accepted', label: 'Event Accepted', icon: 'fa-check-circle' },
        { type: 'event_declined', label: 'Event Declined', icon: 'fa-times-circle' },
        { type: 'event_material_change', label: 'Event Time/Location Changed', icon: 'fa-clock' },
        { type: 'event_cancelled', label: 'Event Cancelled', icon: 'fa-calendar-times' },
        { type: 'proposal_received', label: 'Time Proposal Received', icon: 'fa-calendar-check' },
        { type: 'proposal_accepted', label: 'Proposal Accepted', icon: 'fa-thumbs-up' },
        { type: 'proposal_rejected', label: 'Proposal Rejected', icon: 'fa-thumbs-down' },
        { type: 'ownership_transfer', label: 'Ownership Transfer Needed', icon: 'fa-crown' },
        { type: 'ownership_claimed', label: 'Ownership Claimed', icon: 'fa-hand-paper' },
        { type: 'licence_gifted', label: 'Licence Gifted', icon: 'fa-gift' }
    ];

    $.getJSON('/api/notifications.cfm?action=preferences', function(r) {
        var prefs = {};
        var data = r.DATA || r.data || [];
        data.forEach(function(p) {
            var nt = p.NOTIFICATION_TYPE || p.notification_type;
            prefs[nt] = {
                enabled: p.IS_ENABLED !== undefined ? p.IS_ENABLED : (p.is_enabled !== undefined ? p.is_enabled : true),
                mode: p.DELIVERY_MODE || p.delivery_mode || 'instant'
            };
        });

        var html = '<table class="table table-hover">';
        html += '<thead><tr><th>Notification</th><th class="text-center">Enabled</th><th>Delivery</th></tr></thead><tbody>';
        types.forEach(function(t) {
            var p = prefs[t.type] || { enabled: true, mode: 'instant' };
            var checked = p.enabled ? 'checked' : '';
            html += '<tr>';
            html += '<td><i class="fas ' + t.icon + ' me-2 text-purple"></i>' + t.label + '</td>';
            html += '<td class="text-center"><div class="form-check form-switch d-flex justify-content-center"><input class="form-check-input" type="checkbox" ' + checked + ' onchange="Polyculy.updateNotifPref(\'' + t.type + '\', this.checked, $(this).closest(\'tr\').find(\'select\').val())"></div></td>';
            html += '<td><select class="form-select form-select-sm" style="width:120px;" onchange="Polyculy.updateNotifPref(\'' + t.type + '\', $(this).closest(\'tr\').find(\'input[type=checkbox]\').prop(\'checked\'), this.value)">';
            html += '<option value="instant"' + (p.mode === 'instant' ? ' selected' : '') + '>Instant</option>';
            html += '<option value="digest"' + (p.mode === 'digest' ? ' selected' : '') + '>Digest</option>';
            html += '</select></td>';
            html += '</tr>';
        });
        html += '</tbody></table>';
        $('#notifPrefList').html(html);
    });
});
</script>

</cf_main>
