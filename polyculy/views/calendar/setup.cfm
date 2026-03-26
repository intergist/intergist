<cf_main pageTitle="Create Calendar" activePage="calendar">

<div class="container" style="max-width:700px;">
    <div class="text-center mb-4">
        <h2><i class="fas fa-calendar-plus me-2"></i>Create Your Personal Calendar</h2>
        <p class="text-muted">Choose how you'd like to get started</p>
    </div>

    <div class="row g-4">
        <!-- Option 1: From Scratch -->
        <div class="col-md-4">
            <div class="polyculy-card card text-center h-100" style="cursor:pointer;" onclick="Polyculy.setupCalendar('scratch')">
                <div class="card-body py-4">
                    <i class="fas fa-plus-circle fa-3x text-purple mb-3"></i>
                    <h5>Start from Scratch</h5>
                    <p class="text-muted small">Begin with a blank calendar and add events as you go</p>
                </div>
            </div>
        </div>

        <!-- Option 2: Upload .ics -->
        <div class="col-md-4">
            <div class="polyculy-card card text-center h-100" style="cursor:pointer; opacity:0.6;" title="Coming soon">
                <div class="card-body py-4">
                    <i class="fas fa-file-upload fa-3x text-purple mb-3"></i>
                    <h5>Upload .ics File</h5>
                    <p class="text-muted small">Import events from an .ics calendar file</p>
                    <span class="badge badge-tentative">Coming Soon</span>
                </div>
            </div>
        </div>

        <!-- Option 3: Google Calendar -->
        <div class="col-md-4">
            <div class="polyculy-card card text-center h-100" style="cursor:pointer; opacity:0.6;" title="Coming soon">
                <div class="card-body py-4">
                    <i class="fab fa-google fa-3x text-purple mb-3"></i>
                    <h5>Google Calendar</h5>
                    <p class="text-muted small">Connect to your Google Calendar to import events</p>
                    <span class="badge badge-tentative">Coming Soon</span>
                </div>
            </div>
        </div>
    </div>
</div>

</cf_main>
