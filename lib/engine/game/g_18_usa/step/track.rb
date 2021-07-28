# frozen_string_literal: true

require_relative '../../../step/tracker'
require_relative '../../../step/track'
require_relative '../../../step/upgrade_track_max_exits'
require_relative '../../../game_error'

module Engine
  module Game
    module G18USA
      module Step
        class Track < Engine::Step::Track
          include Engine::Step::UpgradeTrackMaxExits

          def lay_tile_action(action, entity: nil, spender: nil)
            tile = action.tile

            check_company_town(tile, action.hex) if tile.name.include?('CTown')

            super
            @game.company_by_id('P16').close! if tile.name.include?('RHQ')
            process_company_town(tile) if tile.name.include?('CTown')
          end

          def check_company_town(_tile, hex)
            raise GameError, 'Cannot use Company Town in a tokened hex' if hex.tile.cities&.first&.tokens&.first
            return if (hex.neighbors.values & @game.active_metropolitan_hexes).empty?

            raise GameError, 'Cannot use Company Town next to a metropolis'
          end

          def process_company_town(tile)
            corporation = @game.company_by_id('P27').owner
            bonus_token = Engine::Token.new(corporation)
            corporation.tokens << bonus_token
            tile.cities.first.place_token(corporation, bonus_token, free: true, check_tokenable: false, extra_slot: true)
            @game.graph.clear
            @game.company_by_id('P27').close!
          end

          def check_track_restrictions!(entity, old_tile, new_tile)
            old_tile.name.include?('iron') && new_tile.name.include?('iron') ? true : super
          end
        end
      end
    end
  end
end
