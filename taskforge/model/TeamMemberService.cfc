component {

    function getAll() {
        return queryExecute(
            "SELECT member_id, first_name, last_name, email, role, avatar_color, is_active,
                    created_at, updated_at
             FROM team_members
             ORDER BY first_name, last_name"
        );
    }

    function getActive() {
        return queryExecute(
            "SELECT member_id, first_name, last_name, email, role, avatar_color
             FROM team_members
             WHERE is_active = TRUE
             ORDER BY first_name, last_name"
        );
    }

    function getById(required numeric memberId) {
        return queryExecute(
            "SELECT member_id, first_name, last_name, email, role, avatar_color, is_active,
                    created_at, updated_at
             FROM team_members
             WHERE member_id = :id",
            { id: { value: arguments.memberId, cfsqltype: "cf_sql_integer" } }
        );
    }

    function create(required struct data) {
        var result = queryExecute(
            "INSERT INTO team_members (first_name, last_name, email, role, avatar_color)
             VALUES (:fname, :lname, :email, :role, :color)",
            {
                fname: { value: data.first_name, cfsqltype: "cf_sql_varchar" },
                lname: { value: data.last_name, cfsqltype: "cf_sql_varchar" },
                email: { value: data.email, cfsqltype: "cf_sql_varchar" },
                role:  { value: data.role ?: "Developer", cfsqltype: "cf_sql_varchar" },
                color: { value: data.avatar_color ?: "##4F46E5", cfsqltype: "cf_sql_varchar" }
            },
            { result: "qResult" }
        );
        return qResult.generatedKey;
    }

    function update(required numeric memberId, required struct data) {
        queryExecute(
            "UPDATE team_members
             SET first_name = :fname, last_name = :lname, email = :email,
                 role = :role, avatar_color = :color, is_active = :active,
                 updated_at = CURRENT_TIMESTAMP
             WHERE member_id = :id",
            {
                id:     { value: arguments.memberId, cfsqltype: "cf_sql_integer" },
                fname:  { value: data.first_name, cfsqltype: "cf_sql_varchar" },
                lname:  { value: data.last_name, cfsqltype: "cf_sql_varchar" },
                email:  { value: data.email, cfsqltype: "cf_sql_varchar" },
                role:   { value: data.role, cfsqltype: "cf_sql_varchar" },
                color:  { value: data.avatar_color, cfsqltype: "cf_sql_varchar" },
                active: { value: data.is_active ?: true, cfsqltype: "cf_sql_bit" }
            }
        );
    }

    function delete(required numeric memberId) {
        queryExecute(
            "DELETE FROM team_members WHERE member_id = :id",
            { id: { value: arguments.memberId, cfsqltype: "cf_sql_integer" } }
        );
    }

}
