component {

    this.name = "Polyculy";
    this.applicationTimeout = createTimeSpan(1, 0, 0, 0);
    this.sessionManagement = true;
    this.sessionTimeout = createTimeSpan(0, 2, 0, 0);

    // Mappings
    this.mappings["/components"] = getDirectoryFromPath(getCurrentTemplatePath()) & "components";
    this.mappings["/model"]      = getDirectoryFromPath(getCurrentTemplatePath()) & "model";
    this.mappings["/api"]        = getDirectoryFromPath(getCurrentTemplatePath()) & "api";

    // Custom tag paths for layout
    this.customTagPaths = getDirectoryFromPath(getCurrentTemplatePath()) & "views/layouts";

    // H2 embedded datasource for demo
    this.datasources["polyculy"] = {
        class: "org.h2.Driver",
        connectionString: "jdbc:h2:#getDirectoryFromPath(getCurrentTemplatePath())#data/polyculy;MODE=MSSQLServer;AUTO_SERVER=TRUE"
    };
    this.defaultdatasource = "polyculy";

    function onApplicationStart() {
        var dbInit = new components.DatabaseInit();
        dbInit.initialize();
        return true;
    }

    function onSessionStart() {
        session.isLoggedIn = false;
        session.userId = 0;
        session.userEmail = "";
        session.displayName = "";
        session.csrfToken = hash(createUUID() & now(), "SHA-256");
    }

    function onRequestStart(targetPage) {
        // Allow reinit via URL param
        if (structKeyExists(url, "reinit")) {
            onApplicationStart();
        }

        // Determine if this is a public page (no auth required)
        var publicPages = ["/index.cfm", "/views/auth/login.cfm", "/views/auth/signup.cfm", "/views/auth/recovery.cfm"];
        var publicAPIs = ["/api/auth.cfm"];
        var requestedPage = arguments.targetPage;

        var isPublic = false;
        for (var pg in publicPages) {
            if (requestedPage contains pg) { isPublic = true; break; }
        }
        for (var pg in publicAPIs) {
            if (requestedPage contains pg) { isPublic = true; break; }
        }

        // Redirect to login if not authenticated and not on public page
        if (!isPublic && (!structKeyExists(session, "isLoggedIn") || !session.isLoggedIn)) {
            location(url="/index.cfm", addtoken=false);
            return false;
        }

        return true;
    }

    function onError(exception, eventName) {
        if (structKeyExists(url, "format") && url.format == "json") {
            cfheader(name="Content-Type", value="application/json");
            writeOutput(serializeJSON({ "success": false, "message": exception.message }));
        } else {
            include "/views/auth/login.cfm";
        }
    }

}
