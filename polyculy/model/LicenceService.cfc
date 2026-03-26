component {

    function validate(required string licenceCode) {
        return queryExecute(
            "SELECT licence_id, licence_code, licence_type, status, gifted_to_email
             FROM licences WHERE licence_code = :code AND status IN ('available','gifted_pending')",
            { code: { value: arguments.licenceCode, cfsqltype: "cf_sql_varchar" } },
            { datasource: "polyculy" }
        );
    }

    function redeem(required string licenceCode, required numeric userId) {
        queryExecute(
            "UPDATE licences SET redeemed_by_user_id = :uid, owner_user_id = :uid,
                    status = 'redeemed', redeemed_at = CURRENT_TIMESTAMP
             WHERE licence_code = :code AND status IN ('available','gifted_pending')",
            {
                uid:  { value: arguments.userId, cfsqltype: "cf_sql_integer" },
                code: { value: arguments.licenceCode, cfsqltype: "cf_sql_varchar" }
            },
            { datasource: "polyculy" }
        );
    }

    function getByUser(required numeric userId) {
        return queryExecute(
            "SELECT licence_id, licence_code, licence_type, status, gifted_to_email, created_at, redeemed_at
             FROM licences WHERE owner_user_id = :uid OR gifted_by_user_id = :uid2
             ORDER BY created_at DESC",
            {
                uid:  { value: arguments.userId, cfsqltype: "cf_sql_integer" },
                uid2: { value: arguments.userId, cfsqltype: "cf_sql_integer" }
            },
            { datasource: "polyculy" }
        );
    }

    function giftLicence(required numeric fromUserId, required string toEmail, required string licenceCode) {
        queryExecute(
            "UPDATE licences SET gifted_to_email = :email, gifted_by_user_id = :fromId,
                    status = 'gifted_pending'
             WHERE licence_code = :code AND status = 'available'",
            {
                email:  { value: arguments.toEmail, cfsqltype: "cf_sql_varchar" },
                fromId: { value: arguments.fromUserId, cfsqltype: "cf_sql_integer" },
                code:   { value: arguments.licenceCode, cfsqltype: "cf_sql_varchar" }
            },
            { datasource: "polyculy" }
        );
    }

    function getAvailableForUser(required numeric userId) {
        return queryExecute(
            "SELECT licence_id, licence_code, licence_type
             FROM licences WHERE owner_user_id = :uid AND status = 'available'",
            { uid: { value: arguments.userId, cfsqltype: "cf_sql_integer" } },
            { datasource: "polyculy" }
        );
    }

}
