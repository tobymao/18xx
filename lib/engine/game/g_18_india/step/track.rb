# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18India
      module Step
        class Track < Engine::Step::Track

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

          # modified to prevent removal of province borders that had a cost (the cost is from a water border)
          def remove_border_calculate_cost!(tile, entity_or_entities, spender)
            # entity_or_entities is an array when combining private company abilities
            entities = Array(entity_or_entities)
            entity, *_combo_entities = entities

            hex = tile.hex
            types = []

            LOGGER.debug "Track::remove_border_calculate_cost >>"
            LOGGER.debug " >> tile.borders #{tile.borders.to_s}"

            total_cost = tile.borders.dup.sum do |border|
              cost = border.cost ? border.cost : 0

              edge = border.edge
              neighbor = hex.neighbors[edge]
              next 0 if !hex.targeting?(neighbor) || !neighbor.targeting?(hex)

              types << border.type
              if border.type == :province && @game.phase.name != 'IV'
                # if the border is a province prior to phase IV, don't delete, instead change cost to nil
                LOGGER.debug " >> MODIFY Borders!!!"
                tile.borders.delete(border)
                tile.borders << gauge_change_border(tile, edge)
                # add gauge change to neighbor tile also
                neighbor.tile.borders.map! { |nb| nb.edge == hex.invert(edge) ? nil : nb }.compact!
                neighbor.tile.borders << gauge_change_border(neighbor.tile, hex.invert(edge))
              else
                LOGGER.debug " >> DELETE Borders!!!"
                tile.borders.delete(border)
                neighbor.tile.borders.map! { |nb| nb.edge == hex.invert(edge) ? nil : nb }.compact!
              end

              LOGGER.debug " >> neighbor.tile.borders #{neighbor.tile.borders.to_s}"

              cost - border_cost_discount(entity, spender, border, cost, hex)
            end
            [total_cost, types]
          end

          def gauge_change_border(tile, edge)
            new_border = Engine::Part::Border.new(edge, :gauge_change, nil)
            new_border.tile = tile
            new_border
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
