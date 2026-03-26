component {

    function getAll(string projectId = "", string status = "", string assignedTo = "", string priority = "") {
        var sql = "SELECT t.task_id, t.project_id, t.title, t.description, t.status, t.priority,
                          t.assigned_to, t.due_date, t.estimated_hours, t.actual_hours, t.tags,
                          t.created_at, t.updated_at,
                          p.project_name,
                          CONCAT(m.first_name, ' ', m.last_name) AS assignee_name,
                          m.avatar_color AS assignee_color
                   FROM tasks t
                   JOIN projects p ON t.project_id = p.project_id
                   LEFT JOIN team_members m ON t.assigned_to = m.member_id
                   WHERE 1=1";
        var params = {};

        if (len(arguments.projectId)) {
            sql &= " AND t.project_id = :pid";
            params["pid"] = { value: arguments.projectId, cfsqltype: "cf_sql_integer" };
        }
        if (len(arguments.status)) {
            sql &= " AND t.status = :status";
            params["status"] = { value: arguments.status, cfsqltype: "cf_sql_varchar" };
        }
        if (len(arguments.assignedTo)) {
            sql &= " AND t.assigned_to = :assignee";
            params["assignee"] = { value: arguments.assignedTo, cfsqltype: "cf_sql_integer" };
        }
        if (len(arguments.priority)) {
            sql &= " AND t.priority = :priority";
            params["priority"] = { value: arguments.priority, cfsqltype: "cf_sql_varchar" };
        }

        sql &= " ORDER BY
                    CASE t.priority
                        WHEN 'Critical' THEN 1
                        WHEN 'High' THEN 2
                        WHEN 'Medium' THEN 3
                        WHEN 'Low' THEN 4
                    END,
                    CASE WHEN t.due_date IS NULL THEN 1 ELSE 0 END,
                    t.due_date ASC";

        return queryExecute(sql, params);
    }

    function getById(required numeric taskId) {
        return queryExecute(
            "SELECT t.task_id, t.project_id, t.title, t.description, t.status, t.priority,
                    t.assigned_to, t.due_date, t.estimated_hours, t.actual_hours, t.tags,
                    t.created_at, t.updated_at,
                    p.project_name,
                    CONCAT(m.first_name, ' ', m.last_name) AS assignee_name
             FROM tasks t
             JOIN projects p ON t.project_id = p.project_id
             LEFT JOIN team_members m ON t.assigned_to = m.member_id
             WHERE t.task_id = :id",
            { id: { value: arguments.taskId, cfsqltype: "cf_sql_integer" } }
        );
    }

    function create(required struct data) {
        var result = queryExecute(
            "INSERT INTO tasks (project_id, title, description, status, priority, assigned_to, due_date, estimated_hours, tags)
             VALUES (:pid, :title, :desc, :status, :priority, :assignee, :ddate, :hours, :tags)",
            {
                pid:      { value: data.project_id, cfsqltype: "cf_sql_integer" },
                title:    { value: data.title, cfsqltype: "cf_sql_varchar" },
                desc:     { value: data.description ?: "", cfsqltype: "cf_sql_varchar" },
                status:   { value: data.status ?: "To Do", cfsqltype: "cf_sql_varchar" },
                priority: { value: data.priority ?: "Medium", cfsqltype: "cf_sql_varchar" },
                assignee: { value: data.assigned_to ?: "", cfsqltype: "cf_sql_integer", null: !len(data.assigned_to ?: "") },
                ddate:    { value: data.due_date ?: "", cfsqltype: "cf_sql_date", null: !len(data.due_date ?: "") },
                hours:    { value: data.estimated_hours ?: "", cfsqltype: "cf_sql_decimal", null: !len(data.estimated_hours ?: "") },
                tags:     { value: data.tags ?: "", cfsqltype: "cf_sql_varchar" }
            },
            { result: "qResult" }
        );
        return qResult.generatedKey;
    }

    function update(required numeric taskId, required struct data) {
        queryExecute(
            "UPDATE tasks
             SET project_id = :pid, title = :title, description = :desc,
                 status = :status, priority = :priority, assigned_to = :assignee,
                 due_date = :ddate, estimated_hours = :hours, actual_hours = :ahours,
                 tags = :tags, updated_at = CURRENT_TIMESTAMP
             WHERE task_id = :id",
            {
                id:       { value: arguments.taskId, cfsqltype: "cf_sql_integer" },
                pid:      { value: data.project_id, cfsqltype: "cf_sql_integer" },
                title:    { value: data.title, cfsqltype: "cf_sql_varchar" },
                desc:     { value: data.description ?: "", cfsqltype: "cf_sql_varchar" },
                status:   { value: data.status, cfsqltype: "cf_sql_varchar" },
                priority: { value: data.priority, cfsqltype: "cf_sql_varchar" },
                assignee: { value: data.assigned_to ?: "", cfsqltype: "cf_sql_integer", null: !len(data.assigned_to ?: "") },
                ddate:    { value: data.due_date ?: "", cfsqltype: "cf_sql_date", null: !len(data.due_date ?: "") },
                hours:    { value: data.estimated_hours ?: "", cfsqltype: "cf_sql_decimal", null: !len(data.estimated_hours ?: "") },
                ahours:   { value: data.actual_hours ?: "", cfsqltype: "cf_sql_decimal", null: !len(data.actual_hours ?: "") },
                tags:     { value: data.tags ?: "", cfsqltype: "cf_sql_varchar" }
            }
        );
    }

    function updateStatus(required numeric taskId, required string newStatus) {
        queryExecute(
            "UPDATE tasks SET status = :status, updated_at = CURRENT_TIMESTAMP WHERE task_id = :id",
            {
                id:     { value: arguments.taskId, cfsqltype: "cf_sql_integer" },
                status: { value: arguments.newStatus, cfsqltype: "cf_sql_varchar" }
            }
        );
    }

    function delete(required numeric taskId) {
        queryExecute(
            "DELETE FROM task_comments WHERE task_id = :id",
            { id: { value: arguments.taskId, cfsqltype: "cf_sql_integer" } }
        );
        queryExecute(
            "DELETE FROM tasks WHERE task_id = :id",
            { id: { value: arguments.taskId, cfsqltype: "cf_sql_integer" } }
        );
    }

    function getComments(required numeric taskId) {
        return queryExecute(
            "SELECT c.comment_id, c.comment_text, c.created_at,
                    CONCAT(m.first_name, ' ', m.last_name) AS author_name,
                    m.avatar_color AS author_color
             FROM task_comments c
             JOIN team_members m ON c.author_id = m.member_id
             WHERE c.task_id = :id
             ORDER BY c.created_at DESC",
            { id: { value: arguments.taskId, cfsqltype: "cf_sql_integer" } }
        );
    }

    function addComment(required numeric taskId, required numeric authorId, required string commentText) {
        queryExecute(
            "INSERT INTO task_comments (task_id, author_id, comment_text)
             VALUES (:tid, :aid, :txt)",
            {
                tid: { value: arguments.taskId, cfsqltype: "cf_sql_integer" },
                aid: { value: arguments.authorId, cfsqltype: "cf_sql_integer" },
                txt: { value: arguments.commentText, cfsqltype: "cf_sql_varchar" }
            }
        );
    }

    function getStats() {
        return queryExecute(
            "SELECT
                COUNT(*) AS total_tasks,
                SUM(CASE WHEN status = 'To Do' THEN 1 ELSE 0 END) AS todo_count,
                SUM(CASE WHEN status = 'In Progress' THEN 1 ELSE 0 END) AS inprogress_count,
                SUM(CASE WHEN status = 'In Review' THEN 1 ELSE 0 END) AS inreview_count,
                SUM(CASE WHEN status = 'Done' THEN 1 ELSE 0 END) AS done_count,
                SUM(CASE WHEN status = 'Blocked' THEN 1 ELSE 0 END) AS blocked_count,
                SUM(CASE WHEN priority = 'Critical' THEN 1 ELSE 0 END) AS critical_count,
                SUM(CASE WHEN priority = 'High' THEN 1 ELSE 0 END) AS high_count,
                SUM(CASE WHEN due_date < CURRENT_DATE AND status NOT IN ('Done') THEN 1 ELSE 0 END) AS overdue_count
             FROM tasks"
        );
    }

    function getByStatus() {
        return queryExecute(
            "SELECT status, COUNT(*) AS cnt FROM tasks GROUP BY status ORDER BY status"
        );
    }

}
