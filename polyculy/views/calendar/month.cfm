<cf_main pageTitle="My Calendar" activePage="calendar">

<div class="container-fluid">
    <div class="row">
        <div class="col-lg-9">
            <!-- Calendar Header -->
            <div class="calendar-container mb-3">
                <div class="calendar-header">
                    <div class="d-flex align-items-center gap-3">
                        <button class="calendar-nav-btn" onclick="Polyculy.calNavPrev()">
                            <i class="fas fa-chevron-left"></i>
                        </button>
                        <h3 id="calTitle">March 2026</h3>
                        <button class="calendar-nav-btn" onclick="Polyculy.calNavNext()">
                            <i class="fas fa-chevron-right"></i>
                        </button>
                        <button class="btn btn-sm btn-polyculy-outline" onclick="Polyculy.calToday()">Today</button>
                    </div>
                    <div class="d-flex align-items-center gap-3">
                        <div class="mine-our-toggle">
                            <button class="toggle-btn active" id="toggleMine" onclick="Polyculy.setCalMode('mine')">Mine</button>
                            <button class="toggle-btn" id="toggleOur" onclick="Polyculy.setCalMode('our')">Our</button>
                        </div>
                        <div class="btn-group btn-group-sm">
                            <a href="/views/calendar/month.cfm" class="btn btn-polyculy btn-sm">Month</a>
                            <a href="/views/calendar/week.cfm" class="btn btn-polyculy-outline btn-sm">Week</a>
                            <a href="/views/calendar/day.cfm" class="btn btn-polyculy-outline btn-sm">Day</a>
                        </div>
                    </div>
                </div>

                <!-- Month Grid -->
                <div class="month-grid" id="monthGrid">
                    <div class="day-header">Sun</div>
                    <div class="day-header">Mon</div>
                    <div class="day-header">Tue</div>
                    <div class="day-header">Wed</div>
                    <div class="day-header">Thu</div>
                    <div class="day-header">Fri</div>
                    <div class="day-header">Sat</div>
                    <!-- Days populated by JS -->
                </div>
            </div>
        </div>

        <!-- Right sidebar: Quick Actions + Upcoming -->
        <div class="col-lg-3">
            <div class="polyculy-card card mb-3">
                <div class="card-body">
                    <button class="btn btn-polyculy w-100 mb-2" onclick="Polyculy.showPersonalEventModal()">
                        <i class="fas fa-plus me-1"></i>Personal Event
                    </button>
                    <button class="btn btn-polyculy-pink w-100" onclick="Polyculy.showSharedEventModal()">
                        <i class="fas fa-users me-1"></i>Shared Event
                    </button>
                </div>
            </div>

            <div class="polycule-sidebar mb-3">
                <h5>Upcoming Events</h5>
                <div id="upcomingEvents">
                    <div class="text-muted small text-center py-2">Loading...</div>
                </div>
            </div>

            <!-- Polycule Members -->
            <div class="polycule-sidebar" id="calSidebar">
                <h5>Your Polycule</h5>
                <div id="calMembersList"></div>
            </div>
        </div>
    </div>
</div>

<!-- Bottom Filter Bar (Our mode) -->
<div class="filter-bar" id="filterBar">
    <span class="small text-muted me-2"><i class="fas fa-filter me-1"></i>Show:</span>
    <div id="filterPills"></div>
</div>

