<cf_main pageTitle="Week View" activePage="calendar">

<div class="container-fluid">
    <div class="calendar-container">
        <div class="calendar-header">
            <div class="d-flex align-items-center gap-3">
                <button class="calendar-nav-btn" onclick="Polyculy.calNavPrev()">
                    <i class="fas fa-chevron-left"></i>
                </button>
                <h3 id="calTitle">Week of March 23, 2026</h3>
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
                    <a href="/views/calendar/week.cfm" class="btn btn-polyculy btn-sm">Week</a>
                    <a href="/views/calendar/day.cfm" class="btn btn-polyculy-outline btn-sm">Day</a>
                </div>
            </div>
        </div>

        <!-- Week Grid -->
        <div class="position-relative" style="overflow-x: auto;">
            <div id="weekGrid" style="min-height:600px; position:relative;">
                <!-- Week header -->
                <div class="d-flex border-bottom" id="weekDayHeaders" style="position:sticky; top:0; background:white; z-index:5;"></div>
                <!-- Time slots -->
                <div id="weekTimeSlots" style="position:relative;"></div>
            </div>
        </div>
    </div>
</div>

<!-- Bottom Filter Bar -->
<div class="filter-bar" id="filterBar">
    <span class="small text-muted me-2"><i class="fas fa-filter me-1"></i>Show:</span>
    <div id="filterPills"></div>
</div>

<script>
$(function() {
    Polyculy.initCalendar('week');
});
</script>

</cf_main>
