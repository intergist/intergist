-- ═══════════════════════════════════════════════════════════════
--  Polyculy Seed Data
--  Password for all demo users: "demo123"
--  Note: The actual hash is computed at runtime by Lucee's hash() function
--  in DatabaseInit.cfc. The hash below is the standard SHA-256 value but
--  Lucee produces a different hash. This file is for reference only.
-- ═══════════════════════════════════════════════════════════════

-- Users
INSERT INTO users (email, password_hash, display_name, avatar_url, timezone_id, calendar_created)
VALUES ('you@polyculy.app', '240BE518FABD2724DDB6F04EEB1DA5967448D7E831C08C8FA822809F74C720A9', 'You (Demo)', '', 'America/New_York', true);

INSERT INTO users (email, password_hash, display_name, avatar_url, timezone_id, calendar_created)
VALUES ('riley@polyculy.app', '240BE518FABD2724DDB6F04EEB1DA5967448D7E831C08C8FA822809F74C720A9', 'Riley', '', 'America/New_York', true);

INSERT INTO users (email, password_hash, display_name, avatar_url, timezone_id, calendar_created)
VALUES ('jamie@polyculy.app', '240BE518FABD2724DDB6F04EEB1DA5967448D7E831C08C8FA822809F74C720A9', 'Jamie', '', 'America/Chicago', true);

INSERT INTO users (email, password_hash, display_name, avatar_url, timezone_id, calendar_created)
VALUES ('alex@polyculy.app', '240BE518FABD2724DDB6F04EEB1DA5967448D7E831C08C8FA822809F74C720A9', 'Alex', '', 'America/Los_Angeles', true);

INSERT INTO users (email, password_hash, display_name, avatar_url, timezone_id, calendar_created)
VALUES ('casey@polyculy.app', '240BE518FABD2724DDB6F04EEB1DA5967448D7E831C08C8FA822809F74C720A9', 'Casey', '', 'America/Denver', false);

INSERT INTO users (email, password_hash, display_name, avatar_url, timezone_id, calendar_created)
VALUES ('morgan@polyculy.app', '240BE518FABD2724DDB6F04EEB1DA5967448D7E831C08C8FA822809F74C720A9', 'Morgan', '', 'Europe/London', true);

INSERT INTO users (email, password_hash, display_name, avatar_url, timezone_id, calendar_created)
VALUES ('sam@polyculy.app', '240BE518FABD2724DDB6F04EEB1DA5967448D7E831C08C8FA822809F74C720A9', 'Sam', '', 'America/New_York', true);

-- Licences
INSERT INTO licences (licence_code, licence_type, owner_user_id, redeemed_by_user_id, status, redeemed_at)
VALUES ('POLY-ALPHA-001', 'alpha', 1, 1, 'redeemed', CURRENT_TIMESTAMP);

INSERT INTO licences (licence_code, licence_type, owner_user_id, redeemed_by_user_id, status, redeemed_at)
VALUES ('POLY-ALPHA-002', 'alpha', 2, 2, 'redeemed', CURRENT_TIMESTAMP);

INSERT INTO licences (licence_code, licence_type, status)
VALUES ('POLY-BETA-005', 'beta', 'available');

INSERT INTO licences (licence_code, licence_type, status)
VALUES ('POLY-BETA-006', 'beta', 'available');

INSERT INTO licences (licence_code, licence_type, gifted_to_email, gifted_by_user_id, status)
VALUES ('POLY-GIFT-007', 'gifted', 'casey@polyculy.app', 1, 'gifted_pending');

-- Connections
INSERT INTO connections (user_id_1, user_id_2, status, initiated_by)
VALUES (1, 2, 'connected', 1);

INSERT INTO connections (user_id_1, user_id_2, status, initiated_by)
VALUES (1, 3, 'connected', 1);

INSERT INTO connections (user_id_1, user_id_2, status, initiated_by)
VALUES (1, 4, 'awaiting_confirmation', 1);

INSERT INTO connections (user_id_1, user_id_2, status, invited_email, invited_display_name, initiated_by)
VALUES (1, 5, 'licence_gifted_awaiting_signup', 'casey@polyculy.app', 'Casey', 1);

INSERT INTO connections (user_id_1, user_id_2, status, initiated_by)
VALUES (2, 3, 'connected', 2);

