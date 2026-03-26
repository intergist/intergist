component {

    function getAll() {
        return queryExecute(
            "SELECT p.project_id, p.project_name, p.description, p.status, p.priority,
                    p.owner_id, p.start_date, p.due_date, p.created_at, p.updated_at,
                    CONCAT(t.first_name, ' ', t.last_name) AS owner_name,
                    (SELECT COUNT(*) FROM tasks WHERE project_id = p.project_id) AS task_count,
                    (SELECT COUNT(*) FROM tasks WHERE project_id = p.project_id AND status = 'Done') AS done_count
             FROM projects p
             LEFT JOIN team_members t ON p.owner_id = t.member_id
             ORDER BY p.project_name"
        );
    }

    function getById(required numeric projectId) {
        return queryExecute(
            "SELECT p.project_id, p.project_name, p.description, p.status, p.priority,
                    p.owner_id, p.start_date, p.due_date, p.created_at, p.updated_at,
                    CONCAT(t.first_name, ' ', t.last_name) AS owner_name
             FROM projects p
             LEFT JOIN team_members t ON p.owner_id = t.member_id
             WHERE p.project_id = :id",
            { id: { value: arguments.projectId, cfsqltype: "cf_sql_integer" } }
        );
    }

    function create(required struct data) {
        var result = queryExecute(
            "INSERT INTO projects (project_name, description, status, priority, owner_id, start_date, due_date)
             VALUES (:pname, :desc, :status, :priority, :owner, :sdate, :ddate)",
            {
                pname:    { value: data.project_name, cfsqltype: "cf_sql_varchar" },
                desc:     { value: data.description ?: "", cfsqltype: "cf_sql_varchar" },
                status:   { value: data.status ?: "Active", cfsqltype: "cf_sql_varchar" },
                priority: { value: data.priority ?: "Medium", cfsqltype: "cf_sql_varchar" },
                owner:    { value: data.owner_id ?: "", cfsqltype: "cf_sql_integer", null: !len(data.owner_id ?: "") },
                sdate:    { value: data.start_date ?: "", cfsqltype: "cf_sql_date", null: !len(data.start_date ?: "") },
                ddate:    { value: data.due_date ?: "", cfsqltype: "cf_sql_date", null: !len(data.due_date ?: "") }
            },
            { result: "qResult" }
        );
        return qResult.generatedKey;
    }

    function update(required numeric projectId, required struct data) {
        queryExecute(
            "UPDATE projects
             SET project_name = :pname, description = :desc, status = :status,
                 priority = :priority, owner_id = :owner,
                 start_date = :sdate, due_date = :ddate,
                 updated_at = CURRENT_TIMESTAMP
             WHERE project_id = :id",
            {
                id:       { value: arguments.projectId, cfsqltype: "cf_sql_integer" },
                pname:    { value: data.project_name, cfsqltype: "cf_sql_varchar" },
                desc:     { value: data.description ?: "", cfsqltype: "cf_sql_varchar" },
                status:   { value: data.status, cfsqltype: "cf_sql_varchar" },
                priority: { value: data.priority, cfsqltype: "cf_sql_varchar" },
                owner:    { value: data.owner_id ?: "", cfsqltype: "cf_sql_integer", null: !len(data.owner_id ?: "") },
                sdate:    { value: data.start_date ?: "", cfsqltype: "cf_sql_date", null: !len(data.start_date ?: "") },
                ddate:    { value: data.due_date ?: "", cfsqltype: "cf_sql_date", null: !len(data.due_date ?: "") }
            }
        );
    }

    function delete(required numeric projectId) {
        // Delete associated tasks first
        queryExecute(
            "DELETE FROM task_comments WHERE task_id IN (SELECT task_id FROM tasks WHERE project_id = :id)",
            { id: { value: arguments.projectId, cfsqltype: "cf_sql_integer" } }
        );
        queryExecute(
            "DELETE FROM tasks WHERE project_id = :id",
            { id: { value: arguments.projectId, cfsqltype: "cf_sql_integer" } }
        );
        queryExecute(
            "DELETE FROM projects WHERE project_id = :id",
            { id: { value: arguments.projectId, cfsqltype: "cf_sql_integer" } }
        );
    }

    function getStats() {
        return queryExecute(
            "SELECT
                (SELECT COUNT(*) FROM projects) AS total_projects,
                (SELECT COUNT(*) FROM projects WHERE status = 'Active') AS active_projects,
                (SELECT COUNT(*) FROM projects WHERE status = 'On Hold') AS onhold_projects,
                (SELECT COUNT(*) FROM projects WHERE status = 'Completed') AS completed_projects
             FROM (VALUES(1)) AS dummy(x)"
        );
    }

}
