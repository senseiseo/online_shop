# Online Shop

Rails 8 monolith bootstrap for a small shop. The public site has anonymous
visitors, not customer accounts; `User` will mean a staff member only.

## Current stage

Stage 1 configures Rails 8.1, Ruby 3.4, SQLite, ERB, Propshaft, Importmap,
Hotwire, Tailwind, Solid Cache/Cable, RSpec, FactoryBot, and baseline CI checks.
The domain models, authentication, admin, catalogue, cart, checkout, content,
and deployment are deliberately future stages.

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
