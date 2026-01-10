# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Auftragsheld is a Rails 8.1 application using Ruby 3.4.5 with SQLite database, Hotwire (Turbo + Stimulus), and Tailwind CSS.

## Common Commands

### Development
- `bin/setup` - Initial setup (installs dependencies, prepares DB, starts server)
- `bin/dev` - Start development server with Tailwind CSS watch (uses foreman)
- `bin/rails server` - Start Rails server only

### Testing
- `bin/rails test` - Run all unit/integration tests
- `bin/rails test:system` - Run system tests (Capybara + Selenium)
- `bin/rails test test/models/user_test.rb` - Run a specific test file
- `bin/rails test test/models/user_test.rb:10` - Run a specific test by line number

### Linting & Security
- `bin/rubocop` - Run RuboCop linter (uses rubocop-rails-omakase style)
- `bin/rubocop -a` - Auto-fix linting issues
- `bin/brakeman` - Static security analysis
- `bin/bundler-audit` - Check for vulnerable gem versions
- `bin/importmap audit` - Check for JavaScript dependency vulnerabilities

### Full CI Suite
- `bin/ci` - Run complete CI pipeline locally (setup, lint, security scans, all tests)

### Database
- `bin/rails db:prepare` - Create and migrate database
- `bin/rails db:migrate` - Run pending migrations
- `bin/rails db:seed` - Seed the database

## Architecture

- **Asset Pipeline**: Propshaft (Rails 8 default)
- **JavaScript**: Import maps with Turbo and Stimulus
- **CSS**: Tailwind CSS (compiled via `tailwindcss-rails`)
- **Background Jobs**: Solid Queue (SQLite-backed)
- **Caching**: Solid Cache (SQLite-backed)
- **WebSockets**: Solid Cable (SQLite-backed)
- **Deployment**: Kamal with Docker, Thruster for HTTP acceleration
