# frozen_string_literal: true

require_relative 'color'
require_relative 'hex'

module Lib
  module Settings
    DARK = `window.matchMedia('(prefers-color-scheme: dark)').matches`.freeze
    # http://mkweb.bcgsc.ca/colorblind/ 15 color palette, with some substitutions + 1 additional
    ROUTE_COLORS = %i[ #A40122 #099FFA #00DCB5 #FF5AAF #9400E6 #FF6E3A #009581 #FFDC3D
                       #EF0096 #7CFFFA #005FCC #F60239 #00E307 #FFCFE2 #AFFF2A #E8D2AB ].freeze

    ENTER_GREEN = '#3CB371'
    JOIN_YELLOW = '#F0E58C'
    YOUR_TURN_ORANGE = '#FF8C00'
    HOTSEAT_VIOLET = '#AF8CFF'
    FINISHED_GREY = '#D3D3D3'

    ROUTES = ROUTE_COLORS.flat_map.with_index do |color, index|
      [["r#{index}_color", color], ["r#{index}_dash", '0'], ["r#{index}_width", 8]]
    end.to_h

    SETTINGS = {
      notifications: :email,
      webhook: :slack,
      webhook_url: '',
      webhook_user_id: '',
      red_logo: false,
      show_location_names: true,
      bg: DARK ? '#000000' : '#ffffff',
      bg2: DARK ? '#dcdcdc' : '#d3d3d3',
      font: DARK ? '#ffffff' : '#000000',
      font2: '#000000',
      your_turn: YOUR_TURN_ORANGE,
      hotseat_game: HOTSEAT_VIOLET,
      **Lib::Hex::COLOR,
      **ROUTES,
      path_timeout: 30,
      route_timeout: 10,
    }.freeze

    def self.included(base)
      base.needs :user, default: nil, store: true
      base.send :include, Lib::Color
    end

    def default_for(option)
      SETTINGS[option]
    end

    def setting_for(option, game = nil)
      [game ? Lib::Storage["#{option}_#{game.class.title}"] : @user&.dig(:settings, option),
       Lib::Storage[option],
       SETTINGS[option]].compact.first
    end

    def toggle_setting(option, game = nil)
      value = !setting_for(option, game)
      Lib::Storage[option] = value
      Lib::Storage["#{option}_#{game.class.title}"] = value if game
    end

    alias color_for setting_for

    def route_prop(index, prop)
      setting_for(route_prop_string(index, prop))
    end

    def route_prop_string(index, prop)
      "r#{index % ROUTE_COLORS.size}_#{prop}"
    end

    def change_favicon(active)
      `document.getElementById('favicon_svg').href = '/images/icon' + #{active ? '_red' : ''} + '.svg'`
      `document.getElementById('favicon_16').href = '/images/favicon-16x16' + #{active ? '_red' : ''} + '.png'`
      `document.getElementById('favicon_32').href = '/images/favicon-32x32' + #{active ? '_red' : ''} + '.png'`
      `document.getElementById('favicon_apple').href = '/apple-touch-icon' + #{active ? '_red' : ''} + '.png'`
    end

    def change_tab_color(active)
      color = active ? color_for(:your_turn) : color_for(:bg)
      `document.getElementById('theme_color').content = #{color}`
      `document.getElementById('theme_apple').content = #{color}`
      `document.getElementById('theme_ms').content = #{color}`
    end

    def player_colors(players)
      # Rotate around the user if they're logged in
      if @user && (player_idx = players.index { |p| p.id == @user['id'] })
        players = players.rotate(player_idx)
      end

      players.map.with_index { |p, idx| [p, route_prop(idx, 'color')] }.to_h
    end
  end
end
