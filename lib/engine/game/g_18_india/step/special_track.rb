# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G18India
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack

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

          # Bypass some Step::Tracker tests for Town to City upgrade: maintain exits, and check new exits are valid
          # check tile color to active ability
          def legal_tile_rotation?(entity, hex, tile)
            return false unless (ability = abilities(entity))
            return false if tile.color != :yellow && ability.upgrade_count.zero?
            return false if tile.color == :yellow && ability.lay_count.zero?

            old_tile = hex.tile
            if @game.yellow_town_to_city_upgrade?(old_tile, tile)
              all_new_exits_valid = tile.exits.all? { |edge| hex.neighbors[edge] }
              return false unless all_new_exits_valid

              return (old_tile.exits - tile.exits).empty?
            end

            super
          end

          # highlight according to active ability
          def available_hex(entity, hex)
            return unless (ability = abilities(entity))
            return tracker_available_hex(entity, hex) if ability.hexes&.empty? && ability.consume_tile_lay

            color = hex.tile.color
            return nil if color != :white && ability.upgrade_count.zero?
            return nil if color == :white && ability.lay_count.zero?

            hex_neighbors(entity, hex)
          end
        end
      end
    end
  end
end
