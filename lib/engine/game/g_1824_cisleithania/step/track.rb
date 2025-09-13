# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G1824Cisleithania
      module Step
        class Track < Engine::Step::Track
          def can_lay_tile?(entity)
            # Rule X.4: Regional created by construction railway does not lay any tiles (2 player)
            return false if @game.bond_railway?(entity)

            super
          end

          # Rule X.4: Construction railway lay tiles for free (2 player)
          def pay_tile_cost!(_entity_or_entities, tile, rotation, hex, spender, _cost, _extra_cost)
            return super unless @game.construction_railway?(spender)

            @log << "#{spender.name} lays tile ##{tile.name} with rotation #{rotation} on #{hex.name}"\
                    "#{tile.location_name.to_s.empty? ? '' : " (#{tile.location_name})"}"
          end

          def lay_tile_action(action, entity: nil, spender: nil)
            super

            return unless @game.two_player?
            return unless vienna_tile_upgrade?(action)

            # Rule XI.4: Trigger potential Vienna tokening (for 2 players) when Vienna upgraded to brown
            @game.notify_vienna_can_be_tokened_by_bond_railway(action.entity)
          end

          private

          def vienna_tile_upgrade?(action)
            action.hex.id == 'E12' && action.tile.name == '493'
          end
        end
      end
    end
  end
end
