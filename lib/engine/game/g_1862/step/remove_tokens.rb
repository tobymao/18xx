# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1862
      module Step
        class RemoveTokens < Engine::Step::Base
          def description
            'Choose token to remove'
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
            pending_removal[:survivor]
          end

          def pending_removal
            @round.pending_removals&.first || {}
          end

          def round_state
            {
              pending_removals: [],
            }
          end

          def hexes
            pending_removal[:hexes]
          end

          def corps
            [pending_removal[:survivor], pending_removal[:nonsurvivor]]
          end

          def can_replace_token?(entity, token)
            available_hex(entity, token.city.hex) && corps.include?(token.corporation)
          end

          def process_remove_token(action)
            entity = action.entity
            city = action.city
            token = city.tokens[action.slot]
            hex = city.hex
            raise GameError, "Cannot remove #{token.corporation.name} token" unless can_replace_token?(entity, token)

            @log << "#{entity.name} removes token from #{hex.name} (#{hex.location_name})"
            token.destroy!

            count = @round.pending_removals[0][:count] - 1
            @round.pending_removals[0][:count] = count

            return unless count.zero?

            @round.pending_removals.shift
            @game.finish_merge
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
