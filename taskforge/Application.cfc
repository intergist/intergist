component {

    this.name = "TaskForge";
    this.applicationTimeout = createTimeSpan(1, 0, 0, 0);
    this.sessionManagement = true;
    this.sessionTimeout = createTimeSpan(0, 2, 0, 0);

    // Mappings
    this.mappings["/components"] = getDirectoryFromPath(getCurrentTemplatePath()) & "components";
    this.mappings["/model"]      = getDirectoryFromPath(getCurrentTemplatePath()) & "model";
    this.mappings["/api"]        = getDirectoryFromPath(getCurrentTemplatePath()) & "api";

    // Custom tag paths for <cf_main> layout tag
    this.customTagPaths = getDirectoryFromPath(getCurrentTemplatePath()) & "views/layouts";

    // H2 embedded datasource for demo; swap for MSSQL in production
    this.datasources["taskforgeDB"] = {
        class: "org.h2.Driver",
        connectionString: "jdbc:h2:#getDirectoryFromPath(getCurrentTemplatePath())#data/taskforge;MODE=MSSQLServer;AUTO_SERVER=TRUE"
    };
    this.defaultdatasource = "taskforgeDB";

    function onApplicationStart() {
        // Initialize database schema on first run
        var dbInit = new components.DatabaseInit();
        dbInit.initialize();
        return true;
    }

    function onRequestStart(targetPage) {
        // Allow reinit via URL param
        if (structKeyExists(url, "reinit")) {
            onApplicationStart();
        }
        return true;
    }

    function onError(exception, eventName) {
        writeDump(var=exception, label="Application Error");
    }

}
