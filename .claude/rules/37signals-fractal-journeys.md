# 37signals: Fractal Journeys

Reference index: `37signals-style-index.md`

## Architectural / design rules

- **Good code is a fractal**: you should see the same good qualities repeated at every level of abstraction (subsystem -> class -> method).

  ```ruby
  # At the model level: many cohesive concerns, each representing a clear capability
  class Topic < ApplicationRecord
    include Accessible, Breakoutable, Deletable, Entries, Incineratable,
            Indexed, Involvable, Journal, Mergeable, Named, Nettable,
            Notifiable, Postable, Publishable, Preapproved, Collectionable,
            Recycled, Redeliverable, Replyable, Restorable, Sortable, Spam, Spanning
  end
  ```

- **Be domain-driven at every level**:
  - Names and APIs should reflect the problem domain, not incidental implementation detail.

- **Encapsulate aggressively**:
  - Expose crisp public methods; hide internal details behind private helpers/objects.

  ```ruby
  module Account::Closable
    # Clean public API
    def terminate
      purge_or_incinerate if terminable?
    end

    private

    # Internal orchestration hidden from callers
    def purge_or_incinerate
      eligible_for_purge? ? purge : incinerate
    end

    def purge
      Account::Closing::Purging.new(self).run
    end

    def incinerate
      Account::Closing::Incineration.new(self).run
    end
  end
  ```

- **Be cohesive**:
  - Each abstraction should "do one thing" from the caller's point of view (orchestrate at a high level; delegate details below).

- **Be symmetric / stay at one level of abstraction**:
  - Avoid mixing low-level detail into high-level orchestration.
  - Prefer parallel structure (e.g., "relay" and "revoke" counterparts) so the reader can follow the journey cleanly.

## Default stance in this codebase

When the user says **"37signals style rails"**, these rules apply (see `37signals-style-index.md`).

## Source

`https://dev.37signals.com/fractal-journeys/`
