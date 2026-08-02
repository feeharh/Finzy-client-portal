-- Seed default OWNER admin for local/MVP use.
-- Email: owner@finzy.com
-- Password: change-me  (change immediately in production)

INSERT INTO admin_users (
    id,
    first_name,
    last_name,
    email,
    password_hash,
    role,
    account_status,
    failed_login_attempts,
    created_at,
    updated_at
) VALUES (
    'a0000000-0000-4000-8000-000000000001',
    'Finzy',
    'Owner',
    'owner@finzy.com',
    '$2a$10$euvA19M8glc/hzwPXKaf3e5LM/NXG4Hhf10/o6iXdSTrc81f8UVlK',
    'OWNER',
    'ACTIVE',
    0,
    NOW(),
    NOW()
);
