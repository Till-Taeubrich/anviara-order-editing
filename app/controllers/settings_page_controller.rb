# frozen_string_literal: true

class SettingsPageController < AuthenticatedController
  before_action :set_settings

  def show
  end

  def update
    if @settings.update(settings_params)
      flash.now[:notice] = "Editing window set to #{ActiveSupport::Duration.build(@settings.hold_duration_minutes * 60).inspect}"
    else
      flash.now[:alert] = @settings.errors.full_messages.to_sentence
    end

    render(turbo_stream: turbo_flashes)
  end

  private

  def set_settings
    @settings = current_shop.settings
  end

  def settings_params
    params.require(:settings).permit(:hold_duration_minutes)
  end
end
