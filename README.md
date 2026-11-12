# Multi-School Student ID Card Management Platform

PHP 8.3 + PostgreSQL 16 multi-school application. Each school has isolated records and staff memberships. Roles: Platform Owner, School Director, DOS, Patron and Matron.

## Features in this release
- Platform Owner creates schools and the first Director account.
- School Director manages staff, student records, classes and school card settings.
- DOS manages students and classes and can print cards.
- Patron and Matron can view and print only the classes assigned to their accounts.
- Student ID cards are generated on demand and receive unique verification tokens.
- Student CSV import and student editing are included.
- QR verification endpoint (`verify.php?token=...`).
- PostgreSQL schema is automatically installed on application startup.
- Platform Owner is automatically seeded from `OWNER_EMAIL`, `OWNER_PASSWORD`, and `OWNER_NAME` environment variables.
- Student photos and school logos use Cloudinary.

## Deploy on Render
1. Create a PostgreSQL database (Render PostgreSQL or another PostgreSQL provider).
2. Create a Render Web Service from this repository and use the included Dockerfile.
3. Set `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`, `DB_SSLMODE=require` from your database provider.
4. Set `OWNER_EMAIL`, `OWNER_PASSWORD` (at least 16 random characters), and `OWNER_NAME` in the web service environment. Set Cloudinary variables for photo uploads.
5. Deploy. The app creates missing tables and seeds the first Platform Owner on startup. The owner account is created only if that email does not already exist.
6. Open the service URL, sign in as Platform Owner, create a school and its Director account.

Never commit `.env` or expose database/Cloudinary credentials. Rotate any credentials previously shared in messages.

## Local Docker test
`docker compose up --build` then open `http://localhost:8080`. Local credentials are development-only and must be changed before any internet exposure. Set real Cloudinary credentials to test image upload.

## Role model
- Platform Owner: platform-wide school registration and oversight.
- Director: full school administration, staff management, student/class management and settings.
- DOS: student and class management, card printing.
- Patron/Matron: read-only access to assigned classes and card printing only.

## Important release limitations
This is a functional MVP foundation, not a certified production system. Before real student data is entered, complete end-to-end testing on your chosen PostgreSQL host, configure HTTPS and backups, add a password reset process and rate limiting, and review local student-data/privacy requirements. QR verification currently shows basic identity fields. The class card printing view is browser-printable; it does not yet produce a downloadable PDF or a fully configurable front/back card template. Bulk CSV import and full student edit/delete workflows are not enabled in this release.
