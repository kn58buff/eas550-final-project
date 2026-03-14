-- Add RBAC using 2 roles: analyst and app user
-- Analyst: SELECT, App User: SELECT, INSERT, UPDATE
-- SELECT rolname
-- FROM pg_roles



GRANT SELECT ON ALL TABLES IN SCHEMA public TO analyst;

-- App user: application read/write
-- App/admin user: read and write
GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA public
TO app_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO analyst;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_user;