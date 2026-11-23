# frozen_string_literal: true

require_relative '../../../step/special_track'
require_relative 'tracker'

module Engine
  module Game
    module G18OE
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          include Tracker

          def actions(entity)
            return [] unless entity == @game.brandt_private
            return [] unless @game.brandt_token_placeable?(@round.current_operator)

            %w[lay_tile]
          end

          def available_hex(_entity, hex)
            return unless @game.brandt_hex?(hex)

            tracker_available_hex(@round.current_operator, hex)
          end

          def hex_neighbors(entity, hex)
            @game.graph_for_entity(entity).connected_hexes(entity)[hex]
          end

          def process_lay_tile(action)
            operator = @round.current_operator
            hex = action.hex
            tile = action.tile
            old_tile = hex.tile

            raise GameError, "#{action.entity.name} cannot be used by #{operator.name} now" unless
              @game.brandt_token_placeable?(operator)
            raise GameError, "#{hex.name} cannot hold a Brandt & Brandau token" unless @game.brandt_hex?(hex)
            raise GameError, 'Brandt & Brandau lays a yellow tile' unless tile.color == :yellow
            raise GameError, "#{old_tile.name} is not upgradeable to #{tile.name}" unless @game.upgrades_to?(old_tile, tile)
            if !@game.loading && !tracker_available_hex(operator, hex)
              raise GameError, "#{hex.name} is not connected to #{operator.name}"
            end

            lay_tile_action(action, spender: operator)
            abilities(action.entity).use!
            @game.place_brandt_token!(hex)
          end
        end
      end
    end
  end
end
