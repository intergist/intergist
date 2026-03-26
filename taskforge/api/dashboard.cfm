<cfscript>
    setting showDebugOutput=false;
    cfheader(name="Content-Type", value="application/json");

    taskSvc = new model.TaskService();
    projSvc = new model.ProjectService();
    actSvc = new model.ActivityService();

    response = { "success": true };

    try {
        taskStats = taskSvc.getStats();
        projStats = projSvc.getStats();
        recentActivity = actSvc.getRecent(10);

        // Task distribution by status
        statusDist = taskSvc.getByStatus();
        statusData = [];
        for (row in statusDist) { arrayAppend(statusData, row); }

        // Activity list
        activityData = [];
        for (row in recentActivity) { arrayAppend(activityData, row); }

        response["data"] = {
            tasks: {
                total: taskStats.total_tasks,
                todo: taskStats.todo_count,
                in_progress: taskStats.inprogress_count,
                in_review: taskStats.inreview_count,
                done: taskStats.done_count,
                blocked: taskStats.blocked_count,
                critical: taskStats.critical_count,
                high_priority: taskStats.high_count,
                overdue: taskStats.overdue_count
            },
            projects: {
                total: projStats.total_projects,
                active: projStats.active_projects,
                on_hold: projStats.onhold_projects,
                completed: projStats.completed_projects
            },
            status_distribution: statusData,
            recent_activity: activityData
        };
    } catch (any e) {
        response = { "success": false, "message": e.message };
    }

    writeOutput(serializeJSON(response));
</cfscript>
