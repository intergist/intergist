<cf_main pageTitle="Day View" activePage="calendar">

<div class="container-fluid">
    <div class="calendar-container">
        <div class="calendar-header">
            <div class="d-flex align-items-center gap-3">
                <button class="calendar-nav-btn" onclick="Polyculy.calNavPrev()">
                    <i class="fas fa-chevron-left"></i>
                </button>
                <h3 id="calTitle">Wednesday, March 25, 2026</h3>
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
                    <a href="/views/calendar/month.cfm" class="btn btn-polyculy-outline btn-sm">Month</a>
                    <a href="/views/calendar/week.cfm" class="btn btn-polyculy-outline btn-sm">Week</a>
                    <a href="/views/calendar/day.cfm" class="btn btn-polyculy btn-sm">Day</a>
                </div>
            </div>
        </div>

        <div id="dayGrid" style="position:relative; min-height:600px;">
            <div id="dayTimeSlots"></div>
        </div>
    </div>
</div>

<div class="filter-bar" id="filterBar">
    <span class="small text-muted me-2"><i class="fas fa-filter me-1"></i>Show:</span>
    <div id="filterPills"></div>
</div>

<script>
$(function() {
    Polyculy.initCalendar('day');
});
</script>

</cf_main>
