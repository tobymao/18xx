# frozen_string_literal: true

require_relative '../../../step/track_and_token'
require_relative 'receivership_skip'

module Engine
  module Game
    module G1846
      module Step
        class TrackAndToken < Engine::Step::TrackAndToken
          include ReceivershipSkip

          def buying_power(entity)
            @game.track_buying_power(entity)
          end

          def lay_tile_action(action)
            super
            return if !@game.lake_shore_line || !@round.upgraded_track || !@game.class::LSL_HEXES.include?(action.hex.id)

            action.tile.icons.reject! { |icon| icon.name == @game.class::LSL_ICON }
          end

          def process_lay_tile(action)
            super
            @game.place_token_on_upgrade(action)
          end
        end
      end
    end
  end
end
