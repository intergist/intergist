# TaskForge — Task & Project Manager

A full-featured task and project management web application built on **ColdFusion (CFML)** with a modern Bootstrap 5 frontend.

![ColdFusion](https://img.shields.io/badge/ColdFusion-CFML-blue)
![Bootstrap](https://img.shields.io/badge/Bootstrap-5.3-purple)
![License](https://img.shields.io/badge/License-MIT-green)

---

## Features

- **Dashboard** — Summary cards (total tasks, in-progress, completed, team size), Chart.js doughnut for task status distribution, recent activity feed
- **Task Management** — Full CRUD with DataTables (sorting, searching, pagination), inline status/priority badges, Chosen multi-select for assignees, filter by status/priority/project
- **Project Management** — Card-based grid layout, progress bars with completion %, status & priority badges, manager assignment, deadline tracking
- **Team Members** — DataTables-powered directory, avatar initials with color coding, role management, add/edit/delete members
- **Activity Log** — Automatic activity tracking across all entities

## Tech Stack

| Layer      | Technology                                                    |
|------------|---------------------------------------------------------------|
| Backend    | ColdFusion (CFML) — engine-agnostic (Lucee 5+ / Adobe CF 2018+) |
| Database   | Microsoft SQL Server (production) · H2 embedded (demo/dev)    |
| Frontend   | Bootstrap 5.3.3, jQuery 3.7.1, Font Awesome 6.5.1            |
| Data Grid  | DataTables 1.13.8 with Bootstrap 5 integration                |
| Selects    | Chosen 1.8.7                                                  |
| Charts     | Chart.js 4.4.1                                                |
| Typography | Inter (Google Fonts)                                          |

## Project Structure

```
taskforge/
├── Application.cfc              # App config, datasource, mappings
├── index.cfm                    # Dashboard page
├── server.json                  # CommandBox server config
├── box.json                     # CommandBox package descriptor
│
├── api/                         # JSON API endpoints
│   ├── dashboard.cfm            # GET /api/dashboard.cfm
│   ├── tasks.cfm                # GET|POST|PUT|DELETE /api/tasks.cfm
│   ├── projects.cfm             # GET|POST|PUT|DELETE /api/projects.cfm
│   └── team.cfm                 # GET|POST|PUT|DELETE /api/team.cfm
│
├── model/                       # Service layer (business logic)
│   ├── TaskService.cfc
│   ├── ProjectService.cfc
│   ├── TeamMemberService.cfc
│   └── ActivityService.cfc
│
├── components/                  # Utility components
│   └── DatabaseInit.cfc         # Auto-creates schema & seeds demo data
│
├── views/
│   ├── layouts/
│   │   └── main.cfm             # Shared layout (sidebar, header, CDN includes)
│   ├── tasks/
│   │   └── list.cfm             # Tasks page
│   ├── projects/
│   │   └── list.cfm             # Projects page
│   └── team/
│       └── list.cfm             # Team page
│
├── assets/
│   ├── css/
│   │   └── taskforge.css        # Custom styles
│   └── js/
│       └── taskforge.js         # Shared JS utilities
│
└── sql/
    ├── mssql_schema.sql         # Production MSSQL DDL + seed data
    └── h2_schema.sql            # H2-compatible schema for demo
```

## Quick Start (CommandBox / Lucee)

### Prerequisites
- [CommandBox](https://www.ortussolutions.com/products/commandbox) 5.x+

### Run Locally
```bash
# Clone the repository
git clone https://github.com/intergist/intergist.git
cd intergist/taskforge

# Start the server (Lucee 5, port 5000)
box server start
```

The app auto-initializes an embedded H2 database with sample data on first run. Open [http://localhost:5000](http://localhost:5000) to view the dashboard.

### Configuration

**H2 (Demo/Development)** — zero-config, works out of the box. The `Application.cfc` registers an H2 datasource and `DatabaseInit.cfc` auto-creates tables + seed data.

**Microsoft SQL Server (Production)** — run `sql/mssql_schema.sql` against your MSSQL instance, then update the datasource in `Application.cfc`:

```cfml
this.datasources["taskforge"] = {
    class: "com.microsoft.sqlserver.jdbc.SQLServerDriver",
    connectionString: "jdbc:sqlserver://HOST:1433;databaseName=TaskForge;",
    username: "your_user",
    password: "your_password"
};
```

## Database Schema

Five normalized tables:

| Table             | Purpose                        |
|-------------------|--------------------------------|
| `team_members`    | Users / team directory         |
| `projects`        | Project definitions            |
| `tasks`           | Task items with FK to project  |
| `task_assignees`  | Many-to-many task ↔ member     |
| `activity_log`    | Chronological activity stream  |

See `sql/mssql_schema.sql` for the full DDL with indexes and foreign keys.

## API Endpoints

All endpoints return JSON. Use `action` query parameter for mutations.

| Method | Endpoint              | Description              |
|--------|-----------------------|--------------------------|
| GET    | `/api/dashboard.cfm`  | Aggregate stats + chart data |
| GET    | `/api/tasks.cfm`      | List tasks (with filters)    |
| POST   | `/api/tasks.cfm?action=create` | Create task        |
| POST   | `/api/tasks.cfm?action=update` | Update task        |
| POST   | `/api/tasks.cfm?action=delete` | Delete task        |
| GET    | `/api/projects.cfm`   | List projects              |
| POST   | `/api/projects.cfm?action=create` | Create project  |
| POST   | `/api/projects.cfm?action=update` | Update project  |
| POST   | `/api/projects.cfm?action=delete` | Delete project  |
| GET    | `/api/team.cfm`       | List team members          |
| POST   | `/api/team.cfm?action=create` | Add member         |
| POST   | `/api/team.cfm?action=update` | Update member      |
| POST   | `/api/team.cfm?action=delete` | Remove member      |

## Screenshots

### Dashboard
Summary statistics, task status chart, and recent activity feed.

### Tasks
DataTables grid with status/priority badges, Chosen multi-select filters.

### Projects
Card layout with progress tracking, status indicators, and manager assignments.

### Team
Searchable directory with avatar initials and role management.

## License

MIT

---

*Built with [Perplexity Computer](https://perplexity.ai) · TaskForge © 2026*
