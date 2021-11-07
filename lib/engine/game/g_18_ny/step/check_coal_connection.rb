# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18NY
      module Step
        class CheckCoalConnection < Engine::Step::Base
          ACTIONS = %w[claim_hex_token].freeze

          def actions(entity)
            return [] unless entity == current_entity
            return ACTIONS if @game.loading

            actions = []
            @entity = nil

            if coal_to_claim?(entity)
              @entity = entity
              actions = ACTIONS
            end

            actions
          end

          def blocks?
            @entity
          end

          def auto_actions(entity)
            actions = []

            if allowed_to_claim_coal?(entity)
              @game.connected_coal_hexes(entity)&.each do |hex|
                actions << Engine::Action::ClaimHexToken.new(entity, hex: hex, token_type: :coal)
              end
            end

            actions
          end

          def allowed_to_claim_coal?(entity)
            @game.coal_fields_private.closed? || @game.coal_fields_private.owner == entity
          end

          def coal_to_claim?(entity)
            allowed_to_claim_coal?(entity) && @game.connected_coal_hexes(entity).any?
          end

          def process_claim_hex_token(action)
            @game.claim_coal_token(action.entity, action.hex)
          end
        end
      end
    end
  end
end
