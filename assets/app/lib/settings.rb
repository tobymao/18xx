# frozen_string_literal: true

require 'lib/hex'

module Lib
  module Settings
    DARK = `window.matchMedia('(prefers-color-scheme: dark)').matches`.freeze
    # http://mkweb.bcgsc.ca/colorblind/ 12 color palette
    ROUTE_COLORS = %i[#A40122 #008DF9 #00FCCF #FF5AAF].freeze

    ENTER_GREEN = '#3CB371'
    JOIN_YELLOW = '#F0E58C'
    YOUR_TURN_ORANGE = '#FF8C00'
    FINISHED_GREY = '#D3D3D3'

    ROUTES = ROUTE_COLORS.flat_map.with_index do |color, index|
      [["r#{index}_color", color], ["r#{index}_dash", '0'], ["r#{index}_width", 8]]
    end.to_h

    SETTINGS = {
      notifications: true,
      red_logo: false,
      bg: DARK ? '#000000' : '#ffffff',
      bg2: DARK ? '#dcdcdc' : '#d3d3d3',
      font: DARK ? '#ffffff' : '#000000',
      font2: '#000000',
      your_turn: YOUR_TURN_ORANGE,
      **Lib::Hex::COLOR,
      **ROUTES,
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

    def route_prop(index, prop)
      setting_for(route_prop_string(index, prop))
    end

    def route_prop_string(index, prop)
      "r#{index}_#{prop}"
    end
  end
end
