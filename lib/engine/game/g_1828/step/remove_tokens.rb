# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1828
      module Step
        class RemoveTokens < Engine::Step::Base
          REMOVE_TOKEN_ACTIONS = %w[remove_token].freeze

          def description
            'Choose token to remove'
          end

          def actions(entity)
            return [] unless current_entity == entity

            REMOVE_TOKEN_ACTIONS
          end

          def active?
            corporation
          end

          def active_entities
            [corporation]
          end

          def round_state
            {
              corporation_removing_tokens: nil,
              hexes_to_remove_tokens: [],
            }
          end

          def corporation
            @round.corporation_removing_tokens
          end

          def hexes
            @round.hexes_to_remove_tokens
          end

          def can_replace_token?(entity, token)
            available_hex(entity, token.city.hex)
          end

          def process_remove_token(action)
            entity = action.entity
            city = action.city
            token = city.tokens[action.slot]
            hex = city.hex
            raise GameError, "Cannot remove #{token.corporation.name} token" unless available_hex(entity, hex)

            @log << "#{entity.name} removes token from #{hex.name} (#{hex.location_name})"
            token.destroy!
            @game.place_blocking_token(hex, city: city)

            hexes.delete(hex)
            @round.corporation_removing_tokens = nil if hexes.empty?
          end

          def available_hex(entity, hex)
            return false unless entity == corporation

            hexes.include?(hex)
          end
        end
      end
    end
  end
end
