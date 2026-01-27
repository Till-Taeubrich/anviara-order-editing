# Shopify Rails Hotwire Template

A Shopify embedded app built with Rails 8, Hotwire (Turbo + Stimulus), and Polaris components.

## Quick Reference

### Development Commands
```bash
yarn dev          # Start development server (Shopify CLI)
bin/dev           # Alternative: uses Foreman
bin/setup         # Initial project setup
```

### Testing
```bash
bundle exec rspec           # Run RSpec tests (primary)
bundle exec rubocop         # Check code style
bundle exec rubocop -a      # Auto-fix style issues
```

### Database
```bash
bin/rails db:migrate        # Run migrations
bin/rails g model Name      # Generate model (always use generators!)
bin/rails g migration Name  # Generate migration
```

## Architecture Guidelines

This project follows **37signals style Rails** - see `.claude/rules/37signals-*.md` for details:

- **Vanilla Rails**: Controllers access domain models directly; no mandatory service layer
- **Rich Domain Models**: Business logic lives in models, not orchestration layers
- **Good Concerns**: Use concerns for cohesive traits/roles, delegate heavy work to POROs
- **Sharp Knives**: Use callbacks and CurrentAttributes pragmatically

## Key Patterns

### GraphQL Queries
```ruby
# Always wrap in session block
current_shop.with_shopify_session do
  GetProducts.call.data
end
```

### Turbo Stream Responses
- Use `.turbo_stream.erb` templates
- Flash messages via `turbo_flashes` helper
- JWT tokens auto-appended to Turbo requests

### Webhooks
```bash
# Always use the generator
bin/rails g shopify_app:add_declarative_webhook --topic products/update --path webhooks/products_update
```

## Project Structure

- `app/graphql/` - Shopify GraphQL queries/mutations (use `shopify_graphql` gem patterns)
- `app/javascript/controllers/` - Stimulus controllers
- `app/javascript/shopify_app/` - Shopify/JWT integration utilities
- `spec/` - RSpec tests (primary testing framework)

## Dependencies

- **Rails 8.0** with Hotwire (Turbo 8.x, Stimulus 3.x)
- **shopify_app** gem for Shopify integration
- **shopify_graphql** gem for GraphQL queries
- **polaris_view_components** for UI (prefer web components when available)

See `.claude/rules/tech-stack.md` for full dependency details.
