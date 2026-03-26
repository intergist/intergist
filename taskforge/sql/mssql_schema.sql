-- ============================================================
-- TaskForge - Task/Project Manager
-- MS SQL Server Schema DDL
-- ============================================================

-- Drop tables in reverse dependency order (idempotent)
IF OBJECT_ID('dbo.task_comments', 'U') IS NOT NULL DROP TABLE dbo.task_comments;
IF OBJECT_ID('dbo.activity_log', 'U') IS NOT NULL DROP TABLE dbo.activity_log;
IF OBJECT_ID('dbo.tasks', 'U') IS NOT NULL DROP TABLE dbo.tasks;
IF OBJECT_ID('dbo.projects', 'U') IS NOT NULL DROP TABLE dbo.projects;
IF OBJECT_ID('dbo.team_members', 'U') IS NOT NULL DROP TABLE dbo.team_members;

-- ============================================================
-- Team Members
-- ============================================================
CREATE TABLE dbo.team_members (
    member_id       INT IDENTITY(1,1) PRIMARY KEY,
    first_name      NVARCHAR(100) NOT NULL,
    last_name       NVARCHAR(100) NOT NULL,
    email           NVARCHAR(255) NOT NULL UNIQUE,
    role            NVARCHAR(50) NOT NULL DEFAULT 'Developer',
    avatar_color    NVARCHAR(7) NOT NULL DEFAULT '#4F46E5',
    is_active       BIT NOT NULL DEFAULT 1,
    created_at      DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at      DATETIME2 NOT NULL DEFAULT GETDATE()
);

-- ============================================================
-- Projects
-- ============================================================
CREATE TABLE dbo.projects (
    project_id      INT IDENTITY(1,1) PRIMARY KEY,
    project_name    NVARCHAR(200) NOT NULL,
    description     NVARCHAR(MAX),
    status          NVARCHAR(20) NOT NULL DEFAULT 'Active'
                    CHECK (status IN ('Active','On Hold','Completed','Archived')),
    priority        NVARCHAR(10) NOT NULL DEFAULT 'Medium'
                    CHECK (priority IN ('Low','Medium','High','Critical')),
    owner_id        INT NULL REFERENCES dbo.team_members(member_id),
    start_date      DATE NULL,
    due_date        DATE NULL,
    created_at      DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at      DATETIME2 NOT NULL DEFAULT GETDATE()
);

-- ============================================================
-- Tasks
-- ============================================================
CREATE TABLE dbo.tasks (
    task_id         INT IDENTITY(1,1) PRIMARY KEY,
    project_id      INT NOT NULL REFERENCES dbo.projects(project_id),
    title           NVARCHAR(300) NOT NULL,
    description     NVARCHAR(MAX),
    status          NVARCHAR(20) NOT NULL DEFAULT 'To Do'
                    CHECK (status IN ('To Do','In Progress','In Review','Done','Blocked')),
    priority        NVARCHAR(10) NOT NULL DEFAULT 'Medium'
                    CHECK (priority IN ('Low','Medium','High','Critical')),
    assigned_to     INT NULL REFERENCES dbo.team_members(member_id),
    due_date        DATE NULL,
    estimated_hours DECIMAL(6,2) NULL,
    actual_hours    DECIMAL(6,2) NULL,
    tags            NVARCHAR(500) NULL,
    created_at      DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at      DATETIME2 NOT NULL DEFAULT GETDATE()
);

-- ============================================================
-- Task Comments
-- ============================================================
CREATE TABLE dbo.task_comments (
    comment_id      INT IDENTITY(1,1) PRIMARY KEY,
    task_id         INT NOT NULL REFERENCES dbo.tasks(task_id) ON DELETE CASCADE,
    author_id       INT NOT NULL REFERENCES dbo.team_members(member_id),
    comment_text    NVARCHAR(MAX) NOT NULL,
    created_at      DATETIME2 NOT NULL DEFAULT GETDATE()
);

