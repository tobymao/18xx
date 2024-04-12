# frozen_string_literal: true

require_relative '../../../step/tracker'

module Engine
  module Game
    module G18India
      module Step
        module Tracker

          # modified to prevent removal of province borders that had a cost (the cost is from a water border)
          def remove_border_calculate_cost!(tile, entity_or_entities, spender)
            # entity_or_entities is an array when combining private company abilities
            entities = Array(entity_or_entities)
            entity, *_combo_entities = entities

            hex = tile.hex
            types = []
            LOGGER.debug "Tracker::remove_border_calculate_cost >>"

            total_cost = tile.borders.dup.sum do |border|
              cost = border.cost ? border.cost : 0
              edge = border.edge
              neighbor = hex.neighbors[edge]
              next 0 if !hex.targeting?(neighbor) || !neighbor.targeting?(hex)

              types << border.type
              if border.type == :province && @game.phase.name != 'IV'
                # if the border is a province prior to phase IV, don't delete, instead change to gauge change border
                LOGGER.debug " >> MODIFY Borders!!!"
                tile.borders.delete(border)
                tile.borders << add_gauge_change_border(tile, edge)
                # remove old border and add gauge change to neighbor tile also
                neighbor.tile.borders.map! { |nb| nb.edge == hex.invert(edge) ? nil : nb }.compact!
                neighbor.tile.borders << add_gauge_change_border(neighbor.tile, hex.invert(edge))
                # add hex pair to gauge_change_marker array to to keep track of number of active markers (used for removal)
                @game.add_gauge_change_marker(hex, neighbor)
              else
                LOGGER.debug " >> DELETE Borders!!!"
                tile.borders.delete(border)
                neighbor.tile.borders.map! { |nb| nb.edge == hex.invert(edge) ? nil : nb }.compact!
              end
              cost - border_cost_discount(entity, spender, border, cost, hex)
            end
            [total_cost, types]
          end

          def add_gauge_change_border(tile, edge)
            new_border = Engine::Part::Border.new(edge, :gauge_change, nil)
            new_border.tile = tile
            new_border
          end
        end
      end
    end
  end
end
