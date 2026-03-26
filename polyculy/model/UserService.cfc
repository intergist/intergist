component {

    function authenticate(required string email, required string password) {
        var passwordHash = hash(arguments.password, "SHA-256");
        var q = queryExecute(
            "SELECT user_id, email, display_name, avatar_url, timezone_id, calendar_created
             FROM users WHERE email = :email AND password_hash = :pw AND is_active = TRUE",
            {
                email: { value: arguments.email, cfsqltype: "cf_sql_varchar" },
                pw: { value: passwordHash, cfsqltype: "cf_sql_varchar" }
            }
        );
        return q;
    }

    function getById(required numeric userId) {
        return queryExecute(
            "SELECT user_id, email, display_name, avatar_url, timezone_id, calendar_created, is_active, created_at
             FROM users WHERE user_id = :id",
            { id: { value: arguments.userId, cfsqltype: "cf_sql_integer" } }
        );
    }

    function getByEmail(required string email) {
        return queryExecute(
            "SELECT user_id, email, display_name, avatar_url, timezone_id, calendar_created
             FROM users WHERE email = :email",
            { email: { value: arguments.email, cfsqltype: "cf_sql_varchar" } }
        );
    }

    function create(required string email, required string password, required string displayName) {
        var passwordHash = hash(arguments.password, "SHA-256");
        queryExecute(
            "INSERT INTO users (email, password_hash, display_name) VALUES (:email, :pw, :name)",
            {
                email: { value: arguments.email, cfsqltype: "cf_sql_varchar" },
                pw: { value: passwordHash, cfsqltype: "cf_sql_varchar" },
                name: { value: arguments.displayName, cfsqltype: "cf_sql_varchar" }
            },
            { result: "qResult" }
        );
        return listFirst(qResult.generatedKey);
    }

    function updateTimezone(required numeric userId, required string timezoneId) {
        queryExecute(
            "UPDATE users SET timezone_id = :tz, updated_at = CURRENT_TIMESTAMP WHERE user_id = :id",
            {
                id: { value: arguments.userId, cfsqltype: "cf_sql_integer" },
                tz: { value: arguments.timezoneId, cfsqltype: "cf_sql_varchar" }
            }
        );
    }

    function setCalendarCreated(required numeric userId) {
        queryExecute(
            "UPDATE users SET calendar_created = TRUE, updated_at = CURRENT_TIMESTAMP WHERE user_id = :id",
            { id: { value: arguments.userId, cfsqltype: "cf_sql_integer" } }
        );
    }

    function updateProfile(required numeric userId, required string displayName, string avatarUrl = "") {
        queryExecute(
            "UPDATE users SET display_name = :name, avatar_url = :avatar, updated_at = CURRENT_TIMESTAMP WHERE user_id = :id",
            {
                id: { value: arguments.userId, cfsqltype: "cf_sql_integer" },
                name: { value: arguments.displayName, cfsqltype: "cf_sql_varchar" },
                avatar: { value: arguments.avatarUrl, cfsqltype: "cf_sql_varchar", null: !len(arguments.avatarUrl) }
            }
        );
    }

}
