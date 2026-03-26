<cf_main pageTitle="Personal Event" activePage="calendar">
<cfscript>
    // This page handles viewing a personal event by ID
    eventSvc = new model.EventService();
    eventId = url.id ?: 0;
    evt = eventSvc.getById(eventId);
</cfscript>

<div class="container" style="max-width:700px;">
    <cfif evt.recordCount>
        <cfoutput>
        <div class="polyculy-card card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h4 class="mb-0"><i class="fas fa-calendar me-2 text-purple"></i>#htmlEditFormat(evt.title)#</h4>
                <span class="badge badge-#evt.visibility_tier eq 'invisible' ? 'tentative' : 'active-event'#">
                    #evt.visibility_tier#
                </span>
            </div>
            <div class="card-body">
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label text-muted"><i class="fas fa-clock me-1"></i>Start</label>
                        <p>#dateFormat(evt.start_time, 'mmm dd, yyyy')# #timeFormat(evt.start_time, 'h:mm tt')#</p>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label text-muted"><i class="fas fa-clock me-1"></i>End</label>
                        <p>#dateFormat(evt.end_time, 'mmm dd, yyyy')# #timeFormat(evt.end_time, 'h:mm tt')#</p>
                    </div>
                    <cfif len(evt.address)>
                    <div class="col-12">
                        <label class="form-label text-muted"><i class="fas fa-map-marker-alt me-1"></i>Location</label>
                        <p>#htmlEditFormat(evt.address)#</p>
                    </div>
                    </cfif>
                    <cfif len(evt.event_details)>
                    <div class="col-12">
                        <label class="form-label text-muted"><i class="fas fa-info-circle me-1"></i>Details</label>
                        <p>#htmlEditFormat(evt.event_details)#</p>
                    </div>
                    </cfif>
                </div>

                <!-- Visibility Settings -->
                <hr>
                <h6 class="text-purple"><i class="fas fa-eye me-2"></i>Visibility</h6>
                <div id="eventVisibility">Loading...</div>
            </div>
            <div class="card-footer d-flex justify-content-between">
                <a href="/views/calendar/month.cfm" class="btn btn-polyculy-outline">
                    <i class="fas fa-arrow-left me-1"></i>Back
                </a>
                <div>
                    <button class="btn btn-polyculy-outline" onclick="Polyculy.editPersonalEvent(#evt.event_id#)">
                        <i class="fas fa-edit me-1"></i>Edit
                    </button>
                    <button class="btn btn-danger" onclick="if(confirm('Cancel this event?')) Polyculy.cancelPersonalEvent(#evt.event_id#)">
                        <i class="fas fa-times me-1"></i>Cancel
                    </button>
                </div>
            </div>
        </div>
        </cfoutput>
    <cfelse>
        <div class="empty-state">
            <i class="fas fa-calendar-times"></i>
            <h4>Event Not Found</h4>
            <a href="/views/calendar/month.cfm" class="btn btn-polyculy mt-2">Back to Calendar</a>
        </div>
    </cfif>
</div>

<cfif evt.recordCount>
<script>
$(function() {
    $.getJSON('/api/events.cfm?action=get&id=<cfoutput>#eventId#</cfoutput>', function(r) {
        var data = r.DATA || r.data || {};
        var vis = data.visibility || data.VISIBILITY || [];
        var html = '';
        if (vis.length === 0) {
            html = '<p class="text-muted">No one else can see this event.</p>';
        } else {
            vis.forEach(function(v) {
                var name = v.TARGET_NAME || v.target_name;
                var type = v.VISIBILITY_TYPE || v.visibility_type;
                var icon = type === 'full_details' ? 'fa-eye text-purple' : 'fa-eye-slash text-pink';
                html += '<div class="d-flex align-items-center gap-2 mb-2"><i class="fas ' + icon + '"></i> <strong>' + name + '</strong> — ' + type.replace('_', ' ') + '</div>';
            });
        }
        $('#eventVisibility').html(html);
    });
});
</script>
</cfif>

</cf_main>
