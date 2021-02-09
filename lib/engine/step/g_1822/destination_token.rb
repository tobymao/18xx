# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G1822
      class DestinationToken < Base
        ACTIONS = %w[hex_token].freeze

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
          return false if available_tokens(entity).empty?

          destination_hex = @game.class::DESTINATIONS[entity.id]
          parts = @game.graph.connected_nodes(entity).keys
          parts.select(&:city?).any? { |c| c.hex.id == destination_hex }
        end

        def description
          'Place the destination token'
        end

        def available_hex(entity, hex)
          @game.class::DESTINATIONS[entity.id] == hex.name
        end

        def process_hex_token(action)
          entity = action.entity
          hex = action.hex
          token = action.token

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
