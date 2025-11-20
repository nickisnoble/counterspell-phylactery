# Phylactery

Rails 8 app for running tabletop events: manage players, events, seats, newsletters, and broadcast email. Uses Hotwire for the UI, Tailwind for styling, Resend for outbound mail, and Stripe webhooks to confirm paid seats.

## Stack
- Ruby 3.4.5, Rails 8, SQLite (default)
- Hotwire (Turbo/Stimulus), Tailwind via `tailwindcss-rails`
- Solid Queue/Cache/Cable
- Email: Resend (ActionMailer delivery method)
- Webhooks: Resend (`/resend/webhooks`), Stripe Checkout (`/stripe/webhooks`)

## Getting started
1. Install Ruby 3.4.5 (rbenv or asdf) and Bundler.
2. Install gems and prepare the database:
   ```bash
   bundle install
   bin/setup   # installs JS deps, creates/migrates DB, seeds minimal data
   ```
3. Run the app (Rails server + Tailwind watcher):
   ```bash
   bin/dev
   # or: bin/rails server & bin/rails tailwindcss:watch
   ```

## Configuration
Add secrets to `config/credentials.yml.enc` or export env vars before running the app. Required keys for real integrations:

- `RESEND_API_KEY` (or `rails credentials:edit` with `resend_api_key`) — send email.
- `RESEND_WEBHOOK_SECRET` — signing secret from Resend (starts with `whsec_`) to validate incoming webhooks.
- `STRIPE_SIGNING_SECRET` — Stripe webhook signing secret for Checkout events.
- Optional: `DATABASE_URL` (production), `AWS_*`/`BUCKET_NAME` (object storage), `WEB_CONCURRENCY`, `RAILS_MAX_THREADS`.

## Webhooks
### Resend
- Endpoint: `POST /resend/webhooks`
- Security: Requests must include `svix-id`, `svix-timestamp`, and `svix-signature` headers from Resend. The controller now verifies these against `RESEND_WEBHOOK_SECRET` before processing events (bounces/complaints flip `never_send_email`).
- Configure in the Resend dashboard by creating a webhook pointing to the endpoint and copy the signing secret (`whsec_...`) into your env/credentials.

### Stripe
- Endpoint: `POST /stripe/webhooks`
- Security: Validated with `STRIPE_SIGNING_SECRET`.
- Behavior: On `checkout.session.completed`, creates/updates a seat using the session metadata (`game_id`, `user_id`, `hero_id`).

## Testing
```bash
bin/rails test
```
Set `COVERAGE=1` to enable SimpleCov.

## Development notes
- Use `bin/rails console` for quick data inspection.
- Hotwire + importmap means no Node build is required; Tailwind is compiled via `tailwindcss-rails`.
- Foreman is installed automatically by `bin/dev` to run multi-process dev servers.
