# Shopify Webhook Scaffolding (Declarative Webhooks)

When adding a new Shopify webhook handler in this repo, **always scaffold it using the `shopify_app` generator**.

This keeps webhook endpoints consistent, avoids subtle verification mistakes, and aligns with the repo's `/api/webhooks/...` routing convention.

## Default (preferred): use the generator

Use:

```bash
bin/rails g shopify_app:add_declarative_webhook --topic products/update --path webhooks/products_update
```

### Conventions

- **`--topic`**: use Shopify's canonical topic format (`products/update`, `orders/create`, etc.).
  - **For available topics**: See `shopify-webhook-topics.md` - always research the official [Shopify webhook topics documentation](https://shopify.dev/docs/api/webhooks/latest#list-of-topics) when questions about available topics arise.
- **`--path`**: keep it under `webhooks/...` and use **snake_case** for the leaf path.
  - Example: `webhooks/products_update`
  - Resulting URL should live under this app's API scope: **`/api/webhooks/...`**

## After scaffolding

The generator automatically adds the route to `config/routes.rb` under the `/api/webhooks/...` namespace. **Do not make any automatic changes after scaffolding** - only suggest to the user what implementation steps they may need to take next (e.g., implementing the controller action logic).

## Implementation guidelines

- Keep the controller action **small and fast**.
- Put business logic in a domain object / model method (37signals "vanilla Rails" style), not inside the controller.
- Return a simple success response (`head :ok`) once the payload is accepted for processing.

## Good vs bad

### Good

```bash
bin/rails g shopify_app:add_declarative_webhook --topic products/update --path webhooks/products_update
```

### Bad

```bash
# Hand-rolled endpoints are easy to get wrong (verification, headers, future consistency).
bin/rails g controller Webhooks::ProductsUpdate create
```
