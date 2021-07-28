# frozen_string_literal: true

require_relative '../../../step/tracker'
require_relative '../../../step/track'
require_relative '../../../step/upgrade_track_max_exits'

module Engine
  module Game
    module G18USA
      module Step
        class Track < Engine::Step::Track
          include Engine::Step::UpgradeTrackMaxExits

          def lay_tile_action(action, entity: nil, spender: nil)
            tile = action.tile

            super
            @game.company_by_id('P16').close! if tile.name.include?('RHQ')
            process_company_town(tile) if tile.name.include?('CTown')
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
