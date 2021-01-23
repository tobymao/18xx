# frozen_string_literal: true

module Lib
  module PlayerColors
    # Parent must include Lib::Settings
    def self.included(base)
      base.needs :player_colors, default: nil, store: true
    end

    def player_colors
      player_colors = {}
      players = @game.players

      # Rotate around the user if they're logged in
      if @user && (player_idx = players.find_index { |p| p.id == @user['id'] })
        players = players.rotate(player_idx)
      end

      # Calculate player colors
      players.each_with_index { |p, idx| player_colors[p] = route_prop(idx, 'color') }
      player_colors
    end

    def show_player_colors
      Lib::Storage['show_player_colors']
    end
  end
end