-- ============================================================
-- Activity Log
-- ============================================================
CREATE TABLE dbo.activity_log (
    log_id          INT IDENTITY(1,1) PRIMARY KEY,
    entity_type     NVARCHAR(20) NOT NULL,
    entity_id       INT NOT NULL,
    action          NVARCHAR(50) NOT NULL,
    description     NVARCHAR(500) NOT NULL,
    actor_id        INT NULL REFERENCES dbo.team_members(member_id),
    created_at      DATETIME2 NOT NULL DEFAULT GETDATE()
);

-- ============================================================
-- Indexes
-- ============================================================
CREATE INDEX IX_tasks_project_id ON dbo.tasks(project_id);
CREATE INDEX IX_tasks_assigned_to ON dbo.tasks(assigned_to);
CREATE INDEX IX_tasks_status ON dbo.tasks(status);
CREATE INDEX IX_tasks_priority ON dbo.tasks(priority);
CREATE INDEX IX_task_comments_task_id ON dbo.task_comments(task_id);
CREATE INDEX IX_activity_log_entity ON dbo.activity_log(entity_type, entity_id);
CREATE INDEX IX_activity_log_created ON dbo.activity_log(created_at DESC);
CREATE INDEX IX_projects_status ON dbo.projects(status);

-- ============================================================
-- Seed Data
-- ============================================================
SET IDENTITY_INSERT dbo.team_members ON;
INSERT INTO dbo.team_members (member_id, first_name, last_name, email, role, avatar_color) VALUES
(1, 'Alex', 'Morgan', 'alex.morgan@taskforge.dev', 'Project Lead', '#4F46E5'),
(2, 'Sam', 'Rivera', 'sam.rivera@taskforge.dev', 'Senior Developer', '#059669'),
(3, 'Jordan', 'Lee', 'jordan.lee@taskforge.dev', 'Developer', '#D97706'),
(4, 'Casey', 'Chen', 'casey.chen@taskforge.dev', 'QA Engineer', '#DC2626'),
(5, 'Taylor', 'Kim', 'taylor.kim@taskforge.dev', 'Designer', '#7C3AED');
SET IDENTITY_INSERT dbo.team_members OFF;

SET IDENTITY_INSERT dbo.projects ON;
INSERT INTO dbo.projects (project_id, project_name, description, status, priority, owner_id, start_date, due_date) VALUES
(1, 'API Platform v2', 'Redesign the public API with OpenAPI 3.1 spec, rate limiting, and webhook support.', 'Active', 'High', 1, '2026-01-15', '2026-06-30'),
(2, 'Mobile App Refresh', 'Modernize the mobile app with new UI kit and offline-first architecture.', 'Active', 'Medium', 2, '2026-02-01', '2026-08-15'),
(3, 'Data Pipeline Migration', 'Migrate ETL pipelines from legacy batch to streaming with Kafka.', 'On Hold', 'Critical', 1, '2026-03-01', '2026-09-30'),
(4, 'Design System 2.0', 'Unify component library across web and mobile with Figma tokens.', 'Active', 'Medium', 5, '2026-02-15', '2026-05-31');
SET IDENTITY_INSERT dbo.projects OFF;

