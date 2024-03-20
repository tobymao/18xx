# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18India
      module Step
        class Track < Engine::Step::Track
          # for debugging
          def process_lay_tile(action)
            super
            LOGGER.debug "process_lay_tile >> terrain_discount: #{@round.terrain_discount}"
          end

          # Bypass some Step::Tracker tests for Town to City upgrade: maintain exits, and check new exits are valid
          def legal_tile_rotation?(entity, hex, tile)
            old_tile = hex.tile
            if @game.yellow_town_to_city_upgrade?(old_tile, tile)
              all_new_exits_valid = tile.exits.all? { |edge| hex.neighbors[edge] }
              return false unless all_new_exits_valid

              return old_tile.paths.all? { |old| tile.paths.any? { |new| old.exits == new.exits } } &&
                     !(tile.exits & hex_neighbors(entity, hex)).empty?
            end

            super
          end

          # close P4 if ability was activated
          def pass!
            company = @round.discount_source
            unless company.nil?
              @game.company_closing_after_using_ability(company)
              company.close!
            end
            super
          end
        end
      end
    end
  end
end
