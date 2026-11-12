-- Generate a password hash using PHP password_hash() before running this file.
-- Replace the email and hash placeholders before executing.
INSERT INTO users (full_name, email, password_hash, is_platform_owner, status)
VALUES ('Platform Owner', 'owner@example.com', 'REPLACE_WITH_REAL_PASSWORD_HASH', TRUE, 'active');
