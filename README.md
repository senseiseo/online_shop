# Online Shop

Rails 8 monolith bootstrap for a small shop. The public site has anonymous
visitors, not customer accounts; `User` will mean a staff member only.

## Current stage

Stage 2 adds Rails built-in staff authentication. `User` has `admin`, `editor`,
and `manager` roles; `/admin` requires an authenticated staff session. Sign in
is at `/session`; there is no customer registration or customer login.

ActiveAdmin remains Stage 5. It must use this `User` session, without Devise or
an `AdminUser` model.

## Setup

```sh
bin/setup
bin/dev
```

The project needs Ruby 3.4.x. This workspace uses Ruby 3.4.2 and Rails 8.1.4.

## Checks

```sh
bundle exec rspec
bin/rubocop
bin/brakeman --no-pager
bin/bundler-audit
```

CI runs RSpec, Tailwind compilation, RuboCop, Brakeman, bundler-audit, and
Importmap auditing.

## Constraints

The durable architectural rules are in [AGENTS.md](AGENTS.md).

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
