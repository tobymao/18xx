# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G1848
      module Step
        class TasmaniaTile < G1848::Step::SpecialTrack
          def actions(_entity)
            return [] if !@game.private_closed_triggered || @game.tasmania.closed?

            if @active_entity.nil?
              @active_entity = @game.tasmania
              @game.log << "#{@game.tasmania.name} must lay tasmania tile"
            end

            ['lay_tile']
          end

          def description
            'Tasmania tile'
          end

          def blocks?
            @game.tasmania
          end

          def active?
            !active_entities.empty?
          end

          def active_entities
            return [] if !@game.private_closed_triggered || @game.tasmania.closed?

            [@game.tasmania].compact
          end

          def tasmania_player_ability
            @tasmania_player_ability ||= Engine::Ability::TileLay.new(
              type: tasmania_ability.type,
              hexes: tasmania_ability.hexes,
              tiles: tasmania_ability.tiles,
              owner_type: 'player',
              special: tasmania_ability.special,
              count: tasmania_ability.count,
              free: tasmania_ability.free,
              when: 'any',
            )
          end

          def process_lay_tile(action)
            action.entity.add_ability(tasmania_player_ability)
            super
            @active_entity = nil
          end

          def available_hex(_entity, hex)
            tasmania_ability.hexes&.include?(hex.id)
          end

          def potential_tiles(_entity, _hex)
            @game.tiles.select { |t| tasmania_ability.tiles.include?(t.name) }
          end

          def upgradeable_tiles(_entity, ui_hex)
            super(@game.tasmania, ui_hex)
          end

          def hex_neighbors(_entity, hex)
            @game.hex_by_id(hex.id).neighbors.keys
          end

          def tasmania_ability
            @tasmania_ability ||= @game.tasmania.abilities.first
          end
        end
      end
    end
  end
end
