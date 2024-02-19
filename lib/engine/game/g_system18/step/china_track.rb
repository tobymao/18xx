# frozen_string_literal: true

require_relative 'track'

module Engine
  module Game
    module GSystem18
      module Step
        class ChinaTrack < Track
          def round_state
            super.merge({ citytown_track: 0 })
          end

          def setup
            super
            @round.citytown_track = 0
          end

          def process_lay_tile(action)
            lay_tile_action(action)
            tile = action.tile
            entity = action.entity
            if !tile.cities.empty? || !tile.towns.empty?
              # city or town on tile: increase share price
              old_price = entity.share_price
              @game.stock_market.move_right(action.entity)
              @game.log_share_price(entity, old_price)
              @round.citytown_track += 1
            end

            pass! unless can_lay_tile?(action.entity)
          end

          def extra_cost(tile, _tile_lay, _hex)
            return 0 if tile.cities.empty? && tile.towns.empty?

            (current_entity.share_price.price / 2.0).round
          end

          def pass!
            if @round.citytown_track.zero?
              old_price = current_entity.share_price
              @game.stock_market.move_left(current_entity)
              @game.log_share_price(current_entity, old_price)
            end
            super
          end
        end
      end
    end
  end
end
