# frozen_string_literal: true

require_relative 'hex'

module Lib
  module Settings
    DARK = `window.matchMedia('(prefers-color-scheme: dark)').matches`.freeze
    # http://mkweb.bcgsc.ca/colorblind/ 12 color palette
    ROUTE_COLORS = %i[#A40122 #008DF9 #00FCCF #FF5AAF #8400CD #FF6E3A #009F81 #FFC33B].freeze

    ENTER_GREEN = '#3CB371'
    JOIN_YELLOW = '#F0E58C'
    YOUR_TURN_ORANGE = '#FF8C00'
    HOTSEAT_VIOLET = '#AF8CFF'
    FINISHED_GREY = '#D3D3D3'

    ROUTES = ROUTE_COLORS.flat_map.with_index do |color, index|
      [["r#{index}_color", color], ["r#{index}_dash", '0'], ["r#{index}_width", 8]]
    end.to_h

    SETTINGS = {
      notifications: true,
      simple_logos: false,
      red_logo: false,
      your_turn_sound: true,
      other_turn_sound: true,
      bg: DARK ? '#000000' : '#ffffff',
      bg2: DARK ? '#dcdcdc' : '#d3d3d3',
      font: DARK ? '#ffffff' : '#000000',
      font2: '#000000',
      your_turn: YOUR_TURN_ORANGE,
      hotseat_game: HOTSEAT_VIOLET,
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
      setting = @user&.dig(:settings, option)
      setting.nil? ? SETTINGS[option] : setting
    end

    alias color_for setting_for

    def route_prop(index, prop)
      setting_for(route_prop_string(index, prop))
    end

    def route_prop_string(index, prop)
      "r#{index}_#{prop}"
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

    def play_turn_sound(active)
      if active && setting_for(:your_turn_sound)
        audio_id = 'your_turn'
      elsif setting_for(:other_turn_sound)
        audio_id = 'other_turn'
      else
        return
      end

      audio = `document`.JS.getElementById(audio_id)
      audio.JS.play if audio && `typeof #{audio}.play` == 'function'
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
