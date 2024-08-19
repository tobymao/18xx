# frozen_string_literal: true

require_relative '../../../step/tracker'

module Engine
  module Game
    module G18India
      module Step
        module GaugeChangeBorder
          BORDER_TYPE_TO_CHANGE = :province
          STATUS_TO_DISABLE_CHANGE = 'no_gauge_change'
          GAUGE_CHANGE_COLOR = :red

          # modified to prevent removal of province borders that had a cost (the cost is from a water border)
          def remove_border_calculate_cost!(tile, entity_or_entities, spender)
            # entity_or_entities is an array when combining private company abilities
            entities = Array(entity_or_entities)
            entity, *_combo_entities = entities

            hex = tile.hex
            types = []
            LOGGER.debug 'GaugeChangeBorder::remove_border_calculate_cost Called >>'

            total_cost = tile.borders.dup.sum do |border|
              cost = border.cost || 0
              edge = border.edge
              neighbor = hex.neighbors[edge]
              next 0 if !hex.targeting?(neighbor) || !neighbor.targeting?(hex)

              types << border.type
              if border.type == BORDER_TYPE_TO_CHANGE
                # Remove the existing border on tile and neighbor
                remove_border(border, tile, neighbor)
                # Add a gauge change marker to tile and neighbor unless disabled by phase status
                unless @game.phase.status.include?(STATUS_TO_DISABLE_CHANGE)
                  LOGGER.debug ' >> Added Gauge Change Marker'
                  tile.borders << add_gauge_change_border(tile, edge)
                  neighbor.tile.borders << add_gauge_change_border(neighbor.tile, hex.invert(edge))
                  # Add hex pair to track of number of GC markers (Implement if markers are to be removed)
                  @game.add_gauge_change_marker(hex, neighbor)
                  @log << "Gauge Change Marker added between #{hex.id} and #{neighbor.id}"
                end
              elsif cost.positive? # Remove border with a cost from tile and connected neighbor (super)
                LOGGER.debug ' >> Removed border with a cost'
                remove_border(border, tile, neighbor)
              end
              cost - border_cost_discount(entity, spender, border, cost, hex)
            end
            [total_cost, types]
          end

          def remove_border(border, tile, neighbor)
            tile.borders.delete(border)
            neighbor.tile.borders.reject! { |nb| nb.edge == tile.hex.invert(border.edge) }
          end

          def add_gauge_change_border(tile, edge)
            new_border = Engine::Part::Border.new(edge, :gauge_change, nil, GAUGE_CHANGE_COLOR)
            new_border.tile = tile
            new_border
          end
        end
      end
    end
  end
end
