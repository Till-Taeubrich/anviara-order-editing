# frozen_string_literal: true

class Settings < ApplicationRecord
  self.table_name = "settings"

  belongs_to :shop
end
