# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G1844
      module Step
        class MountainRailwayTrack < Engine::Step::SpecialTrack
          def description
            "Assign Revenue Marker for #{current_entity.name}"
          end

          def active_entities
            Array(@game.mountain_railways.find { |c| c.owner&.player? && c.abilities.find { |a| a.type == :tile_lay } })
          end

          def abilities(entity, **kwargs, &block)
            @game.abilities(entity, :tile_lay, time: 'stock_round', **kwargs, &block)
          end

          def blocks?
            true
          end

          def help
            "Select mountain hex and revenue marker for #{current_entity.name}."
          end

          def available_hex(_entity, hex)
            abilities(current_entity).hexes.include?(hex.id) &&
              hex.tile.offboards.first.max_revenue.zero?
          end

          def upgradeable_tiles(entity, _hex)
            ability = abilities(entity)
            @game.tiles.select { |t| ability.tiles.include?(t.name) }.uniq(&:name)
          end

          def potential_tile_colors(_entity, _hex)
            [:gray]
          end

          def process_lay_tile(action)
            tile = action.tile
            hex = action.hex
            company = action.entity

            ability = abilities(company)
            raise GameError, "#{company.name} cannot lay on hex #{hex.name}" unless ability.hexes.include?(hex.id)
            raise GameError, "#{company.name} cannot lay tile #{tile.name}" unless ability.tiles.include?(tile.name)

            revenue = tile.offboards.first.revenue
            hex.tile.offboards.first.parse_revenue(revenue.map { |color, value| "#{color}_#{value}" }.join('|'))
            hex.assign!(company.id)
            @log << "#{company.name} places #{revenue.values.join('/')} revenue marker on #{hex.location_name} (#{hex.name})"

            @game.tiles.delete(tile)
            company.remove_ability(ability)
          end
        end
      end
    end
  end
end
