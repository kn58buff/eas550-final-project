-- Add RBAC using 2 roles: analyst and app user
-- Analyst: SELECT, App User: SELECT, INSERT, UPDATE
-- SELECT rolname
-- FROM pg_roles


grant select on all tables in schema public to analyst;

-- App user: application read/write
-- App/admin user: read and write
grant select, insert, update, delete
on all tables in schema public
to app_user;

alter default privileges in schema public
grant select on tables to analyst;

alter default privileges in schema public
grant select, insert, update, delete on tables to app_user;
