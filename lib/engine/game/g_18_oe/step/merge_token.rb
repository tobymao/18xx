# frozen_string_literal: true

require_relative '../../g_18_eu/step/replace_token'

module Engine
  module Game
    module G18OE
      module Step
        class MergeToken < G18EU::Step::ReplaceToken
          def auto_actions(_entity)
            []
          end

          def active?
            !!pending_acquisition && placed_tokens.any?
          end

          def pass_description
            'Decline Token'
          end

          def pending_token
            placed_tokens.first
          end

          def process_place_token(action)
            entity = action.entity
            raise GameError, "Cannot place a token on #{action.city.hex.name}" unless available_city?(entity, action.city)

            new_token = pending_corporation.unplaced_tokens.max_by(&:price)

            pending_token.remove!
            action.city.exchange_token(new_token)
            @game.log << "#{pending_corporation.name} replaces #{pending_minor.name} token on #{action.city.hex.name}"

            resolve_forced!
          end

          def process_pass(_action)
            decline!(pending_token, 'declines')
            resolve_forced!
          end

          def resolve_forced!
            return unless pending_acquisition

            placed_tokens.select { |token| forced_decline?(token) }.each { |token| decline!(token, 'must decline') }
            close_minor! if placed_tokens.empty?
          end

          private

          def placed_tokens
            pending_minor.tokens.select(&:used)
          end

          def forced_decline?(token)
            pending_corporation.unplaced_tokens.empty? ||
              token.city.hex.tile.cities.any? { |city| city.tokened_by?(pending_corporation) }
          end

          def decline!(token, verb)
            hex_name = token.city.hex.name
            token.remove!
            @game.log << "#{pending_corporation.name} #{verb} #{pending_minor.name} token on #{hex_name}"
          end

          def close_minor!
            @game.close_corporation(pending_minor)
            @round.pending_acquisition = nil
          end
        end
      end
    end
  end
end
