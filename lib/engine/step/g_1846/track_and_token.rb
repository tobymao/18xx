# frozen_string_literal: true

require_relative '../track_and_token'
require_relative 'receivership_skip'

module Engine
  module Step
    module G1846
      class TrackAndToken < TrackAndToken
        include ReceivershipSkip

        def buying_power(entity)
          @game.track_buying_power(entity)
        end

        def lay_tile_action(action)
          super
          return unless @game.lake_shore_line && @upgraded && @game.class::LSL_HEXES.include?(action.hex.id)

          action.tile.icons.reject! { |icon| icon.name == @game.class::LSL_ICON }
        end
      end
    end
  end
end
