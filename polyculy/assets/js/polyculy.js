/**
 * Polyculy — Privacy-first, relationship-aware scheduling
 * Main client-side application logic
 */
var Polyculy = (function($) {
    'use strict';

    // ── State ──
    var calState = {
        currentDate: new Date(),
        viewType: 'month',
        mode: 'mine',           // 'mine' or 'our'
        enabledUserIds: [],
        memberColors: {}
    };

    var memberPool = [
        '#22C55E', '#3B82F6', '#F59E0B', '#A855F7',
        '#EC4899', '#14B8A6', '#F97316', '#6366F1'
    ];

    // ── Helpers ──
    function lk(obj) {
        if (!obj) return obj;
        var out = {};
        for (var k in obj) {
            if (obj.hasOwnProperty(k)) {
                out[k.toLowerCase()] = obj[k];
            }
        }
        return out;
    }

    function toast(msg, type) {
        var $t = $('#appToast');
        $t.removeClass('bg-success bg-danger bg-warning bg-info').addClass('bg-' + (type || 'success'));
        $('#toastMessage').text(msg);
        var t = new bootstrap.Toast($t[0], { delay: 3000 });
        t.show();
    }

    function formatDate(d) {
        var m = d.getMonth() + 1;
        var day = d.getDate();
        return d.getFullYear() + '-' + (m < 10 ? '0' + m : m) + '-' + (day < 10 ? '0' + day : day);
    }

    function formatDateTime(d) {
        return formatDate(d) + 'T' + (d.getHours() < 10 ? '0' + d.getHours() : d.getHours()) +
            ':' + (d.getMinutes() < 10 ? '0' + d.getMinutes() : d.getMinutes());
    }

    function parseDate(str) {
        if (!str) return new Date();
        // Handle various date formats from server
        if (typeof str === 'object' && str.getTime) return str;
        var d = new Date(str);
        if (isNaN(d.getTime())) {
            // Try parsing "March 25, 2026 14:00:00" style
            d = new Date(str.replace(/\{ts '(.*)'\}/, '$1'));
        }
        return isNaN(d.getTime()) ? new Date() : d;
    }

    var monthNames = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    var dayNames = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];

    // ── Notifications ──
    function loadNotifications() {
        $.getJSON('/api/notifications.cfm?action=list', function(r) {
            var data = r.DATA || r.data || [];
            var count = r.UNREAD_COUNT || r.unread_count || 0;
            if (count > 0) {
                $('#notifCount').text(count).show();
            } else {
                $('#notifCount').hide();
            }

            var html = '';
            if (data.length === 0) {
                html = '<div class="text-center text-muted py-3"><small>No notifications</small></div>';
            } else {
                data.slice(0, 20).forEach(function(n) {
                    n = lk(n);
                    var unread = !n.is_read;
                    html += '<a href="#" class="dropdown-item py-2' + (unread ? ' bg-purple-light' : '') + '" onclick="Polyculy.readNotif(' + n.notification_id + '); return false;">';
                    html += '<div class="fw-semibold small">' + (n.title || '') + '</div>';
                    html += '<div class="text-muted" style="font-size:0.75rem;">' + (n.message || '') + '</div>';
                    html += '</a>';
                });
            }
            $('#notifList').html(html);
        });
    }

    function readNotif(nid) {
        $.post('/api/notifications.cfm?action=markRead', { notification_id: nid }, function() {
            loadNotifications();
        });
    }

    function markAllNotifRead() {
        $.post('/api/notifications.cfm?action=markAllRead', {}, function() {
            loadNotifications();
            toast('All notifications marked as read');
        });
    }

    // ── Auth ──
    function logout() {
        $.post('/api/auth.cfm?action=logout', {}, function() {
            window.location.href = '/index.cfm';
        });
    }

    // ── Connections ──
    function loadConnections() {
        $.getJSON('/api/connections.cfm?action=list', function(r) {
            var data = r.DATA || r.data || [];
            var html = '';
            if (data.length === 0) {
                html = '<div class="text-muted text-center py-3"><i class="fas fa-heart"></i><p class="mt-1 small">No connections yet</p></div>';
            } else {
                data.forEach(function(c) {
                    c = lk(c);
                    var name = c.nickname || c.other_display_name || c.invited_display_name || c.invited_email || 'Unknown';
                    var status = c.status || 'unknown';
                    var color = c.calendar_color || '#7C3AED';
                    var initial = name.charAt(0).toUpperCase();

                    html += '<div class="polycule-member" data-connection-id="' + c.connection_id + '">';
                    html += '<div class="member-avatar" style="background:' + color + ';">' + initial + '</div>';
                    html += '<div class="member-name">' + name + '</div>';
                    html += '<span class="status-badge status-' + status + '"><span class="status-dot"></span>' + status.replace(/_/g, ' ') + '</span>';
                    html += '</div>';

                    // Context menu actions
                    if (status === 'awaiting_confirmation' && c.initiated_by !== c.user_id_1) {
                        // Could be a pending request from them
                    }
                    if (status === 'connected') {
                        html += '<div class="ps-5 mb-2">';
                        html += '<a href="/views/connections/revoke-review.cfm?connection_id=' + c.connection_id + '" class="btn btn-sm btn-outline-danger"><i class="fas fa-heart-broken me-1"></i>Revoke</a>';
                        html += '</div>';
                    }
                });
            }
            $('#connectionsList').html(html);
        });
    }

    function loadPendingRequests() {
        $.getJSON('/api/connections.cfm?action=pending', function(r) {
            var data = r.DATA || r.data || [];
            if (data.length === 0) {
                $('#pendingSection').hide();
                return;
            }
            $('#pendingSection').show();
            var html = '';
            data.forEach(function(c) {
                c = lk(c);
                html += '<div class="d-flex justify-content-between align-items-center mb-2 p-2 bg-purple-light rounded">';
                html += '<div><strong>' + (c.from_display_name || c.from_email) + '</strong> wants to connect</div>';
                html += '<div>';
                html += '<button class="btn btn-sm btn-success me-1" onclick="Polyculy.acceptConnection(' + c.connection_id + ')"><i class="fas fa-check"></i></button>';
                html += '</div>';
                html += '</div>';
            });
            $('#pendingList').html(html);
        });
    }

    function sendInvite() {
        $('#inviteError').addClass('d-none');
        $.ajax({
            url: '/api/connections.cfm?action=invite',
            method: 'POST',
            data: { email: $('#inviteEmail').val(), display_name: $('#inviteDisplayName').val() },
            dataType: 'json',
            success: function(r) {
                if (r.SUCCESS || r.success) {
                    var data = r.DATA || r.data || {};
                    var status = data.STATUS || data.status || 'awaiting_signup';
                    window.location.href = '/views/connections/results.cfm?status=' + status + '&email=' + encodeURIComponent($('#inviteEmail').val());
                } else {
                    $('#inviteError').removeClass('d-none').text(r.MESSAGE || r.message);
                }
            }
        });
        return false;
    }

    function acceptConnection(connId) {
        $.post('/api/connections.cfm?action=accept', { connection_id: connId }, function(r) {
            toast('Connection accepted!');
            loadConnections();
            loadPendingRequests();
        }, 'json');
    }

    function loadAvailableLicences() {
        $.getJSON('/api/licences.cfm?action=available', function(r) {
            var data = r.DATA || r.data || [];
            var $sel = $('#giftLicenceCode');
            data.forEach(function(lic) {
                lic = lk(lic);
                $sel.append('<option value="' + lic.licence_code + '">' + lic.licence_code + ' (' + lic.licence_type + ')</option>');
            });
        });
    }

    function giftLicence() {
        var code = $('#giftLicenceCode').val();
        var email = $('#giftEmail').val();
        if (!code || !email) { toast('Please fill all fields', 'warning'); return false; }
        $.post('/api/licences.cfm?action=gift', { licence_code: code, to_email: email }, function(r) {
            if (r.SUCCESS || r.success) {
                toast('Licence gifted!');
                $('#giftEmail').val('');
            } else {
                toast(r.MESSAGE || r.message, 'danger');
            }
        }, 'json');
        return false;
    }

    function confirmRevocation() {
        var connId = new URLSearchParams(window.location.search).get('connection_id');
        var decisions = [];
        $('[data-event-id]').each(function() {
            decisions.push({ event_id: $(this).data('event-id'), action: $(this).val() });
        });
        $.ajax({
            url: '/api/connections.cfm?action=revoke',
            method: 'POST',
            data: { connection_id: connId },
            dataType: 'json',
            success: function(r) {
                toast('Connection revoked');
                setTimeout(function() { window.location.href = '/views/connections/connect.cfm'; }, 1000);
            }
        });
    }

    // ── Calendar ──
    function initCalendar(viewType) {
        calState.viewType = viewType;
        calState.currentDate = new Date();
        loadMembers();
        renderCalendar();
        loadNotifications();
        setInterval(loadNotifications, 30000);
    }

    function loadMembers() {
        $.getJSON('/api/calendar.cfm?action=getMembers', function(r) {
            var data = r.DATA || r.data || [];
            calState.enabledUserIds = [];
            var pillsHtml = '';
            data.forEach(function(m, i) {
                m = lk(m);
                var color = m.calendar_color || memberPool[i % memberPool.length];
                calState.memberColors[m.user_id] = color;
                calState.enabledUserIds.push(m.user_id);

                pillsHtml += '<div class="filter-pill active" data-user-id="' + m.user_id + '" onclick="Polyculy.toggleMember(this)" style="border-color:' + color + ';">';
                pillsHtml += '<span class="pill-dot" style="background:' + color + ';"></span>';
                pillsHtml += m.display_name;
                pillsHtml += '</div>';
            });
            $('#filterPills').html(pillsHtml);

            // Sidebar members
            var sideHtml = '';
            data.forEach(function(m) {
                m = lk(m);
                var color = calState.memberColors[m.user_id] || '#7C3AED';
                sideHtml += '<div class="polycule-member">';
                sideHtml += '<div class="member-avatar" style="background:' + color + ';">' + m.display_name.charAt(0).toUpperCase() + '</div>';
                sideHtml += '<div class="member-name">' + m.display_name + '</div>';
                sideHtml += '</div>';
            });
            $('#calMembersList').html(sideHtml || '<p class="text-muted small">No connections yet</p>');
        });
    }

    function renderCalendar() {
        var d = calState.currentDate;
        if (calState.viewType === 'month') {
            renderMonthView(d);
        } else if (calState.viewType === 'week') {
            renderWeekView(d);
        } else {
            renderDayView(d);
        }
        loadCalendarData();
    }

    function renderMonthView(d) {
        var year = d.getFullYear();
        var month = d.getMonth();
        $('#calTitle').text(monthNames[month] + ' ' + year);

        var firstDay = new Date(year, month, 1);
        var lastDay = new Date(year, month + 1, 0);
        var startDay = firstDay.getDay();
        var totalDays = lastDay.getDate();
        var today = new Date();

        // Clear existing day cells (keep headers)
        $('#monthGrid .day-cell').remove();

        // Previous month fill
        var prevLastDay = new Date(year, month, 0).getDate();
        for (var i = startDay - 1; i >= 0; i--) {
            var dayNum = prevLastDay - i;
            $('#monthGrid').append('<div class="day-cell other-month" data-date="' + formatDate(new Date(year, month - 1, dayNum)) + '"><span class="day-number">' + dayNum + '</span></div>');
        }

        // Current month
        for (var day = 1; day <= totalDays; day++) {
            var cellDate = new Date(year, month, day);
            var isToday = (cellDate.toDateString() === today.toDateString());
            var cls = 'day-cell' + (isToday ? ' today' : '');
            var dateStr = formatDate(cellDate);
            $('#monthGrid').append('<div class="' + cls + '" data-date="' + dateStr + '" onclick="Polyculy.onDayClick(\'' + dateStr + '\')"><span class="day-number">' + day + '</span><div class="day-events"></div></div>');
        }

        // Next month fill
        var remaining = 42 - (startDay + totalDays);
        for (var j = 1; j <= remaining; j++) {
            $('#monthGrid').append('<div class="day-cell other-month" data-date="' + formatDate(new Date(year, month + 1, j)) + '"><span class="day-number">' + j + '</span></div>');
        }
    }

    function renderWeekView(d) {
        var startOfWeek = new Date(d);
        startOfWeek.setDate(d.getDate() - d.getDay());
        var endOfWeek = new Date(startOfWeek);
        endOfWeek.setDate(startOfWeek.getDate() + 6);

        $('#calTitle').text('Week of ' + monthNames[startOfWeek.getMonth()] + ' ' + startOfWeek.getDate() + ', ' + startOfWeek.getFullYear());

        var headerHtml = '<div style="width:60px; flex-shrink:0;"></div>';
        for (var i = 0; i < 7; i++) {
            var dd = new Date(startOfWeek);
            dd.setDate(startOfWeek.getDate() + i);
            var isToday = dd.toDateString() === new Date().toDateString();
            headerHtml += '<div class="flex-fill text-center py-2 border-start" style="' + (isToday ? 'background:rgba(124,58,237,0.05);' : '') + '">';
            headerHtml += '<div class="small text-muted">' + dayNames[dd.getDay()] + '</div>';
            headerHtml += '<div class="fw-bold' + (isToday ? ' text-purple' : '') + '">' + dd.getDate() + '</div>';
            headerHtml += '</div>';
        }
        $('#weekDayHeaders').html(headerHtml);

        // Time slots
        var slotsHtml = '';
        for (var h = 0; h < 24; h++) {
            var label = h === 0 ? '12 AM' : h < 12 ? h + ' AM' : h === 12 ? '12 PM' : (h - 12) + ' PM';
            slotsHtml += '<div class="d-flex" style="height:60px; border-bottom:1px solid #F3F4F6;">';
            slotsHtml += '<div class="time-label" style="width:60px; flex-shrink:0;">' + label + '</div>';
            for (var j = 0; j < 7; j++) {
                slotsHtml += '<div class="flex-fill border-start position-relative" data-hour="' + h + '" data-day="' + j + '"></div>';
            }
            slotsHtml += '</div>';
        }
        $('#weekTimeSlots').html(slotsHtml);
    }

    function renderDayView(d) {
        var dayStr = dayNames[d.getDay()] + ', ' + monthNames[d.getMonth()] + ' ' + d.getDate() + ', ' + d.getFullYear();
        $('#calTitle').text(dayStr);

        var slotsHtml = '';
        for (var h = 0; h < 24; h++) {
            var label = h === 0 ? '12 AM' : h < 12 ? h + ' AM' : h === 12 ? '12 PM' : (h - 12) + ' PM';
            slotsHtml += '<div class="d-flex" style="height:60px; border-bottom:1px solid #F3F4F6;">';
            slotsHtml += '<div class="time-label" style="width:70px; flex-shrink:0;">' + label + '</div>';
            slotsHtml += '<div class="flex-fill position-relative" data-hour="' + h + '"></div>';
            slotsHtml += '</div>';
        }
        $('#dayTimeSlots').html(slotsHtml);
    }

    function loadCalendarData() {
        var d = calState.currentDate;
        var startDate, endDate;

        if (calState.viewType === 'month') {
            startDate = formatDate(new Date(d.getFullYear(), d.getMonth(), 1));
            endDate = formatDate(new Date(d.getFullYear(), d.getMonth() + 1, 0));
        } else if (calState.viewType === 'week') {
            var ws = new Date(d);
            ws.setDate(d.getDate() - d.getDay());
            var we = new Date(ws);
            we.setDate(ws.getDate() + 6);
            startDate = formatDate(ws);
            endDate = formatDate(we);
        } else {
            startDate = formatDate(d);
            endDate = formatDate(d);
        }

        var url = '/api/calendar.cfm?action=getData&view_type=' + calState.viewType +
            '&start_date=' + startDate + '&end_date=' + endDate +
            '&mode=' + calState.mode +
            '&enabled_user_ids=' + calState.enabledUserIds.join(',');

        $.getJSON(url, function(r) {
            var data = r.DATA || r.data || {};
            var personal = data.PERSONALEVENTS || data.personalEvents || [];
            var shared = data.SHAREDEVENTS || data.sharedEvents || [];
            var others = data.OTHERSEVENTS || data.othersEvents || [];

            if (calState.viewType === 'month') {
                renderMonthEvents(personal, shared, others);
            }

            // Render upcoming sidebar
            renderUpcoming(personal, shared);
        });
    }

    function renderMonthEvents(personal, shared, others) {
        // Clear existing events
        $('.day-events').empty();

        var allEvents = [];
        personal.forEach(function(e) {
            e = lk(e);
            allEvents.push({ title: e.title, date: parseDate(e.start_time), color: '#7C3AED', type: 'personal', id: e.event_id });
        });
        shared.forEach(function(e) {
            e = lk(e);
            var color = e.global_state === 'tentative' ? '#F59E0B' : '#22C55E';
            allEvents.push({ title: e.title, date: parseDate(e.start_time), color: color, type: 'shared', id: e.event_id });
        });
        others.forEach(function(e) {
            e = lk(e);
            var color = e.calendar_color || calState.memberColors[e.owner_user_id] || '#A855F7';
            var title = e.visibility_type === 'busy_block' ? 'Busy' : e.title;
            allEvents.push({ title: title, date: parseDate(e.start_time), color: color, type: 'other', id: e.event_id, owner: e.owner });
        });

        allEvents.forEach(function(ev) {
            var dateStr = formatDate(ev.date);
            var $cell = $('.day-cell[data-date="' + dateStr + '"] .day-events');
            if ($cell.length) {
                var $existing = $cell.children();
                if ($existing.length < 3) {
                    var onclick = ev.type === 'shared' ? "Polyculy.viewSharedEvent(" + ev.id + ")" : "Polyculy.viewPersonalEvent(" + ev.id + ")";
                    $cell.append('<div class="event-mini" style="background:' + ev.color + ';" onclick="' + onclick + '">' + ev.title + '</div>');
                } else if ($existing.length === 3) {
                    $cell.append('<div class="text-muted" style="font-size:0.65rem;">+more</div>');
                }
            }
        });
    }

    function renderUpcoming(personal, shared) {
        var all = [];
        personal.forEach(function(e) {
            e = lk(e);
            all.push({ title: e.title, date: parseDate(e.start_time), type: 'personal', id: e.event_id });
        });
        shared.forEach(function(e) {
            e = lk(e);
            all.push({ title: e.title, date: parseDate(e.start_time), type: 'shared', id: e.event_id, state: e.global_state });
        });
        all.sort(function(a, b) { return a.date - b.date; });

        var html = '';
        all.slice(0, 5).forEach(function(ev) {
            var icon = ev.type === 'shared' ? 'fa-users text-pink' : 'fa-calendar text-purple';
            var onclick = ev.type === 'shared' ? "Polyculy.viewSharedEvent(" + ev.id + ")" : "Polyculy.viewPersonalEvent(" + ev.id + ")";
            html += '<div class="event-card py-2 px-3 mb-2" onclick="' + onclick + '" style="cursor:pointer;">';
            html += '<div class="event-time"><i class="fas ' + icon + ' me-1"></i>' + ev.date.toLocaleDateString() + '</div>';
            html += '<div class="event-title small">' + ev.title + '</div>';
            html += '</div>';
        });
        if (all.length === 0) {
            html = '<p class="text-muted small text-center">No upcoming events</p>';
        }
        $('#upcomingEvents').html(html);
    }

    // ── Calendar Navigation ──
    function calNavPrev() {
        var d = calState.currentDate;
        if (calState.viewType === 'month') {
            d.setMonth(d.getMonth() - 1);
        } else if (calState.viewType === 'week') {
            d.setDate(d.getDate() - 7);
        } else {
            d.setDate(d.getDate() - 1);
        }
        renderCalendar();
    }

    function calNavNext() {
        var d = calState.currentDate;
        if (calState.viewType === 'month') {
            d.setMonth(d.getMonth() + 1);
        } else if (calState.viewType === 'week') {
            d.setDate(d.getDate() + 7);
        } else {
            d.setDate(d.getDate() + 1);
        }
        renderCalendar();
    }

    function calToday() {
        calState.currentDate = new Date();
        renderCalendar();
    }

    function setCalMode(mode) {
        calState.mode = mode;
        $('.mine-our-toggle .toggle-btn').removeClass('active');
        if (mode === 'our') {
            $('#toggleOur').addClass('active');
            $('#filterBar').addClass('active');
        } else {
            $('#toggleMine').addClass('active');
            $('#filterBar').removeClass('active');
        }
        loadCalendarData();
    }

    function toggleMember(el) {
        var $pill = $(el);
        var uid = parseInt($pill.data('user-id'));
        $pill.toggleClass('active');
        if ($pill.hasClass('active')) {
            if (calState.enabledUserIds.indexOf(uid) === -1) calState.enabledUserIds.push(uid);
        } else {
            calState.enabledUserIds = calState.enabledUserIds.filter(function(id) { return id !== uid; });
        }
        loadCalendarData();
    }

    function onDayClick(dateStr) {
        // Pre-fill modal with clicked date
        var dt = dateStr + 'T09:00';
        var dtEnd = dateStr + 'T10:00';
        $('#pe_start_time').val(dt);
        $('#pe_end_time').val(dtEnd);
        showPersonalEventModal();
    }

    // ── Personal Events ──
    function showPersonalEventModal() {
        $('#pe_event_id').val('');
        if (!$('#pe_start_time').val()) {
            var now = new Date();
            now.setMinutes(0);
            now.setHours(now.getHours() + 1);
            var end = new Date(now);
            end.setHours(end.getHours() + 1);
            $('#pe_start_time').val(formatDateTime(now));
            $('#pe_end_time').val(formatDateTime(end));
        }
        loadVisibilityPeople();
        new bootstrap.Modal('#personalEventModal').show();
    }

    function loadVisibilityPeople() {
        $.getJSON('/api/connections.cfm?action=connected', function(r) {
            var data = r.DATA || r.data || [];
            var fdHtml = '';
            var bbHtml = '';
            data.forEach(function(u) {
                u = lk(u);
                fdHtml += '<div class="form-check"><input class="form-check-input vis-fd" type="checkbox" value="' + u.user_id + '" data-name="' + u.display_name + '"><label class="form-check-label">' + (u.nickname || u.display_name) + '</label></div>';
                bbHtml += '<div class="form-check"><input class="form-check-input vis-bb" type="checkbox" value="' + u.user_id + '" data-name="' + u.display_name + '"><label class="form-check-label">' + (u.nickname || u.display_name) + '</label></div>';
            });
            fdHtml += '<div class="form-check mt-1"><input class="form-check-input vis-fd-all" type="checkbox" value="all"><label class="form-check-label fw-bold">Entire Polycule</label></div>';
            $('#fullDetailsPeople').html(fdHtml);
            $('#busyBlockPeople').html(bbHtml);
        });
    }

    function onVisibilityTierChange() {
        var tier = $('#pe_visibility_tier').val();
        if (tier === 'invisible') {
            $('#visibilityOptions').hide();
        } else if (tier === 'full_details') {
            $('#visibilityOptions').show();
            $('#fullDetailsGroup').show();
            $('#busyBlockGroup').hide();
        } else {
            $('#visibilityOptions').show();
            $('#fullDetailsGroup').show();
            $('#busyBlockGroup').show();
        }
    }

    function savePersonalEvent() {
        var data = {
            event_id: $('#pe_event_id').val(),
            title: $('#pe_title').val(),
            start_time: $('#pe_start_time').val(),
            end_time: $('#pe_end_time').val(),
            all_day: $('#pe_all_day').is(':checked'),
            address: $('#pe_address').val(),
            reminder_minutes: $('#pe_reminder').val(),
            event_details: $('#pe_details').val(),
            visibility_tier: $('#pe_visibility_tier').val()
        };

        if (!data.title || !data.start_time || !data.end_time) {
            toast('Please fill required fields', 'warning');
            return;
        }

        $.post('/api/events.cfm?action=save', data, function(r) {
            if (r.SUCCESS || r.success) {
                var eventId = r.ID || r.id;

                // Save visibility
                var tier = data.visibility_tier;
                if (tier !== 'invisible') {
                    var visData = [];
                    if ($('.vis-fd-all').is(':checked')) {
                        // All connected users get full details
                        $('.vis-fd').each(function() {
                            visData.push({ target_user_id: parseInt($(this).val()), visibility_type: 'full_details' });
                        });
                    } else {
                        $('.vis-fd:checked').each(function() {
                            visData.push({ target_user_id: parseInt($(this).val()), visibility_type: 'full_details' });
                        });
                    }
                    if (tier === 'mixed') {
                        $('.vis-bb:checked').each(function() {
                            var uid = parseInt($(this).val());
                            if (!visData.some(function(v) { return v.target_user_id === uid; })) {
                                visData.push({ target_user_id: uid, visibility_type: 'busy_block' });
                            }
                        });
                    }
                    if (visData.length > 0) {
                        $.post('/api/events.cfm?action=setVisibility', {
                            event_id: eventId,
                            visibility_data: JSON.stringify(visData)
                        });
                    }
                }

                bootstrap.Modal.getInstance('#personalEventModal').hide();
                toast(r.MESSAGE || r.message || 'Event saved');
                loadCalendarData();
            } else {
                toast(r.MESSAGE || r.message, 'danger');
            }
        }, 'json');
    }

    function cancelPersonalEvent(eventId) {
        $.post('/api/events.cfm?action=cancel', { event_id: eventId }, function(r) {
            toast('Event cancelled');
            window.location.href = '/views/calendar/month.cfm';
        }, 'json');
    }

    function viewPersonalEvent(id) {
        window.location.href = '/views/events/personal.cfm?id=' + id;
    }

    // ── Shared Events ──
    function showSharedEventModal() {
        $('#se_event_id').val('');
        $('#se_title').val('');
        $('#seStep1').show();
        $('#seStep2').hide();
        var now = new Date();
        now.setMinutes(0);
        now.setHours(now.getHours() + 1);
        var end = new Date(now);
        end.setHours(end.getHours() + 2);
        $('#se_start_time').val(formatDateTime(now));
        $('#se_end_time').val(formatDateTime(end));
        new bootstrap.Modal('#sharedEventModal').show();
    }

    function sharedEventStep2() {
        if (!$('#se_title').val() || !$('#se_start_time').val()) {
            toast('Please fill event details', 'warning');
            return;
        }
        $('#seStep1').hide();
        $('#seStep2').show();

        // Load connected users as potential participants
        $.getJSON('/api/connections.cfm?action=connected', function(r) {
            var data = r.DATA || r.data || [];
            var html = '';
            data.forEach(function(u) {
                u = lk(u);
                html += '<div class="form-check mb-2 p-2 bg-purple-light rounded">';
                html += '<input class="form-check-input se-participant" type="checkbox" value="' + u.user_id + '" id="sep_' + u.user_id + '">';
                html += '<label class="form-check-label ms-2" for="sep_' + u.user_id + '">';
                html += '<strong>' + (u.nickname || u.display_name) + '</strong>';
                html += '</label>';
                html += '<select class="form-select form-select-sm float-end" style="width:120px;" id="sept_' + u.user_id + '">';
                html += '<option value="required">Required</option><option value="optional">Optional</option>';
                html += '</select>';
                html += '</div>';
            });
            if (data.length === 0) {
                html = '<p class="text-muted">No connected users to invite. Connect with someone first!</p>';
            }
            $('#seParticipantList').html(html);
        });
    }

    function saveSharedEvent() {
        var participants = [];
        var formData = {
            title: $('#se_title').val(),
            start_time: $('#se_start_time').val(),
            end_time: $('#se_end_time').val(),
            address: $('#se_address').val(),
            event_details: $('#se_details').val(),
            participant_visibility: $('#se_participant_visibility').val(),
            participants: ''
        };

        var pids = [];
        $('.se-participant:checked').each(function() {
            var uid = $(this).val();
            pids.push(uid);
            formData['attendance_' + uid] = $('#sept_' + uid).val();
        });
        formData.participants = pids.join(',');

        $.post('/api/shared-events.cfm?action=create', formData, function(r) {
            if (r.SUCCESS || r.success) {
                bootstrap.Modal.getInstance('#sharedEventModal').hide();
                toast('Shared event created! Invitations sent.');
                loadCalendarData();
            } else {
                toast(r.MESSAGE || r.message, 'danger');
            }
        }, 'json');
    }

    function viewSharedEvent(id) {
        window.location.href = '/views/events/shared.cfm?id=' + id;
    }

    function cancelSharedEvent(eventId) {
        $.post('/api/shared-events.cfm?action=cancel', { event_id: eventId }, function(r) {
            toast('Event cancelled');
            window.location.href = '/views/calendar/month.cfm';
        }, 'json');
    }

    function respondToInvite(eventId, response) {
        $.post('/api/shared-events.cfm?action=respond', { event_id: eventId, response: response }, function(r) {
            toast('Response: ' + response);
            setTimeout(function() { window.location.href = '/views/calendar/month.cfm'; }, 800);
        }, 'json');
    }

    // ── Proposals ──
    function submitProposal(eventId) {
        $.post('/api/proposals.cfm?action=create', {
            event_id: eventId,
            proposed_start: $('#prop_start').val(),
            proposed_end: $('#prop_end').val(),
            message: $('#prop_message').val()
        }, function(r) {
            if (r.SUCCESS || r.success) {
                toast('Proposal submitted');
                try { bootstrap.Modal.getInstance('#proposeTimeModal').hide(); } catch(e) {}
                setTimeout(function() { location.reload(); }, 800);
            } else {
                toast(r.MESSAGE || r.message, 'danger');
            }
        }, 'json');
    }

    function acceptProposal(pid) {
        $.post('/api/proposals.cfm?action=accept', { proposal_id: pid }, function(r) {
            toast('Proposal accepted — event time updated');
            setTimeout(function() { location.reload(); }, 800);
        }, 'json');
    }

    function rejectProposal(pid) {
        $.post('/api/proposals.cfm?action=reject', { proposal_id: pid }, function(r) {
            toast('Proposal rejected');
            setTimeout(function() { location.reload(); }, 800);
        }, 'json');
    }

    // ── Ownership ──
    function claimOwnership(eventId) {
        $.post('/api/shared-events.cfm?action=claimOwnership', { event_id: eventId }, function(r) {
            if (r.SUCCESS || r.success) {
                toast('You are now the organizer!');
                setTimeout(function() { location.reload(); }, 800);
            } else {
                toast(r.MESSAGE || r.message, 'danger');
            }
        }, 'json');
    }

    // ── One-Hop ──
    function oneHopConsent(eventId, accept, allow) {
        if (accept) {
            // First respond to the event
            $.post('/api/shared-events.cfm?action=respond', { event_id: eventId, response: 'accepted' });
        }
        if (allow) {
            $.post('/api/shared-events.cfm?action=oneHopConsent', { event_id: eventId, consent: true }, function() {
                toast('Consent given — downstream invite activated');
                setTimeout(function() { window.location.href = '/views/calendar/month.cfm'; }, 800);
            }, 'json');
        } else {
            toast(accept ? 'Accepted without allowing one-hop' : 'Cancelled');
            setTimeout(function() { window.location.href = '/views/calendar/month.cfm'; }, 800);
        }
    }

    // ── Participant Removal ──
    function removeParticipant(eventId, userId) {
        $.post('/api/shared-events.cfm?action=removeParticipant', { event_id: eventId, user_id: userId }, function(r) {
            toast('Participant removed');
            setTimeout(function() { window.location.href = '/views/events/shared.cfm?id=' + eventId; }, 800);
        }, 'json');
    }

    // ── Info Email ──
    function sendInfoEmail(eventId) {
        $.post('/api/shared-events.cfm?action=sendInfoEmail', {
            event_id: eventId,
            recipient_name: $('#ie_name').val(),
            recipient_email: $('#ie_email').val(),
            message_note: $('#ie_note').val()
        }, function(r) {
            toast('Informational email would be sent (demo mode)');
            setTimeout(function() { history.back(); }, 800);
        }, 'json');
    }

    // ── Calendar Setup ──
    function setupCalendar(method) {
        $.post('/api/calendar.cfm?action=setup', {}, function(r) {
            if (r.SUCCESS || r.success) {
                window.location.href = r.REDIRECT || r.redirect || '/views/calendar/month.cfm';
            }
        }, 'json');
    }

    // ── Settings ──
    function saveProfile() {
        $.post('/api/preferences.cfm?action=update', {
            display_name: $('#pref_display_name').val(),
            timezone_id: $('#pref_timezone').val()
        }, function(r) {
            if (r.SUCCESS || r.success) {
                toast('Profile updated');
            } else {
                toast(r.MESSAGE || r.message, 'danger');
            }
        }, 'json');
        return false;
    }

    function saveTimezone() {
        $.post('/api/preferences.cfm?action=update', {
            display_name: $('#pref_display_name').val(),
            timezone_id: $('#pref_timezone').val()
        }, function(r) {
            toast('Timezone updated');
        }, 'json');
    }

    function changePassword() {
        if ($('#pw_new').val() !== $('#pw_confirm').val()) {
            toast('Passwords do not match', 'danger');
            return false;
        }
        $.post('/api/preferences.cfm?action=changePassword', {
            current_password: $('#pw_current').val(),
            new_password: $('#pw_new').val()
        }, function(r) {
            if (r.SUCCESS || r.success) {
                toast('Password changed');
                $('#pw_current, #pw_new, #pw_confirm').val('');
            } else {
                toast(r.MESSAGE || r.message, 'danger');
            }
        }, 'json');
        return false;
    }

    function updateNotifPref(type, enabled, mode) {
        $.post('/api/notifications.cfm?action=updatePreference', {
            notification_type: type,
            is_enabled: enabled,
            delivery_mode: mode || 'instant'
        });
    }

    // ── Public API ──
    return {
        // Notifications
        loadNotifications: loadNotifications,
        readNotif: readNotif,
        markAllNotifRead: markAllNotifRead,
        // Auth
        logout: logout,
        // Connections
        loadConnections: loadConnections,
        loadPendingRequests: loadPendingRequests,
        sendInvite: sendInvite,
        acceptConnection: acceptConnection,
        loadAvailableLicences: loadAvailableLicences,
        giftLicence: giftLicence,
        confirmRevocation: confirmRevocation,
        // Calendar
        initCalendar: initCalendar,
        calNavPrev: calNavPrev,
        calNavNext: calNavNext,
        calToday: calToday,
        setCalMode: setCalMode,
        toggleMember: toggleMember,
        onDayClick: onDayClick,
        // Personal Events
        showPersonalEventModal: showPersonalEventModal,
        onVisibilityTierChange: onVisibilityTierChange,
        savePersonalEvent: savePersonalEvent,
        cancelPersonalEvent: cancelPersonalEvent,
        viewPersonalEvent: viewPersonalEvent,
        editPersonalEvent: function(id) { viewPersonalEvent(id); },
        // Shared Events
        showSharedEventModal: showSharedEventModal,
        sharedEventStep2: sharedEventStep2,
        saveSharedEvent: saveSharedEvent,
        viewSharedEvent: viewSharedEvent,
        cancelSharedEvent: cancelSharedEvent,
        respondToInvite: respondToInvite,
        editSharedEvent: function(id) { viewSharedEvent(id); },
        // Proposals
        submitProposal: submitProposal,
        acceptProposal: acceptProposal,
        rejectProposal: rejectProposal,
        // Ownership
        claimOwnership: claimOwnership,
        // One-hop
        oneHopConsent: oneHopConsent,
        // Participants
        removeParticipant: removeParticipant,
        // Info Email
        sendInfoEmail: sendInfoEmail,
        // Calendar Setup
        setupCalendar: setupCalendar,
        // Settings
        saveProfile: saveProfile,
        saveTimezone: saveTimezone,
        changePassword: changePassword,
        updateNotifPref: updateNotifPref,
        // Utilities
        toast: toast,
        lk: lk
    };

})(jQuery);
