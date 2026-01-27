# 37signals: Active Record, Nice and Blended

Reference index: `37signals-style-index.md`

## Architectural / design rules

- **Reframe the separation question**:
  - Active Record (the pattern) combines persistence + domain logic; 37signals treats this as a feature when the ORM makes it workable.

- **Prefer an impedance-less match over strict layering**:
  - A good ORM reduces object-relational impedance mismatch so the code can read naturally and stay expressive.

- **Lean on Active Record's primitives for rich models**:
  - Use associations, STI, serialized attributes, delegated types, etc., to persist rich object models directly.

- **Keep encapsulation strong even with AR**:
  - Wrap persistence details in private methods and domain-level APIs so callers don't absorb query/persistence complexity.
  - Use POROs/objects when complexity warrants it; AR doesn't prevent proper OO design.

  ```ruby
  module Contact::Designatable
    def designate_to(user)
      # ...
    end

    private

    def some_private_method
      # Active Record logic hidden behind private method
    end
  end
  ```

- **Beware the cost of persistence isolation**:
  - A strict "persistence-free domain model" often adds orchestration overhead and can make rich domain logic harder (or pushes you toward anemic models).

- **Active Record is still a tool (avoid mess)**:
  - Blending persistence with domain logic can become unmaintainable if responsibilities are mixed arbitrarily—use good boundaries and cohesive abstractions.

  ```ruby
  # The Account model has a clean public API...
  class Account < ApplicationRecord
    include Closable
  end

  # ...while the Closable concern encapsulates closing logic
  module Account::Closable
    def terminate
      purge_or_incinerate if terminable?
    end

    private

    def purge_or_incinerate
      eligible_for_purge? ? purge : incinerate
    end

    # Heavy operations delegated to dedicated POROs
    def purge
      Account::Closing::Purging.new(self).run
    end

    def incinerate
      Account::Closing::Incineration.new(self).run
    end
  end
  ```

## Default stance in this codebase

When the user says **"37signals style rails"**, these rules apply (see `37signals-style-index.md`).

## Source

`https://dev.37signals.com/active-record-nice-and-blended/`
