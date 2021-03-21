# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1822
      module Step
        class DestinationToken < Engine::Step::Base
          ACTIONS = %w[hex_token pass].freeze

          def actions(entity)
            return [] unless entity == current_entity
            return [] unless can_place_token?(entity)

            ACTIONS
          end

          def available_tokens(entity)
            destination_token = entity.find_token_by_type(:destination)
            return [] unless destination_token

            [destination_token]
          end

          def can_place_token?(entity)
            return false if !entity.corporation? || (entity.corporation? && entity.type != :major)

            !available_tokens(entity).empty?
          end

          def description
            'Place the destination token'
          end

          def pass_description
            'Skip (Destination token)'
          end

          def available_hex(entity, hex)
            @game.class::DESTINATIONS[entity.id] == hex.name
          end

          def destination_node_check?(entity)
            destination_hex = @game.class::DESTINATIONS[entity.id]
            node_keys = @game.graph.connected_nodes(entity).keys
            node_keys.select(&:city?).any? { |c| c.hex.id == destination_hex }
          end

          def process_hex_token(action)
            entity = action.entity
            hex = action.hex
            token = action.token

            if !@game.loading && !destination_node_check?(entity)
              raise GameError, "Can't place the destination token on #{hex.name} "\
                               'because it is not connected'
            end

            @game.place_destination_token(entity, hex, token)
            pass!
          end

          def process_pass(action)
            entity = action.entity
            if !@game.loading && destination_node_check?(entity)
              raise GameError, "You can't skip placing your destination token when you have a connection "\
                               "to #{@game.class::DESTINATIONS[entity.id]}"
            end

            super
          end

          def skip!
            pass!
          end
        end
      end
    end
  end
end
