# Database Safety Rules

## Mandatory rules for all operations

### Never wipe or reset any database

These rules apply to all operations — manual coding, agents, and automated tasks.

## Forbidden operations

**Never execute these commands against development or production:**
- `rails db:drop`
- `rails db:reset`
- `rails db:setup` (on existing databases)
- `rails db:schema:load` (on existing databases)
- `Model.destroy_all` or `Model.delete_all` without scoped conditions
- SQL `TRUNCATE TABLE`
- SQL `DROP TABLE`
- SQL `DELETE FROM` without a WHERE clause

## Required behavior

1. **Refuse** any request to reset or wipe the development database
2. **Only** use the test database (`RAILS_ENV=test`) for destructive operations
3. **Always** preserve existing development data
4. **Migrations** should be additive or safely reversible

## Safe alternatives

Instead of destructive operations, use:
- Scoped deletions: `Model.where(condition: value).destroy_all`
- Test database: `RAILS_ENV=test rails console`
- Transactions with rollback for exploratory work
- Creating new records instead of destroying existing ones

## Why this matters

Development databases contain important test data, Shopify OAuth sessions, configuration that took time to set up, and data for reproducing bugs. Destroying this data can set back development significantly.
