# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G1822
      class DestinationToken < Base
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

        def process_hex_token(action)
          entity = action.entity
          hex = action.hex
          token = action.token

          unless @game.loading
            destination_hex = @game.class::DESTINATIONS[entity.id]
            node_keys = @game.graph.connected_nodes(entity).keys
            found_connected_city = node_keys.select(&:city?).any? { |c| c.hex.id == destination_hex }
            raise GameError, "Cannot place the destination token on #{hex.name} "\
                             'because it is not connected' unless found_connected_city
          end

          @game.place_destination_token(entity, hex, token)
          pass!
        end

        def skip!
          pass!
        end
      end
    end
  end
end
