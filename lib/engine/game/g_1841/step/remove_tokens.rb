# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1841
      module Step
        class RemoveTokens < Engine::Step::Base
          def description
            'Choose token to remove'
          end

          def actions(entity)
            return [] unless entity == pending_entity

            actions = ['remove_token']
            actions << 'pass' if pending_count >= pending_min
            actions
          end

          def active?
            pending_entity
          end

          def active_entities
            [pending_entity]
          end

          def pending_entity
            pending_removal[:entity]
          end

          def pending_hexes
            pending_removal[:hexes]
          end

          def pending_corporations
            pending_removal[:corporations]
          end

          def pending_count
            pending_removal[:count]
          end

          def pending_min
            pending_removal[:min]
          end

          def pending_max
            pending_removal[:max]
          end

          def pending_oo
            pending_removal[:oo] || false
          end

          def pending_removal
            @round.pending_removals&.first || {}
          end

          def round_state
            {
              pending_removals: [],
            }
          end

          def can_replace_token?(entity, token)
            available_hex(entity, token.city.hex) && pending_corporations.include?(token.corporation)
          end

          def pass!
            super
            return unless active?

            oo = pending_oo
            @round.pending_removals.shift
            return @game.merger_tokens_finish if oo

            @game.merger_finish
          end

          def process_remove_token(action)
            entity = action.entity
            city = action.city
            token = city.tokens[action.slot]
            hex = city.hex
            raise GameError, "Cannot remove #{token.corporation.name} token" unless can_replace_token?(entity, token)

            city_tokens = pending_corporations.first.tokens.select { |t| t.used && t.city.city? && !t.city.pass? }
            city_tokens.concat(pending_corporations.last.tokens.select { |t| t.used && t.city.city? && !t.city.pass? })
            city_tokens.compact!

            raise GameError, 'Cannot remove last non-pass token' if city_tokens.one? && token == city_tokens[0]

            @log << "#{entity.name} removes #{token.corporation.name} token from #{hex.name} (#{hex.location_name})"
            token.destroy!

            count = @round.pending_removals[0][:count] + 1
            @round.pending_removals[0][:count] = count

            return if count < pending_max

            oo = pending_oo
            @round.pending_removals.shift
            return @game.merger_tokens_finish if oo

            @game.merger_finish
          end

          def available_hex(entity, hex)
            return false unless entity == pending_entity

            pending_hexes.include?(hex)
          end
        end
      end
    end
  end
end
