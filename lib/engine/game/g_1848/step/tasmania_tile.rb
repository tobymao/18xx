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
            active_entities.any?
          end

          def active_entities
            return [] if !@game.private_closed_triggered || @game.tasmania.closed?

            [@game.tasmania].compact
          end

          def process_lay_tile(action)
            super
            @active_entity = nil
          end

          def available_hex(_entity, hex)
            @game.tasmania.abilities.first.hexes&.include?(hex.id)
          end

          def potential_tiles(_entity, _hex)
            @game.tiles.select { |tile| tile.color == 'blue' }
          end

          def upgradeable_tiles(_entity, ui_hex)
            super(@game.tasmania, ui_hex)
          end

          def abilities(_entity, **_kwargs)
            @game.tasmania.abilities.first
          end

          def hex_neighbors(_entity, hex)
            @game.hex_by_id(hex.id).neighbors.keys
          end

          def lay_tile(action, spender: nil)
            super(action, spender: nil, ignore_abilities: true)
          end
        end
      end
    end
  end
end
