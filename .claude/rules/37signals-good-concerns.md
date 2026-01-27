# 37signals: Good Concerns

Reference index: `37signals-style-index.md`

## Placement conventions

- **Default use-case**: concerns are primarily used to organize **one host model's** cohesive traits/roles (not as grab-bag shared modules).

- **Common model concerns**: put in `app/models/concerns`.

- **Model-specific concerns**: put in `app/models/<model_name>/...` and include without repeating namespaces.

  ```ruby
  # app/models/recording.rb
  class Recording < ApplicationRecord
    include Completable  # No need to prefix with Recording::
  end

  # app/models/recording/completable.rb
  module Recording::Completable
    extend ActiveSupport::Concern
  end
  ```

- **Controller concerns**: place most in `app/controllers/concerns`, with subsystem-specific subfolders as needed.

## What belongs in a concern

- **Concerns should be cohesive traits/roles**:
  - A concern should reflect "has trait" / "acts as" semantics.
  - Don't use concerns as arbitrary buckets just to split a large file.

  ```ruby
  # The Examiner concern represents a cohesive role a User can play
  class User < ApplicationRecord
    include Examiner
  end

  # app/models/user/examiner.rb
  module User::Examiner
    extend ActiveSupport::Concern

    included do
      has_many :clearances, foreign_key: "examiner_id",
                            class_name: "Clearance",
                            dependent: :destroy
    end

    def approve(contacts)
      # ...
    end

    def has_approved?(contact)
      # ...
    end

    def has_denied?(contact)
      # ...
    end
  end
  ```

- **Concerns improve readability when used to manage complexity**:
  - Split by coherent concepts so the reader can focus on one thing at a time.

- **Concerns can be domain-oriented abstractions**:
  - Names should capture domain roles and concepts clearly.

## Concerns are not a replacement for OO design

- **Use concerns to offer a nice domain API, but hide subsystems behind it**:
  - A concern can provide the public "door" method(s) while delegating to POROs / composed objects for the heavy work.

  ```ruby
  module Recording::Incineratable
    # Public API: simple and clean
    def incinerate
      Incineration.new(self).run  # Heavy work lives in a PORO
    end
  end
  ```

- **Avoid "fat and flat" models as the endgame**:
  - Concerns should work alongside composition/inheritance/patterns, not excuse poor responsibility distribution.

## Default stance in this codebase

When the user says **"37signals style rails"**, these rules apply (see `37signals-style-index.md`).

## Source

`https://dev.37signals.com/good-concerns/`
