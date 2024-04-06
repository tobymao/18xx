# frozen_string_literal: true

require_relative '../../../step/track'
# require_relative 'tracker'

module Engine
  module Game
    module G18India
      module Step
        class Track < Engine::Step::Track
          # include Tracker

          # for debugging
          def process_lay_tile(action)
            tile = action.tile
            hex = action.hex
            rotation = action.rotation
            old_tile = hex.tile
            LOGGER.debug "Track::process_lay_tile:"
            LOGGER.debug "process_lay_tile >> old_tile.borders #{old_tile.borders.to_s}"

            super

            LOGGER.debug "process_lay_tile >> tile.borders #{tile.borders.to_s}"
            tile.borders do |border|
              next 0 unless (cost = border.cost)

              edge = border.edge
              neighbor = hex.neighbors[edge]
              next 0 if !hex.targeting?(neighbor) || !neighbor.targeting?(hex)

              LOGGER.debug "process_lay_tile >> neighbor.tile.borders #{neighbor.tile.borders.to_s}"
            end
          end

          # Bypass some Step::Tracker tests for Town to City upgrade: maintain exits, and check new exits are valid
          def legal_tile_rotation?(entity, hex, tile)
            old_tile = hex.tile
            if @game.yellow_town_to_city_upgrade?(old_tile, tile)
              all_new_exits_valid = tile.exits.all? { |edge| hex.neighbors[edge] }
              return false unless all_new_exits_valid

              return (old_tile.exits - tile.exits).empty?
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
