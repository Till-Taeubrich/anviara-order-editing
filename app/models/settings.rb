# frozen_string_literal: true

class Settings < ApplicationRecord
  belongs_to :shop

  HOLD_DURATION_OPTIONS = [30, 45, 60, 90, 120, 180].freeze

  def self.hold_duration_options_for_select
    HOLD_DURATION_OPTIONS.map { |minutes| [ActiveSupport::Duration.build(minutes * 60).inspect, minutes] }
  end
end
