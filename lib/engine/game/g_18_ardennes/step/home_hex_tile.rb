# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/tracker'

module Engine
  module Game
    module G18Ardennes
      module Step
        class HomeHexTile < Engine::Step::Base
          include Engine::Step::Tracker
          ACTIONS = %w[lay_tile].freeze

          def actions(entity)
            return [] unless entity == pending_entity

            ACTIONS
          end

          def round_state
            super.merge({ minor_floated: nil })
          end

          def description
            "Place home tile for minor #{pending_entity.id}"
          end

          def active?
            pending_entity && home_hex.tile.color == :white
          end

          def visible?
            true
          end

          def players_visible?
            true
          end

          def current_entity
            pending_entity
          end

          def pending_entity
            @round.minor_floated
          end

          def active_entities
            [pending_entity.owner]
          end

          def available
            [pending_entity]
          end

          def home_hex
            @game.hex_by_id(pending_entity.coordinates)
          end

          def available_hex(entity, hex)
            tracker_available_hex(entity, hex)
          end

          def process_lay_tile(action)
            lay_tile_action(action)
            @round.minor_floated = nil

            # M7 gets a mine token from its home hex
            hex = action.hex
            return if hex.tokens.empty?

            corporation = action.entity
            corporation.assign!(hex.coordinates)
            token_type = @game.dummy_token_type(hex.tokens.first)
            hex.tokens.first.remove!
            @game.log << "#{corporation.id} collects a #{token_type} token " \
                         "from hex #{hex.coordinates} (#{hex.location_name})"
          end
        end
      end
    end
  end
end