SET IDENTITY_INSERT dbo.tasks ON;
INSERT INTO dbo.tasks (task_id, project_id, title, description, status, priority, assigned_to, due_date, estimated_hours, tags) VALUES
(1, 1, 'Define OpenAPI 3.1 base schema', 'Create the foundational OpenAPI document with shared components, security schemes, and server definitions.', 'Done', 'High', 1, '2026-02-15', 16.00, 'api,schema,documentation'),
(2, 1, 'Implement rate limiting middleware', 'Add token-bucket rate limiter with configurable limits per API key tier.', 'In Progress', 'High', 2, '2026-04-01', 24.00, 'api,middleware,security'),
(3, 1, 'Build webhook delivery system', 'Event-driven webhook dispatcher with retry logic and dead-letter queue.', 'To Do', 'Medium', 3, '2026-05-15', 40.00, 'api,webhooks,events'),
(4, 1, 'API documentation portal', 'Interactive Swagger UI portal with try-it-out and code samples.', 'To Do', 'Low', NULL, '2026-06-01', 20.00, 'api,documentation,frontend'),
(5, 2, 'Design new navigation patterns', 'Prototype bottom-nav, gesture nav, and tab-bar patterns for user testing.', 'In Review', 'Medium', 5, '2026-03-15', 12.00, 'mobile,ux,design'),
(6, 2, 'Implement offline data sync', 'Build conflict-resolution layer for offline-first CRUD with SQLite backing store.', 'In Progress', 'High', 2, '2026-05-01', 60.00, 'mobile,sync,database'),
(7, 2, 'Push notification service', 'Integrate FCM/APNs with segmented targeting and A/B message testing.', 'To Do', 'Medium', 3, '2026-06-15', 32.00, 'mobile,notifications'),
(8, 3, 'Kafka cluster provisioning', 'Set up 3-broker Kafka cluster with Schema Registry and topic ACLs.', 'Blocked', 'Critical', 2, '2026-04-15', 20.00, 'infrastructure,kafka,devops'),
(9, 3, 'Stream processor POC', 'Proof-of-concept Kafka Streams app converting legacy batch job to real-time.', 'To Do', 'High', 3, '2026-05-30', 40.00, 'kafka,streaming,poc'),
(10, 4, 'Component audit spreadsheet', 'Catalog all existing components across web and mobile with usage frequency.', 'Done', 'Medium', 5, '2026-03-01', 8.00, 'design,audit,components'),
(11, 4, 'Figma token export pipeline', 'Automate design-token export from Figma to CSS custom properties and Swift/Kotlin constants.', 'In Progress', 'Medium', 5, '2026-04-15', 24.00, 'design,tokens,automation'),
(12, 4, 'Button and input component specs', 'Define states, sizes, variants, and accessibility requirements for base interactive components.', 'To Do', 'Low', 5, '2026-05-01', 16.00, 'design,components,a11y');
SET IDENTITY_INSERT dbo.tasks OFF;

SET IDENTITY_INSERT dbo.task_comments ON;
INSERT INTO dbo.task_comments (comment_id, task_id, author_id, comment_text) VALUES
(1, 2, 1, 'Let''s use a sliding-window counter algorithm — cleaner than token bucket for our burst patterns.'),
(2, 2, 2, 'Agreed. I''ll prototype both and benchmark. Will share results by Friday.'),
(3, 6, 2, 'Looking at CRDTs for conflict resolution. The Yjs library has a good TypeScript implementation.'),
(4, 8, 2, 'Blocked on infrastructure approval. Waiting on VP sign-off for the Kafka cluster budget.'),
(5, 5, 1, 'The gesture-nav prototype feels really smooth. Let''s go with that for the next user test.');
SET IDENTITY_INSERT dbo.task_comments OFF;

SET IDENTITY_INSERT dbo.activity_log ON;
INSERT INTO dbo.activity_log (log_id, entity_type, entity_id, action, description, actor_id) VALUES
(1, 'task', 1, 'status_change', 'Task "Define OpenAPI 3.1 base schema" moved to Done', 1),
(2, 'task', 2, 'status_change', 'Task "Implement rate limiting middleware" moved to In Progress', 2),
(3, 'project', 3, 'status_change', 'Project "Data Pipeline Migration" set to On Hold', 1),
(4, 'task', 10, 'status_change', 'Task "Component audit spreadsheet" moved to Done', 5),
(5, 'task', 5, 'status_change', 'Task "Design new navigation patterns" moved to In Review', 5),
(6, 'task', 6, 'comment', 'Sam Rivera commented on "Implement offline data sync"', 2),
(7, 'task', 8, 'status_change', 'Task "Kafka cluster provisioning" moved to Blocked', 2),
(8, 'project', 1, 'created', 'Project "API Platform v2" created', 1),
(9, 'project', 2, 'created', 'Project "Mobile App Refresh" created', 2),
(10, 'task', 11, 'status_change', 'Task "Figma token export pipeline" moved to In Progress', 5);
SET IDENTITY_INSERT dbo.activity_log OFF;

PRINT 'TaskForge schema and seed data created successfully.';
GO
