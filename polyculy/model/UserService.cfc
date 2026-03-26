component {

    function authenticate(required string email, required string password) {
        var pwHash = uCase(hash(arguments.password, "SHA-256"));
        return queryExecute(
            "SELECT user_id, email, display_name, avatar_url, timezone_id, calendar_created
             FROM users
             WHERE email = :email AND password_hash = :pw AND is_active = TRUE",
            {
                email: { value: arguments.email, cfsqltype: "cf_sql_varchar" },
                pw:    { value: pwHash, cfsqltype: "cf_sql_varchar" }
            },
            { datasource: "polyculy" }
        );
    }

    function getById(required numeric userId) {
        return queryExecute(
            "SELECT user_id, email, display_name, avatar_url, timezone_id, calendar_created, is_active, created_at
             FROM users WHERE user_id = :id",
            { id: { value: arguments.userId, cfsqltype: "cf_sql_integer" } },
            { datasource: "polyculy" }
        );
    }

    function getByEmail(required string email) {
        return queryExecute(
            "SELECT user_id, email, display_name, avatar_url, timezone_id, calendar_created
             FROM users WHERE email = :email",
            { email: { value: arguments.email, cfsqltype: "cf_sql_varchar" } },
            { datasource: "polyculy" }
        );
    }

    function create(required struct data) {
        var pwHash = uCase(hash(arguments.data.password, "SHA-256"));
        queryExecute(
            "INSERT INTO users (email, password_hash, display_name, timezone_id)
             VALUES (:email, :pw, :name, :tz)",
            {
                email: { value: data.email, cfsqltype: "cf_sql_varchar" },
                pw:    { value: pwHash, cfsqltype: "cf_sql_varchar" },
                name:  { value: data.display_name, cfsqltype: "cf_sql_varchar" },
                tz:    { value: data.timezone_id ?: "America/New_York", cfsqltype: "cf_sql_varchar" }
            },
            { datasource: "polyculy", result: "qResult" }
        );
        return listFirst(qResult.generatedKey);
    }

    function updateProfile(required numeric userId, required struct data) {
        queryExecute(
            "UPDATE users SET display_name = :name, timezone_id = :tz, updated_at = CURRENT_TIMESTAMP
             WHERE user_id = :id",
            {
                id:   { value: arguments.userId, cfsqltype: "cf_sql_integer" },
                name: { value: data.display_name, cfsqltype: "cf_sql_varchar" },
                tz:   { value: data.timezone_id, cfsqltype: "cf_sql_varchar" }
            },
            { datasource: "polyculy" }
        );
    }

    function setCalendarCreated(required numeric userId) {
        queryExecute(
            "UPDATE users SET calendar_created = TRUE, updated_at = CURRENT_TIMESTAMP WHERE user_id = :id",
            { id: { value: arguments.userId, cfsqltype: "cf_sql_integer" } },
            { datasource: "polyculy" }
        );
    }

    function changePassword(required numeric userId, required string newPassword) {
        var pwHash = uCase(hash(arguments.newPassword, "SHA-256"));
        queryExecute(
            "UPDATE users SET password_hash = :pw, updated_at = CURRENT_TIMESTAMP WHERE user_id = :id",
            {
                id: { value: arguments.userId, cfsqltype: "cf_sql_integer" },
                pw: { value: pwHash, cfsqltype: "cf_sql_varchar" }
            },
            { datasource: "polyculy" }
        );
    }

}
