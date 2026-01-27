# Rails Generators for Models and Migrations

When adding a **new model** and/or **new migration**, always use Rails generators instead of manually creating files under `app/models/` or `db/migrate/`.

## Rule

- Always run `bin/rails generate ...` (or `bin/rails g ...`) to create models and migrations.
- After generating, it's fine (and expected) to **edit the generated files** to match the desired schema, constraints, and domain language.
- Do not "freehand" new model or migration files unless the generator cannot express what's needed (rare). If you must, explain why.

## Commands (common cases)

### New model (and migration)

```bash
bin/rails g model Shop name:string shopify_domain:string
```

### New migration

```bash
bin/rails g migration AddSubscriptionActiveToShops subscription_active:boolean
```

### Add / remove columns

```bash
bin/rails g migration AddFooToBars foo:string
bin/rails g migration RemoveFooFromBars foo:string
```

### Join table

```bash
bin/rails g migration CreateJoinTableUsersRoles users roles
```

## Editing after generation (expected)

- Update the migration to add constraints like `null: false`, defaults, and indexes.
- Update the model to add validations, associations, and domain behavior.

## Bad vs good

### Bad

- Create `db/migrate/2026..._add_foo_to_bars.rb` manually from scratch.
- Create `app/models/foo.rb` manually from scratch for a new model.

### Good

- Use `bin/rails g model ...` / `bin/rails g migration ...`, then refine the generated code.