INSERT INTO connections (user_id_1, user_id_2, status, initiated_by)
VALUES (1, 6, 'connected', 1);

INSERT INTO connections (user_id_1, user_id_2, status, initiated_by)
VALUES (1, 7, 'revoked', 1);

-- Connection Display Preferences
INSERT INTO connection_display_preferences (user_id, target_user_id, nickname, calendar_color)
VALUES (1, 2, 'Ri', '#22C55E');

INSERT INTO connection_display_preferences (user_id, target_user_id, nickname, calendar_color)
VALUES (1, 3, 'Jay', '#3B82F6');

-- Personal Events
INSERT INTO personal_events (owner_user_id, title, start_time, end_time, timezone_id, event_details, address, visibility_tier)
VALUES (1, 'Therapy Session', DATEADD('DAY', 1, CURRENT_TIMESTAMP), DATEADD('MINUTE', 60, DATEADD('DAY', 1, CURRENT_TIMESTAMP)), 'America/New_York', 'Weekly therapy appointment', '123 Wellness Ave', 'full_details');

INSERT INTO personal_events (owner_user_id, title, start_time, end_time, timezone_id, event_details, visibility_tier)
VALUES (1, 'Personal Journaling', DATEADD('DAY', 2, CURRENT_TIMESTAMP), DATEADD('MINUTE', 30, DATEADD('DAY', 2, CURRENT_TIMESTAMP)), 'America/New_York', 'Morning journaling time', 'invisible');

-- Personal Event Visibility
INSERT INTO personal_event_visibility (event_id, target_user_id, visibility_type)
VALUES (1, 2, 'full_details');

INSERT INTO personal_event_visibility (event_id, target_user_id, visibility_type)
VALUES (1, 3, 'busy_block');

-- Shared Events
INSERT INTO shared_events (organizer_user_id, title, start_time, end_time, timezone_id, event_details, address, global_state)
VALUES (1, 'Game Night', DATEADD('DAY', 4, CURRENT_TIMESTAMP), DATEADD('HOUR', 3, DATEADD('DAY', 4, CURRENT_TIMESTAMP)), 'America/New_York', 'Board games and snacks!', 'Our Place', 'active');

INSERT INTO shared_events (organizer_user_id, title, start_time, end_time, timezone_id, event_details, global_state)
VALUES (2, 'Movie Marathon', DATEADD('DAY', 6, CURRENT_TIMESTAMP), DATEADD('HOUR', 5, DATEADD('DAY', 6, CURRENT_TIMESTAMP)), 'America/New_York', 'Studio Ghibli marathon', 'tentative');

-- Shared Event Participants
INSERT INTO shared_event_participants (shared_event_id, user_id, attendance_type, response_status)
VALUES (1, 1, 'required', 'accepted');

INSERT INTO shared_event_participants (shared_event_id, user_id, attendance_type, response_status)
VALUES (1, 2, 'required', 'accepted');

INSERT INTO shared_event_participants (shared_event_id, user_id, attendance_type, response_status)
VALUES (1, 3, 'optional', 'pending');

INSERT INTO shared_event_participants (shared_event_id, user_id, attendance_type, response_status)
VALUES (2, 2, 'required', 'accepted');

INSERT INTO shared_event_participants (shared_event_id, user_id, attendance_type, response_status)
VALUES (2, 1, 'required', 'pending');

-- Notifications
INSERT INTO notifications (user_id, notification_type, title, message, related_entity_type, related_entity_id)
VALUES (1, 'connection_accepted', 'Connection Accepted', 'Riley accepted your connection request.', 'connection', 1);

INSERT INTO notifications (user_id, notification_type, title, message, related_entity_type, related_entity_id)
VALUES (1, 'shared_event_invite', 'New Shared Event Invite', 'Riley invited you to Movie Marathon.', 'shared_event', 2);

-- Audit Log
INSERT INTO audit_log (actor_user_id, action_type, entity_type, entity_id, details)
VALUES (1, 'user_signup', 'user', 1, 'User You (Demo) signed up');

INSERT INTO audit_log (actor_user_id, action_type, entity_type, entity_id, details)
VALUES (1, 'connection_invite', 'connection', 1, 'Invited Riley to connect');

INSERT INTO audit_log (actor_user_id, action_type, entity_type, entity_id, details)
VALUES (1, 'event_create', 'shared_event', 1, 'Created shared event Game Night');
