# initr — Redmine plugin (Puppet frontend + ENC)

## IMPORTANT
Always follow the rules in this file first, then proceed to solve the problem efficiently.

Redmine plugin (author "Ingent") that gives a web UI to configure **Puppet modules**
and acts as an **External Node Classifier (ENC)** for a Puppet master: a managed host
("node") gets a set of Puppet classes ("klasses"), and initr emits the ENC YAML the
master consumes. Reads node facts and exported resources from PuppetDB (with a Puppet
storeconfigs fallback) and collects Puppet run reports.

Runs inside a **Redmine 5.0.x / Ruby 3.x / MySQL** install. This file is the project's
single source of truth (committed to the `initr` repo); the Redmine root's `CLAUDE.md`
only `@import`s it.

## Git workflow — get this right
The working tree is **two nested git repos**:
- **`plugins/initr/` (here)** = `descala/initr.git` (active branch `ruby_3`; `master` is stale — ignore it).
  **All commits happen here** — run every `git status`/`add`/`commit`/`push` from this dir. The Puppet modules in
  `puppet/modules/` are tracked as part of *this* repo (they have no separate `.git`).
- **The Redmine root above** = stock `redmine/redmine.git`, only ever `pull`ed to update
  Redmine core. **Never commit there.** Its untracked `git status` noise (`public/puppetrun_*`,
  `*.sql` dumps) is not ours — ignore it.

