# frozen_string_literal: true

require 'lib/hex'

module Lib
  module Settings
    DARK = `window.matchMedia('(prefers-color-scheme: dark)').matches`.freeze

    SETTINGS = {
      notifications: true,
      red_logo: false,
      bg: DARK ? '#000000' : '#ffffff',
      bg2: DARK ? '#dcdcdc' : '#d3d3d3',
      font: DARK ? '#ffffff' : '#000000',
      font2: '#000000',
      **Lib::Hex::COLOR,
    }.freeze

    def self.included(base)
      base.needs :user, default: nil, store: true
    end

    def default_for(option)
      SETTINGS[option]
    end

    def setting_for(option)
      @user&.dig(:settings, option) || SETTINGS[option]
    end

    alias color_for setting_for
  end
end
