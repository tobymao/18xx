# frozen_string_literal: true

require_relative '../../../step/base'
require_relative 'tracker'

module Engine
  module Game
    module G1822
      module Step
        class Track < Engine::Step::Base
          include Engine::Game::G1822::Tracker

          ACTIONS = %w[lay_tile pass].freeze

          def actions(entity)
            return ['choose_ability'] unless choices_ability(entity).empty?
            return [] unless entity == current_entity
            return [] if entity.company? || !can_lay_tile?(entity)

            ACTIONS
          end

          def choices_ability(entity)
            return {} unless entity.company?

            @game.company_choices(entity, :track)
          end

          def description
            tile_lay = get_tile_lay(current_entity)
            return 'Lay Track' unless tile_lay

            if tile_lay[:lay] && tile_lay[:upgrade]
              'Lay/Upgrade Track'
            elsif tile_lay[:lay]
              'Lay Track'
            else
              'Upgrade Track'
            end
          end

          def pass_description
            @acted ? 'Done (Track)' : 'Skip (Track)'
          end

          def process_choose_ability(action)
            @game.company_made_choice(action.entity, action.choice, :track)
          end

          def process_lay_tile(action)
            old_tile = action.hex.tile

            lay_tile_action(action)
            pass! unless can_lay_tile?(action.entity)

            @game.after_lay_tile(action.hex, old_tile, action.tile)
          end

          def available_hex(entity_or_entities, hex)
            # entity_or_entities is an array when combining private company abilities
            entities = Array(entity_or_entities)
            entity, *_combo_entities = entities

            connected = hex_neighbors(entity, hex)
            return nil unless connected

            tile_lay = get_tile_lay(entity)
            return nil unless tile_lay

            color = hex.tile.color
            return nil if color == :white && !tile_lay[:lay]
            return nil if color != :white && !tile_lay[:upgrade]
            return nil if color != :white && tile_lay[:cannot_reuse_same_hex] && @round.laid_hexes.include?(hex)

            connected
          end
        end
      end
    end
  end
end
