# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18NY
      module Step
        class ClaimCoalToken < Engine::Step::Base
          ACTIONS = %w[claim_hex_token pass].freeze

          def actions(entity)
            return [] unless entity == current_entity

            ACTIONS
          end

          def auto_actions(entity)
            actions = []
            if allowed_to_claim_coal?(entity)
              @game.connected_coal_hexes(entity)&.each do |hex|
                actions << Engine::Action::ClaimHexToken.new(entity, hex: hex, token_type: :coal)
              end
            end
            actions << Engine::Action::Pass.new(entity) if actions.empty?
            actions
          end

          def allowed_to_claim_coal?(entity)
            @game.coal_fields_private.closed? || @game.coal_fields_private.owner == entity
          end

          def coal_to_claim?(entity)
            allowed_to_claim_coal?(entity) && !@game.connected_coal_hexes(entity).empty?
          end

          def can_claim_coal_on_hex?(entity, hex)
            allowed_to_claim_coal?(entity) && @game.connected_coal_hexes(entity).include?(hex)
          end

          def process_claim_hex_token(action)
            entity = action.entity
            hex = action.hex
            if !@game.loading && !can_claim_coal_on_hex?(entity, hex)
              raise GameError, "#{entity.name} cannot claim coal token at #{hex.name} (#{hex.location_name})"
            end

            @game.claim_coal_token(entity, hex)
          end

          def log_pass(entity) end
        end
      end
    end
  end
end