## Rules
- **ALL new code — controllers, routes, models, endpoints — goes inside `plugins/initr/`.
  NEVER edit Redmine core (anything outside `plugins/initr/`).** Core classes are changed at
  runtime via the monkeypatch files in `lib/` (`*_patch.rb` plus `redmine.rb`) — never by
  editing core files. **A patch of a core `Redmine::*` class must re-apply on every dev reload**:
  the reloader unloads those classes each reload while every plugin `init.rb` re-runs, so a patch
  applied only once silently vanishes — works at boot, then 500s on the next request ("undefined
  method"). The surviving pattern (see `init.rb`): a top-level `load` of `lib/redmine.rb`, which
  reopens the class, so it re-runs whenever `init.rb` does. (The `Project`/`User`/`Redmine::Plugin`
  patches are instead `include`d inside a `Rails.configuration.after_initialize` block in `init.rb`.)
  When proposing any new feature, start from the plugin, not from Redmine internals.
- The top-level `plugins/zzz_*` entries are **symlinks** into `puppet/modules/*` (that's how
  Redmine loads each module as a sub-plugin). **Never edit through a symlink** — edit the real
  file under `puppet/modules/<name>/`.
- Each sub-plugin migrates **separately** by module name, not just `NAME=initr`, e.g.
  `rake redmine:plugins:migrate NAME=bind`. **Ask before running migrations.**
- **`redmine:plugins:migrate NAME=initr` currently FAILS** — an old initr migration inherits
  `ActiveRecord::Migration` with no `[x.y]` version suffix, which Rails 6.1 rejects ("Directly
  inheriting from ActiveRecord::Migration is not supported"). So you can't build a DB from a clean
  full migrate — the **dev DB is the only source of truth** for the full schema. (Re)build the
  test DB from a fresh `db:schema:dump` of dev, never by migrating (see Pointers → Tests).

## Mental model
- **`Initr::Node`** (STI: `NodeInstance`, `NodeTemplate`) — a managed host, belongs to a
  project + user, has many klasses. `#parameters` assembles the ENC YAML (classes + params)
  the Puppet master reads. Facts and exported resources come from **PuppetDB** first
  (`Initr.puppetdb`, `lib/initr.rb`), falling back to the `Puppet::Rails::*` models in
  `app/models/puppet/rails/` that map the Puppet storeconfigs DB tables. Reports are
  stored locally (the `store_report` action → the node's `last_report`).
- **`Initr::Klass`** — one Puppet class applied to a node. Its `config` is a **serialized
  hash** (note: Rails dirty-tracking on serialized columns is unreliable). Raise
  `Initr::Klass::ConfigurationError` from `parameters` to report a config problem to Puppet
  instead of emitting a broken class.
- **`Initr::BindZone`** (bind module) — `domain` is **not globally unique** (uniqueness is only
  scoped to `bind_id`), and the DB contains **orphaned zones**: rows whose `bind_id` points at a
  deleted klass but that keep their full content. Any lookup by domain must scope to *existing*
  binds (e.g. `.where(bind_id: Initr::Bind.select(:id))`), otherwise it can land on an orphan
  (→ `.bind` is `nil` → 500) or an arbitrary project's copy. The `domain` column collation is also
  **accent-insensitive** (`ñ` ≡ `n`), so a `where(domain:)` can't distinguish IDN look-alikes
  (e.g. `labodaquesonaste` vs `labodaquesoñaste`). Empirically, no domain is served by two *live*
  binds — duplicates are always live-plus-orphan or such collation look-alikes.
- **`Initr::BindZoneManager` / `MyZonesController` (`/my_dns`)** — the self-service "My DNS" stack: a
  logged-in user edits only the `Initr::BindZone`s assigned to them. `BindZoneManager` links user ↔
  zone; the gate is `BindZone#editable_by?` + permission `:edit_own_bind_zones`.
- Each thing under `puppet/modules/` is **two things at once**: real Puppet code
  (`manifests/`, `templates/`, `files/`) *and* a Redmine sub-plugin (`app/`, `db/migrate/`,
  `init.rb`). Modules: `base`, `bind`, `borg_backup`, `copier`, `custom_klasses`, `dyndns`,
  `fail2ban`, `ftp_server`, `mailserver`, `monit`, `munin`, `nagios`, `package_manager`,
  `rsyncd`, `samba`, `smart`, `squid`, `ssh_station`, `webserver1`, plus support-only
  `link_klass`, `common`, `ldap`, `postgres`, `gnulinux`.

## Adding / changing a sub-plugin
A module's `init.rb` registers it and advertises its klass(es):
```ruby
Initr::Plugin.register :bind do
  name 'bind'
  project_module(:initr) { add_permission :edit_klasses, { :bind => [:configure, ...] } }
  klasses 'bind' => 'DNS server'   # string, or { :description=>..., :unique=>false }
end
```
The matching model is `app/models/initr/<name>.rb < Initr::Klass`; override
`class_parameters`/`parameters` (emit the Puppet config), `name`/`puppetname`, `unique?`,
`more_classes`, `print_parameters`, `clone` as needed. If the module ships a controller with a
`configure` action it owns its UI; otherwise the generic `KlassController` is used. Each
module's routes are auto-loaded by initr's root `config/routes.rb` (glob); Gemfiles are
picked up by Redmine's root `Gemfile` glob via the `zzz_*` symlinks. Because of that glob
**plus** the `zzz_*` symlink, each module's `config/routes.rb` is evaluated **twice** — so
**never give these routes an `:as` name** (a named route defined twice raises `Invalid route
name, already in use` and aborts route loading). Use bare `get/post '...' => 'controller#action'`
and reference them with explicit `{ :controller, :action }` hashes. Locales are **not**
auto-loaded centrally — each module's own `init.rb` must call `I18n.load_path +=`. Load order matters — the `zzz_` symlink prefix makes modules load *after*
`initr`, so the `Initr::Plugin`/`Initr::Klass` base classes exist first.

## Redmine API gotchas
- **`api_request?` override** — Redmine only attempts API key authentication when `api_request?`
  returns true, which it determines by URL format suffix (`.json`, `.xml`). For controllers that
  serve API endpoints without a format suffix (e.g. routes containing domain names), override
  `api_request?` to return `true` in the controller, otherwise `find_current_user` skips the
  API key lookup and the request is always anonymous. (Guidance for new endpoints — no plugin
  controller currently overrides it.)
- **API key header** — Redmine expects `X-Redmine-API-Key: <token>`, not `Authorization: Bearer <token>`.
- **Routes with dots** — Rails treats the last `.xxx` segment of a route as a format extension.
  Domain names in route params (e.g. `example.com`) must use `constraints: { id: /[^\/]+/ }` to
  prevent `.com` being stripped as a format.

## Pointers
- Settings (`Setting.plugin_initr`): puppetmaster host/ip/port — `app/views/initr/_settings.html.erb`.
  PuppetDB endpoint is hardcoded to `http://puppet:8080` in `lib/initr.rb`.
- ENC entry points for the Puppet master: `bin/external_node.sh`, `bin/puppet_external_nodes`.
- Tests (Minitest in `test/`, all commands from the Redmine root; procedure verified 2026-06):
  - Run: `RAILS_ENV=test bundle exec rails test plugins/initr/test/unit` (suite) or
    `... rails test plugins/initr/test/unit/node_test.rb` (single file).
    **Never `rake redmine:plugins:test`** — its `db:test:prepare` dependency purges the test DB,
    and the plugin `test_helper.rb` needs core data (`Project.find(2)`) at require time.
  - Test-DB bootstrap (only when the schema changed or the DB is broken):
    1. once per machine, `config/database.yml` test section needs
       `variables: { innodb_strict_mode: 0 }` — legacy wide latin1 tables
       (`initr_b2brouter_steps`) fail schema load otherwise;
    2. `bundle exec rake db:schema:dump RAILS_ENV=development` — `db/schema.rb` is
       local/gitignored and goes stale; only the dev DB has all plugin tables;
    3. `bundle exec rake db:test:prepare RAILS_ENV=test`;
    4. `bundle exec rake db:fixtures:load RAILS_ENV=test FIXTURES=projects,users,email_addresses,roles,members,member_roles,enabled_modules`
       — a full fixture load fails (UTF-8 wiki titles vs latin1 tables).
    Never run `redmine:plugins:migrate RAILS_ENV=test`: schema load records **no** plugin
    migration versions, so it would re-run them all (duplicate columns, unversioned classes).
    The schema dump already carries every plugin table.
  - `RUNNING_TESTS` is stale (Redmine 2.3 / zeus era) — don't follow it.
- Verifying a change (check, don't guess — model/logic via tests, the UI by hand in the browser):
  - **Tests run as-is**, no setup needed in the normal case: a single file runs clean with **no**
    schema dump / fixtures reload (checked 2026-06-16: `bind_zone_manager_test.rb`, 0 failures).
    The Test-DB bootstrap above is only a *fallback* for when a run fails on the DB, not a
    precondition for every run.
  - **Forcing a real dev reload:** only the plugin `app/` and `lib/` dirs are watched. Editing
    `init.rb`, a `config/routes.rb`, or a `puppet/modules/*/init.rb` does **NOT** reload; touch e.g.
    `app/controllers/initr_controller.rb` to trigger one, then watch `log/development.log` for the
    reload line + any error. `rails runner` + `Rails.application.reloader.reload!` is **not** a
    faithful proxy (it doesn't unload `Redmine::MenuManager`; raises spurious "Child already added")
    — use it only for boot-state checks.

## Known issues / TODO
- **Command injection via zone `domain` — FIXED 2026-06-22** (was noted 2026-06-19). `Initr::BindZone`
  previously shelled out with `domain` interpolated into a command string in `named_checkzone`
  (`` `#{checkzone} #{domain_idn} #{tmpfile.path}` ``) and `update_active_ns` (`` `dig ns #{domain} ...` ``),
  and the validator `/\A[^_]+\.[a-z]{2,20}\z/` allowed shell metacharacters (`;`, `$()`, backticks,
  spaces), so a domain like `$(...).com` could inject. It was a privileged-user (`:edit_klasses`) →
  RCE-on-the-Redmine-host escalation, *not* reachable by self-service `:edit_own_bind_zones` users.
  Fix (in `bind_zone.rb`): both call sites now use `Open3.capture2e(...)` with discrete argv (no
  shell, so metacharacters can't be parsed as syntax) — this also corrected the old broken `2&>1`
  in the `dig` call. The `domain` regex was tightened to a label-based hostname pattern
  (`/\A(?:[\p{L}\p{N}](?:[\p{L}\p{N}-]*[\p{L}\p{N}])?\.)+[a-z]{2,20}\z/i`) that excludes whitespace
  and shell metacharacters as defense-in-depth; note it allows Unicode letters/digits, *not* strict
  ASCII-LDH, because `domain` can legitimately hold Unicode IDN values (e.g. `labodaquesoñaste.com`).
