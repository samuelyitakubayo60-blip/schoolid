# Deployment guide

## Render
- Provision PostgreSQL and copy its external connection host, port, database, username and password.
- Deploy this repository as a Docker web service.
- Add the environment variables shown in `.env.example` to Render. `DB_SSLMODE=require` is normally appropriate for managed hosted PostgreSQL.
- Set a strong unique `OWNER_PASSWORD`; do not use the example value.
- Add Cloudinary credentials for persistent image uploads.
- Deploy and open `/login.php`. The database schema and first Platform Owner are created automatically when the app starts.

## Security checklist
- Keep secrets only in Render environment variables.
- Enable HTTPS (Render provides HTTPS for its service domain).
- Use a strong owner password and rotate credentials that have ever been shared.
- Restrict database network access where the provider supports it.
- Configure database backups and retention.
- Test Director, DOS, Patron and Matron accounts with separate test schools before using real student records.

## Local Docker
Run `docker compose up --build`; open `http://localhost:8080`. Change the example owner and database credentials before exposing this service publicly.
