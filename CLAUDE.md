# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Anviara Order Editing** is a Shopify embedded app that enables merchants to edit order shipping addresses on the thank-you page. Built on the Shopify Hotwire template using Rails 8, Hotwire (Turbo + Stimulus), and Shopify UI Extensions.

## Quick Reference

### Development Commands
```bash
bin/tunnel         # Start Cloudflare tunnel (run in one terminal)
yarn dev           # Start development server (run in another terminal)
bin/setup          # Initial project setup
```

### Testing & Linting
```bash
bundle exec rspec           # Run RSpec tests (primary)
bundle exec rspec spec/models/  # Run specific directory
bundle exec rubocop         # Check code style
bundle exec rubocop -a      # Auto-fix style issues
```

### Database
```bash
bin/rails db:migrate        # Run migrations
bin/rails g model Name      # Generate model (always use generators)
bin/rails g migration Name  # Generate migration
```

### Shopify CLI
```bash
yarn config link             # Link app credentials
yarn deploy -c production    # Deploy config to production
yarn env show -c production  # Get production env vars
```

## Architecture

### Extension → Backend Communication

The thank-you page extension (`extensions/thank-you-address-editor/`) communicates with the Rails backend:

1. Extension POSTs to `/api/shipping_address_updates` with shop domain, order ID, and address data
2. `Api::ShippingAddressUpdatesController` skips CSRF and sets CORS headers for cross-origin requests
3. Backend calls GraphQL mutation (`UpdateOrderAddress`) within Shopify session
4. Returns JSON: `{success: bool, statusPageUrl: string, errors: []}`

### GraphQL Pattern
```ruby
# Always wrap in session block
current_shop.with_shopify_session do
  UpdateOrderAddress.call(order_id:, shipping_address:).data
end
```

GraphQL queries/mutations live in `app/graphql/` following `shopify_graphql` gem conventions:
- Include `ShopifyGraphql::Query` or `ShopifyGraphql::Mutation`
- Define GraphQL as `QUERY` / `MUTATION` constants
- Implement `def call(...)` returning the response
- Call `handle_user_errors(response.data)` for mutations

### 37signals Style Rails

This project follows 37signals architectural patterns (see `.cursor/rules/37signals-*.mdc`):

- **Vanilla Rails**: Controllers access domain models directly; no mandatory service layer
- **Rich Domain Models**: Business logic lives in models, not orchestration layers
- **Good Concerns**: Use concerns for cohesive traits/roles, delegate heavy work to POROs
- **Sharp Knives**: Use callbacks and CurrentAttributes pragmatically

### Turbo Stream Responses
- Use `.turbo_stream.erb` templates
- Flash messages via `turbo_flashes` helper
- JWT tokens auto-appended to Turbo requests via AppBridge

## Project Structure

```
app/
├── controllers/
│   ├── authenticated_controller.rb  # Base for authenticated routes
│   └── api/
│       └── shipping_address_updates_controller.rb  # API for extension calls
├── graphql/                # Shopify GraphQL queries/mutations
├── javascript/
│   ├── controllers/        # Stimulus controllers
│   └── shopify_app/        # JWT/Shopify integration utilities
└── views/

extensions/
└── thank-you-address-editor/
    ├── src/
    │   ├── ThankYouAddressEditor.jsx  # Main extension entry
    │   └── Modal.jsx
    ├── locales/             # i18n (en.default.json, de.json)
    └── shopify.extension.toml  # Targets purchase.thank-you.customer-information.render-after

spec/                        # RSpec tests (primary framework)
.cursor/rules/               # Cursor rules (tech-stack, conventions, etc.)
```

## Key Dependencies

- **Rails 8.0** with Hotwire (Turbo 8.x, Stimulus 3.x)
- **Ruby 3.3.6** / Node 20.10.0
- **shopify_app** gem for Shopify integration
- **shopify_graphql** gem for GraphQL queries
- **polaris_view_components** for UI (prefer web components when available)
- **Preact + @preact/signals** for UI extensions
- **PostgreSQL** database, **Redis** for caching

See `.claude/rules/tech-stack.md` for full dependency details.

## API Scopes

`read_orders, write_orders, write_order_edits, write_merchant_managed_fulfillment_orders, write_third_party_fulfillment_orders`

## Webhooks

Generate new webhooks with:
```bash
bin/rails g shopify_app:add_declarative_webhook --topic products/update --path webhooks/products_update
```

## Claude Code Agents

Three agents are available in `.claude/agents/`. Use them by name in prompts.

### feature-build (full pipeline)
For non-trivial features where design matters. Runs the complete pipeline:
1. Clarifies requirements (asks 3+ questions)
2. Researches codebase patterns + fetches external docs (Shopify API, Turbo, Polaris, etc.)
3. Drafts spec v1 (likely bloated)
4. DHH review #1 via `dhh-code-reviewer` subagent
5. Drafts spec v2 (tighter)
6. DHH review #2
7. Final spec v3 -- pauses for your approval
8. Builds the feature
9. Writes RSpec tests after you confirm

Usage: `Use the feature-build agent to build [requirements]`

### application-architect (design only)
For when you want an architecture plan without building anything. Researches the codebase and external docs, then produces a structured implementation plan with steps, code snippets, and trade-offs.

Usage: `Use the application-architect agent to design [feature]`

### dhh-code-reviewer (code review)
Invoked automatically by `feature-build`, but can also be used standalone after writing any Ruby or JavaScript code. Reviews against DHH's standards for elegance, expressiveness, and idiomatic style.

Usage: `Use the dhh-code-reviewer agent to review [files or changes]`

## Claude Code Safety Hooks

Configured in `.claude/settings.json` and `.claude/hooks/`:

- **Database safety rules** (`.claude/rules/database-safety.md`): Forbids destructive DB operations (`db:drop`, `db:reset`, `destroy_all`, etc.)
