# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1856
      module Step
        class RemoveTokens < Engine::Step::Base
          def description
            'Choose token(s) to remove'
          end

          def actions(entity)
            return [] unless entity == pending_entity

            %w[remove_token]
          end

          def active?
            pending_entity
          end

          def active_entities
            [pending_entity]
          end

          def pending_entity
            duplicate_token[:corp] || pending_removal[:corp]
          end

          def pending_removal
            @round.pending_removals&.first || {}
          end

          def duplicate_token
            @round.duplicate_tokens&.first || {}
          end

          def round_state
            {
              duplicate_tokens: [],
              pending_removals: [],
            }
          end

          # duplicate tokens, then pending_removal
          def hexes
            (duplicate_token && duplicate_token[:hexes]) || pending_removal[:hexes]
          end

          def corps
            [(duplicate_token && duplicate_token[:corp]) || pending_removal[:corp]]
          end

          def can_replace_token?(entity, token)
            available_hex(entity, token.city.hex) && corps.include?(token.corporation) &&
            # duplicate tokens first
            (!duplicate_token[:tokens] || duplicate_token[:tokens].include?(token))
          end

          def process_remove_token(action)
            entity = action.entity
            city = action.city
            token = city.tokens[action.slot]
            hex = city.hex
            raise GameError, "Cannot remove #{token.corporation.name} token" unless can_replace_token?(entity, token)

            @log << "#{entity.name} removes token from #{hex.name} (#{hex.location_name})"
            token.destroy!

            @round.duplicate_tokens.shift unless @round.duplicate_tokens.empty?
            return if @round.pending_removals.empty?

            count = @round.pending_removals[0][:count] - 1
            @round.pending_removals[0][:count] = count if count.positive?

            return unless count.zero?

            @round.pending_removals.shift
          end

          def available_hex(entity, hex)
            return false unless entity == pending_entity

            hexes.include?(hex)
          end
        end
      end
    end
  end
end
