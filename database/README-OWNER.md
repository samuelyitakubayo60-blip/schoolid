# Automatic Platform Owner setup

The application creates the first Platform Owner automatically during startup when these environment variables are present:

- `OWNER_NAME`
- `OWNER_EMAIL`
- `OWNER_PASSWORD`

Use a unique email address and a strong password of at least 16 characters. The password is hashed using PHP `password_hash()` before it is stored. The seed is idempotent: it does not create a duplicate account on later requests.

You do not need to manually run `seed_owner.sql` when deploying this version. That SQL file is retained only as a manual reference.
