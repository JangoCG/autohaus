# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GoAuftrag Autohaus is a Rails 8.1 application for a German car dealership (Autohaus) with a double-opt-in waitlist system. Built with Ruby 3.4.5, SQLite, Hotwire (Turbo + Stimulus), and Tailwind CSS.

## Common Commands

### Development
- `bin/setup` - Initial setup (installs dependencies, prepares DB, starts server)
- `bin/dev` - Start development server with Tailwind CSS watch (uses foreman)
- `bin/rails server` - Start Rails server only

### Testing
- `bin/rails test` - Run all unit/integration tests
- `bin/rails test:system` - Run system tests (Capybara + Selenium)
- `bin/rails test test/models/user_test.rb` - Run specific test file
- `bin/rails test test/models/user_test.rb:10` - Run test by line number

### Linting & Security
- `bin/rubocop` - Run RuboCop linter (rubocop-rails-omakase style)
- `bin/rubocop -a` - Auto-fix linting issues
- `bin/brakeman` - Static security analysis
- `bin/bundler-audit` - Check for vulnerable gem versions
- `bin/ci` - Run complete CI pipeline locally

### Database
- `bin/rails db:prepare` - Create and migrate database
- `bin/rails db:migrate` - Run pending migrations

### Deployment
- `kamal deploy` - Deploy via Docker/Kamal
- `kamal console` - Access production Rails console

## Architecture

### Stack
- **Asset Pipeline**: Propshaft (Rails 8 default)
- **JavaScript**: Import maps with Turbo and Stimulus
- **CSS**: Tailwind CSS v4 (compiled via `tailwindcss-rails`)
- **Background Jobs**: Solid Queue (SQLite-backed)
- **Caching**: Solid Cache (SQLite-backed)
- **WebSockets**: Solid Cable (SQLite-backed)
- **Deployment**: Kamal with Docker, Thruster for HTTP acceleration

### Key Features

**Double-Opt-In Waitlist System**
- `WaitlistEntry` - Stores email signups with consent tracking
- `ConfirmationToken` - 24-hour expiring tokens (format: XXXX-XXXX-XXXX)
- Flow: signup → email with token → confirm via link → marked confirmed

**Authentication & Authorization**
- `Authentication` concern - Session-based auth via `Current.user`
- `Authorization` concern - Admin check via `ensure_admin` before_action
- Admin panel at `/admin` requires `User.admin?`

### Routes Structure
- `/` - Landing page (pages#home)
- `/waitlist` - POST signup, `/waitlist/confirm/:token` - GET confirmation
- `/admin` - Admin dashboard (waitlist stats)
- `/impressum`, `/datenschutz` - Legal pages (German)
- `/session` - Authentication

### Frontend Structure
- Shared partials in `app/views/shared/` (_navbar, _footer, _company_logo)
- Stimulus controllers in `app/javascript/controllers/`
- Uses `@tailwindplus/elements` for interactive components (mobile menu dialog)
- Color scheme: sky/blue accents (sky-400, sky-500, sky-600)

### Email
- `letter_opener` gem in development - emails open in browser
- `WaitlistMailer` sends confirmation requests
