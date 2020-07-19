# frozen_string_literal: true

require 'lib/hex'

module Lib
  module Settings
    DARK = `window.matchMedia('(prefers-color-scheme: dark)').matches`.freeze
    # http://mkweb.bcgsc.ca/colorblind/ 12 color palette
    ROUTE_COLORS = %i[#A40122 #008DF9 #00FCCF #FF5AAF].freeze

    routes = {}
    ROUTE_COLORS.each_with_index do |color, n|
      routes["r#{n}_color"] = color
      routes["r#{n}_dash"] = '0'
      routes["r#{n}_width"] = 8
    end

    SETTINGS = {
      notifications: true,
      red_logo: false,
      bg: DARK ? '#000000' : '#ffffff',
      bg2: DARK ? '#dcdcdc' : '#d3d3d3',
      font: DARK ? '#ffffff' : '#000000',
      font2: '#000000',
      **Lib::Hex::COLOR,
      **routes,
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
