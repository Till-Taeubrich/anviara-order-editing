# 37signals: Globals, Callbacks and Other Sacrileges

Reference index: `37signals-style-index.md`

## Architectural / design rules

- **Avoid maximalist bans**: don't categorically forbid a technique because it can be misused; judge it by whether it reduces complexity in-context.

- **Use callbacks for small, lifecycle-coupled hooks**:
  - Good fit when you're **hooking a small orthogonal behavior** into an object's lifecycle (e.g., auto-building a companion record).
  - Don't use callbacks to **orchestrate complex flows** that should be explicit and readable.

- **Use request-scoped globals intentionally (CurrentAttributes)**:
  - Prefer `Current.*` when it removes pervasive parameter threading for cross-cutting, request-level context (auditing, attribution, diagnostics).
  - Keep `Current` focused on **request context**, not arbitrary global state.

- **Combine callbacks + Current for orthogonal concerns**:
  - Use indirection when it **reduces coupling** between a primary operation (e.g., create project) and an orthogonal concern (e.g., auditing).

- **Use suppression mechanisms only for exceptionality**:
  - When the default behavior is correct most of the time (e.g., callbacks that track events), provide an explicit "exception mode" (e.g., `suppress`) for rare cases.

- **Treat these tools as sharp knives**:
  - They can create hard-to-follow code if abused; use them to **remove boilerplate and preserve cohesion**, not to hide core domain flows.

## Default stance in this codebase

When the user says **"37signals style rails"**, these rules apply (see `37signals-style-index.md`).

## Source

`https://dev.37signals.com/globals-callbacks-and-other-sacrileges/`
