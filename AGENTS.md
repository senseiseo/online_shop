# Architecture constraints

- Keep this a Rails monolith: Ruby 3.4.x, Rails 8.1.x, SQLite, ERB, Hotwire,
  Tailwind, Propshaft, and Importmap.
- `User` means staff only. Use Rails built-in authentication; no public
  customer accounts and no Devise or Rodauth.
- Public customers are anonymous `Visitor` records identified only by an
  opaque signed or encrypted cookie token. Keep customer data in the database.
- Store carts in the database (`Visitor -> Cart -> CartItem`), not the session.
  An order converts its cart; `OrderItem` retains product and price snapshots.
- Prefer Rails built-ins. The approved future gems are Pagy, FriendlyId, and
  ActiveAdmin; add each only in its owning stage. Do not add Redis, Sidekiq,
  PostgreSQL, a SPA, Docker, or Kamal.
- Production is one VPS using Capistrano, Nginx, Puma/systemd, shared SQLite,
  and shared Active Storage. Keep secrets outside Git.
