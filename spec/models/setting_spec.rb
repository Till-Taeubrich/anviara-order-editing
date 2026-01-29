# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Settings, type: :model) do
  describe ".hold_duration_options_for_select" do
    it "returns label-value pairs for all options" do
      options = Settings.hold_duration_options_for_select

      expect(options).to(eq([
        ["30 minutes", 30],
        ["45 minutes", 45],
        ["1 hour", 60],
        ["1 hour and 30 minutes", 90],
        ["2 hours", 120],
        ["3 hours", 180],
      ]))
    end
  end
end
