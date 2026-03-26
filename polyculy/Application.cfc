component {

    this.name = "Polyculy";
    this.applicationTimeout = createTimeSpan(1, 0, 0, 0);
    this.sessionManagement = true;
    this.sessionTimeout = createTimeSpan(0, 2, 0, 0);

    // Mappings
    this.mappings["/components"] = getDirectoryFromPath(getCurrentTemplatePath()) & "components";
    this.mappings["/model"]      = getDirectoryFromPath(getCurrentTemplatePath()) & "model";
    this.mappings["/api"]        = getDirectoryFromPath(getCurrentTemplatePath()) & "api";

    // Custom tag paths for <cf_main> layout tag
    this.customTagPaths = getDirectoryFromPath(getCurrentTemplatePath()) & "views/layouts";

    // H2 embedded datasource
    this.datasources["polyculy"] = {
        class: "org.h2.Driver",
        connectionString: "jdbc:h2:#getDirectoryFromPath(getCurrentTemplatePath())#data/polyculy;MODE=MSSQLServer;AUTO_SERVER=TRUE"
    };
    this.defaultdatasource = "polyculy";

    function onApplicationStart() {
        var dbInit = new components.DatabaseInit();
        dbInit.initialize();
        application.csrfKey = hash(createUUID());
        return true;
    }

    function onSessionStart() {
        session.isLoggedIn = false;
        session.userId = 0;
        session.displayName = "";
        session.email = "";
        session.csrfToken = hash(createUUID() & now());
    }

    function onRequestStart(targetPage) {
        // Allow reinit via URL param
        if (structKeyExists(url, "reinit")) {
            onApplicationStart();
        }

        // Public pages that don't require auth
        var publicPages = ["/index.cfm", "/views/auth/login.cfm", "/views/auth/signup.cfm", "/views/auth/recovery.cfm", "/api/auth.cfm", "/api/licences.cfm"];
        var currentPage = lCase(arguments.targetPage);

        // Allow API endpoints and static assets without auth check for specific actions
        if (findNoCase("/assets/", currentPage) || findNoCase("/api/auth.cfm", currentPage)) {
            return true;
        }

        // Check authentication for non-public pages
        var isPublic = false;
        for (var pg in publicPages) {
            if (currentPage == lCase(pg)) {
                isPublic = true;
                break;
            }
        }

        if (!isPublic && (!structKeyExists(session, "isLoggedIn") || !session.isLoggedIn)) {
            location(url="/index.cfm", addToken=false);
            return false;
        }

        return true;
    }

    function onError(exception, eventName) {
        writeDump(var=exception, label="Application Error");
    }

}
