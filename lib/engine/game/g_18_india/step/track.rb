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
            LOGGER.debug "process_lay_tile >> Test: #{@round.terrain_discount}"

            tile = action.tile

            LOGGER.debug "Track >> remove_border_calculate_cost "
            LOGGER.debug " >> tile.borders #{tile.borders.to_s}"
            tile.borders do |border|
              next 0 unless (cost = border.cost)

              edge = border.edge
              neighbor = hex.neighbors[edge]
              next 0 if !hex.targeting?(neighbor) || !neighbor.targeting?(hex)

              LOGGER.debug " >> neighbor.tile.borders #{neighbor.tile.borders.to_s}"
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

          # modified to prevent removal of province borders that had a cost (the cost is from a water border)
          def remove_border_calculate_cost!(tile, entity_or_entities, spender)
            # entity_or_entities is an array when combining private company abilities
            entities = Array(entity_or_entities)
            entity, *_combo_entities = entities

            hex = tile.hex
            types = []

            total_cost = tile.borders.dup.sum do |border|
              next 0 unless (cost = border.cost)

              edge = border.edge
              neighbor = hex.neighbors[edge]
              next 0 if !hex.targeting?(neighbor) || !neighbor.targeting?(hex)

              types << border.type
              if border.type == :province && @game.phase.name != 'IV'
                # if the border is a province prior to phase IV, don't delete, instead change cost to nil
                new_border = Engine::Part::Border.new(border.edge, border.type, nil, border.color)
                tile.borders.delete(border)
                tile.borders << new_border
                LOGGER.debug "Track >> remove_border_calculate_cost "
                LOGGER.debug " >> tile.borders #{tile.borders.to_s}"
                LOGGER.debug " >> neighbor.tile.borders #{neighbor.tile.borders.to_s}"
              else
                tile.borders.delete(border)
              end

              neighbor.tile.borders.map! { |nb| nb.edge == hex.invert(edge) ? nil : nb }.compact!

              LOGGER.debug "Track >> remove_border_calculate_cost "
              LOGGER.debug " >> tile.borders #{tile.borders.to_s}"
              LOGGER.debug " >> neighbor.tile.borders #{neighbor.tile.borders.to_s}"

              cost - border_cost_discount(entity, spender, border, cost, hex)
            end
            LOGGER.debug "Track >> remove_border_calculate_cost "
            LOGGER.debug " >> tile.borders #{tile.borders.to_s}"
            LOGGER.debug " >> neighbor.tile.borders #{neighbor.tile.borders.to_s}"

            [total_cost, types]
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
