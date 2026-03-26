-- ============================================================
-- TaskForge - H2 Database Schema (Demo/Sandbox)
-- Compatible with Lucee embedded H2 datasource
-- ============================================================

DROP TABLE IF EXISTS task_comments;
DROP TABLE IF EXISTS activity_log;
DROP TABLE IF EXISTS tasks;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS team_members;

-- ============================================================
-- Team Members
-- ============================================================
CREATE TABLE team_members (
    member_id       INT AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(100) NOT NULL,
    last_name       VARCHAR(100) NOT NULL,
    email           VARCHAR(255) NOT NULL UNIQUE,
    role            VARCHAR(50) NOT NULL DEFAULT 'Developer',
    avatar_color    VARCHAR(7) NOT NULL DEFAULT '#4F46E5',
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- Projects
-- ============================================================
CREATE TABLE projects (
    project_id      INT AUTO_INCREMENT PRIMARY KEY,
    project_name    VARCHAR(200) NOT NULL,
    description     CLOB,
    status          VARCHAR(20) NOT NULL DEFAULT 'Active',
    priority        VARCHAR(10) NOT NULL DEFAULT 'Medium',
    owner_id        INT NULL,
    start_date      DATE NULL,
    due_date        DATE NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_project_owner FOREIGN KEY (owner_id) REFERENCES team_members(member_id)
);

-- ============================================================
-- Tasks
-- ============================================================
CREATE TABLE tasks (
    task_id         INT AUTO_INCREMENT PRIMARY KEY,
    project_id      INT NOT NULL,
    title           VARCHAR(300) NOT NULL,
    description     CLOB,
    status          VARCHAR(20) NOT NULL DEFAULT 'To Do',
    priority        VARCHAR(10) NOT NULL DEFAULT 'Medium',
    assigned_to     INT NULL,
    due_date        DATE NULL,
    estimated_hours DECIMAL(6,2) NULL,
    actual_hours    DECIMAL(6,2) NULL,
    tags            VARCHAR(500) NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_task_project FOREIGN KEY (project_id) REFERENCES projects(project_id),
    CONSTRAINT fk_task_assignee FOREIGN KEY (assigned_to) REFERENCES team_members(member_id)
);

-- ============================================================
-- Task Comments
-- ============================================================
CREATE TABLE task_comments (
    comment_id      INT AUTO_INCREMENT PRIMARY KEY,
    task_id         INT NOT NULL,
    author_id       INT NOT NULL,
    comment_text    CLOB NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_comment_task FOREIGN KEY (task_id) REFERENCES tasks(task_id) ON DELETE CASCADE,
    CONSTRAINT fk_comment_author FOREIGN KEY (author_id) REFERENCES team_members(member_id)
);

-- ============================================================
-- Activity Log
-- ============================================================
CREATE TABLE activity_log (
    log_id          INT AUTO_INCREMENT PRIMARY KEY,
    entity_type     VARCHAR(20) NOT NULL,
    entity_id       INT NOT NULL,
    action          VARCHAR(50) NOT NULL,
    description     VARCHAR(500) NOT NULL,
    actor_id        INT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_log_actor FOREIGN KEY (actor_id) REFERENCES team_members(member_id)
);

-- ============================================================
-- Indexes
-- ============================================================
CREATE INDEX IX_tasks_project_id ON tasks(project_id);
CREATE INDEX IX_tasks_assigned_to ON tasks(assigned_to);
CREATE INDEX IX_tasks_status ON tasks(status);
CREATE INDEX IX_tasks_priority ON tasks(priority);
CREATE INDEX IX_task_comments_task_id ON task_comments(task_id);
CREATE INDEX IX_activity_log_entity ON activity_log(entity_type, entity_id);
CREATE INDEX IX_activity_log_created ON activity_log(created_at DESC);
CREATE INDEX IX_projects_status ON projects(status);

-- ============================================================
-- Seed Data
-- ============================================================
INSERT INTO team_members (first_name, last_name, email, role, avatar_color) VALUES
('Alex', 'Morgan', 'alex.morgan@taskforge.dev', 'Project Lead', '#4F46E5'),
('Sam', 'Rivera', 'sam.rivera@taskforge.dev', 'Senior Developer', '#059669'),
('Jordan', 'Lee', 'jordan.lee@taskforge.dev', 'Developer', '#D97706'),
('Casey', 'Chen', 'casey.chen@taskforge.dev', 'QA Engineer', '#DC2626'),
('Taylor', 'Kim', 'taylor.kim@taskforge.dev', 'Designer', '#7C3AED');

INSERT INTO projects (project_name, description, status, priority, owner_id, start_date, due_date) VALUES
('API Platform v2', 'Redesign the public API with OpenAPI 3.1 spec, rate limiting, and webhook support.', 'Active', 'High', 1, '2026-01-15', '2026-06-30'),
('Mobile App Refresh', 'Modernize the mobile app with new UI kit and offline-first architecture.', 'Active', 'Medium', 2, '2026-02-01', '2026-08-15'),
('Data Pipeline Migration', 'Migrate ETL pipelines from legacy batch to streaming with Kafka.', 'On Hold', 'Critical', 1, '2026-03-01', '2026-09-30'),
('Design System 2.0', 'Unify component library across web and mobile with Figma tokens.', 'Active', 'Medium', 5, '2026-02-15', '2026-05-31');

INSERT INTO tasks (project_id, title, description, status, priority, assigned_to, due_date, estimated_hours, tags) VALUES
(1, 'Define OpenAPI 3.1 base schema', 'Create the foundational OpenAPI document with shared components, security schemes, and server definitions.', 'Done', 'High', 1, '2026-02-15', 16.00, 'api,schema,documentation'),
(1, 'Implement rate limiting middleware', 'Add token-bucket rate limiter with configurable limits per API key tier.', 'In Progress', 'High', 2, '2026-04-01', 24.00, 'api,middleware,security'),
(1, 'Build webhook delivery system', 'Event-driven webhook dispatcher with retry logic and dead-letter queue.', 'To Do', 'Medium', 3, '2026-05-15', 40.00, 'api,webhooks,events'),
(1, 'API documentation portal', 'Interactive Swagger UI portal with try-it-out and code samples.', 'To Do', 'Low', NULL, '2026-06-01', 20.00, 'api,documentation,frontend'),
(2, 'Design new navigation patterns', 'Prototype bottom-nav, gesture nav, and tab-bar patterns for user testing.', 'In Review', 'Medium', 5, '2026-03-15', 12.00, 'mobile,ux,design'),
(2, 'Implement offline data sync', 'Build conflict-resolution layer for offline-first CRUD with SQLite backing store.', 'In Progress', 'High', 2, '2026-05-01', 60.00, 'mobile,sync,database'),
(2, 'Push notification service', 'Integrate FCM/APNs with segmented targeting and A/B message testing.', 'To Do', 'Medium', 3, '2026-06-15', 32.00, 'mobile,notifications'),
(3, 'Kafka cluster provisioning', 'Set up 3-broker Kafka cluster with Schema Registry and topic ACLs.', 'Blocked', 'Critical', 2, '2026-04-15', 20.00, 'infrastructure,kafka,devops'),
(3, 'Stream processor POC', 'Proof-of-concept Kafka Streams app converting legacy batch job to real-time.', 'To Do', 'High', 3, '2026-05-30', 40.00, 'kafka,streaming,poc'),
(4, 'Component audit spreadsheet', 'Catalog all existing components across web and mobile with usage frequency.', 'Done', 'Medium', 5, '2026-03-01', 8.00, 'design,audit,components'),
(4, 'Figma token export pipeline', 'Automate design-token export from Figma to CSS custom properties and Swift/Kotlin constants.', 'In Progress', 'Medium', 5, '2026-04-15', 24.00, 'design,tokens,automation'),
(4, 'Button and input component specs', 'Define states, sizes, variants, and accessibility requirements for base interactive components.', 'To Do', 'Low', 5, '2026-05-01', 16.00, 'design,components,a11y');

INSERT INTO task_comments (task_id, author_id, comment_text) VALUES
(2, 1, 'Let''s use a sliding-window counter algorithm - cleaner than token bucket for our burst patterns.'),
(2, 2, 'Agreed. I''ll prototype both and benchmark. Will share results by Friday.'),
(6, 2, 'Looking at CRDTs for conflict resolution. The Yjs library has a good TypeScript implementation.'),
(8, 2, 'Blocked on infrastructure approval. Waiting on VP sign-off for the Kafka cluster budget.'),
(5, 1, 'The gesture-nav prototype feels really smooth. Let''s go with that for the next user test.');

INSERT INTO activity_log (entity_type, entity_id, action, description, actor_id) VALUES
('task', 1, 'status_change', 'Task "Define OpenAPI 3.1 base schema" moved to Done', 1),
('task', 2, 'status_change', 'Task "Implement rate limiting middleware" moved to In Progress', 2),
('project', 3, 'status_change', 'Project "Data Pipeline Migration" set to On Hold', 1),
('task', 10, 'status_change', 'Task "Component audit spreadsheet" moved to Done', 5),
('task', 5, 'status_change', 'Task "Design new navigation patterns" moved to In Review', 5),
('task', 6, 'comment', 'Sam Rivera commented on "Implement offline data sync"', 2),
('task', 8, 'status_change', 'Task "Kafka cluster provisioning" moved to Blocked', 2),
('project', 1, 'created', 'Project "API Platform v2" created', 1),
('project', 2, 'created', 'Project "Mobile App Refresh" created', 2),
('task', 11, 'status_change', 'Task "Figma token export pipeline" moved to In Progress', 5);
