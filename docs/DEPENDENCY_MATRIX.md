# Dependency matrix

Stage 1 uses Rails 8.1.4 application defaults. Exact resolved versions are in
`Gemfile.lock`.

| Component | Selection | Reason |
| --- | --- | --- |
| Ruby | 3.4.2 | Installed locally; satisfies the Ruby 3.4.x target. |
| Rails | `~> 8.1.3` (resolved 8.1.4) | Rails monolith framework. |
| SQLite | `sqlite3 >= 2.1` | Rails default and the production database choice. |
| Propshaft | Rails default | Asset pipeline without Sprockets configuration. |
| Importmap | Rails default | Browser-native modules without a Node build service. |
| Turbo / Stimulus | Rails defaults | Hotwire UX without an SPA. |
| Tailwind | `tailwindcss-rails` | Rails-supported Tailwind integration. |
| Solid Cache / Cable | Rails defaults | Database-backed Rails adapters; no Redis. |
| RSpec / FactoryBot | `rspec-rails`, `factory_bot_rails` | Requested Rails test stack and concise test data. |
| FriendlyId | `5.7.0` | Human-readable Product, Category, and Post URLs. |
| Pagy | `43.7.0` | Catalog and post pagination. |
| RuboCop / Brakeman / bundler-audit | Rails defaults plus `rubocop-rspec` | Style and security checks; RSpec coverage. |

## Catalog gem compatibility

On 2026-10-03, Ruby 3.4.2 / Rails 8.1.4 loaded FriendlyId 5.7.0 and Pagy
43.7.0 from the resolved `Gemfile.lock`. The catalog request specs exercise
FriendlyId routes and Pagy 43's `pagy(:offset, collection)` / `series_nav`
API.

## Security audit

**Not verified locally.** `bin/bundler-audit` stores `ruby-advisory-db` in
writable `tmp/ruby-advisory-db`. On 2026-10-03, it attempted to clone there
but failed with `Could not resolve host: github.com`. A successful audit in an
environment with outbound DNS must be recorded before calling it verified.

## Local process verification

`bin/dev` starts the Tailwind watcher and Puma. HTTP verification of `/up` is
**not verified in this sandbox**: on 2026-10-03 Puma booted, then exited while
binding the loopback socket with `Socket.ip_address_list: Operation not
permitted (Errno::EPERM)`; its `EXIT` trap terminated the Tailwind watcher.
Run `bin/dev`, request `http://127.0.0.1:3000/up`, and stop both processes in
an environment that permits local socket binding.

## Reproducible setup

On a Ruby 3.4.x environment, run:

```sh
bin/setup --skip-server
bin/ci
```

The generated Importmap, Hotwire, Tailwind, Solid Cache, and Solid Cable files
are committed; installers do not need to be rerun. Solid Queue is deferred
until a real background job exists.