<!-- Personal Event Modal -->
<div class="modal fade" id="personalEventModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-calendar-plus me-2"></i>Personal Event</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <form id="personalEventForm">
                    <input type="hidden" id="pe_event_id">
                    <div class="row g-3">
                        <div class="col-12">
                            <label class="form-label">Title</label>
                            <input type="text" class="form-control" id="pe_title" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Start</label>
                            <input type="datetime-local" class="form-control" id="pe_start_time" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">End</label>
                            <input type="datetime-local" class="form-control" id="pe_end_time" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Address</label>
                            <input type="text" class="form-control" id="pe_address" placeholder="Optional">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Reminder</label>
                            <select class="form-select" id="pe_reminder">
                                <option value="">None</option>
                                <option value="15">15 minutes before</option>
                                <option value="30">30 minutes before</option>
                                <option value="60">1 hour before</option>
                                <option value="1440">1 day before</option>
                            </select>
                        </div>
                        <div class="col-12">
                            <label class="form-label">Details</label>
                            <textarea class="form-control" id="pe_details" rows="3"></textarea>
                        </div>
                        <div class="col-12">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" id="pe_all_day">
                                <label class="form-check-label" for="pe_all_day">All Day Event</label>
                            </div>
                        </div>
                        <!-- Visibility -->
                        <div class="col-12">
                            <hr>
                            <h6 class="text-purple"><i class="fas fa-eye me-2"></i>Sharing & Visibility</h6>
                            <div class="mb-3">
                                <label class="form-label">Visibility Tier</label>
                                <select class="form-select" id="pe_visibility_tier" onchange="Polyculy.onVisibilityTierChange()">
                                    <option value="invisible">Invisible (only I can see)</option>
                                    <option value="full_details">Full Details (selected people see everything)</option>
                                    <option value="mixed">Mixed (some see details, some see busy block)</option>
                                </select>
                            </div>
                            <div id="visibilityOptions" style="display:none;">
                                <div class="mb-3" id="fullDetailsGroup">
                                    <label class="form-label">Show Full Details To:</label>
                                    <div id="fullDetailsPeople"></div>
                                </div>
                                <div class="mb-3" id="busyBlockGroup" style="display:none;">
                                    <label class="form-label">Show as Busy Block To:</label>
                                    <div id="busyBlockPeople"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-polyculy-outline" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-polyculy" onclick="Polyculy.savePersonalEvent()">
                    <i class="fas fa-save me-1"></i>Save Event
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Shared Event Modal -->
<div class="modal fade" id="sharedEventModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-users me-2"></i>Shared Event</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <form id="sharedEventForm">
                    <input type="hidden" id="se_event_id">
                    <!-- Step 1: Details -->
                    <div id="seStep1">
                        <div class="row g-3">
                            <div class="col-12">
                                <label class="form-label">Event Title</label>
                                <input type="text" class="form-control" id="se_title" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Start</label>
                                <input type="datetime-local" class="form-control" id="se_start_time" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">End</label>
                                <input type="datetime-local" class="form-control" id="se_end_time" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Address</label>
                                <input type="text" class="form-control" id="se_address">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Participant Visibility</label>
                                <select class="form-select" id="se_participant_visibility">
                                    <option value="visible">Participants can see each other</option>
                                    <option value="hidden">Participants are hidden from each other</option>
                                </select>
                            </div>
                            <div class="col-12">
                                <label class="form-label">Details</label>
                                <textarea class="form-control" id="se_details" rows="3"></textarea>
                            </div>
                        </div>
                        <div class="text-end mt-3">
                            <button type="button" class="btn btn-polyculy" onclick="Polyculy.sharedEventStep2()">
                                Next: Invite Others <i class="fas fa-arrow-right ms-1"></i>
                            </button>
                        </div>
                    </div>
                    <!-- Step 2: Invite Participants -->
                    <div id="seStep2" style="display:none;">
                        <h6 class="text-purple mb-3"><i class="fas fa-user-plus me-2"></i>Invite Participants</h6>
                        <div id="seConflictWarning" class="alert alert-warning d-none">
                            <i class="fas fa-exclamation-triangle me-1"></i>
                            <span id="seConflictMsg"></span>
                        </div>
                        <div id="seParticipantList"></div>
                        <div class="d-flex justify-content-between mt-3">
                            <button type="button" class="btn btn-polyculy-outline" onclick="$('#seStep2').hide();$('#seStep1').show();">
                                <i class="fas fa-arrow-left me-1"></i>Back
                            </button>
                            <button type="button" class="btn btn-polyculy" onclick="Polyculy.saveSharedEvent()">
                                <i class="fas fa-paper-plane me-1"></i>Send Invitations
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- Event Detail Modal -->
<div class="modal fade" id="eventDetailModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="edTitle"></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" id="edBody"></div>
            <div class="modal-footer" id="edFooter"></div>
        </div>
    </div>
</div>

<script>
$(function() {
    Polyculy.initCalendar('month');
});
</script>

</cf_main>
