# frozen_string_literal: true

require_relative '../../../step/reduce_tokens'
require_relative 'minor_exchange'

module Engine
  module Game
    module G18Ardennes
      module Step
        class DeclineTokens < Engine::Step::ReduceTokens
          include MinorExchange

          ACTIONS_OVER_LIMIT = %w[remove_token].freeze
          ACTIONS_WITH_PASS = %w[remove_token pass].freeze

          def actions(entity)
            return [] unless current_entity == entity
            return [] unless @round.corporations_removing_tokens

            if over_limit?
              ACTIONS_OVER_LIMIT
            else
              ACTIONS_WITH_PASS
            end
          end

          def description
            'Choose tokens to remove'
          end

          def help
            if over_limit?
              'Choose tokens to remove to drop below limit of ' \
                "#{@game.class::LIMIT_TOKENS_AFTER_MERGER} tokens"
            else
              "#{major.id} may accept or decline minor #{minor.id}’s " \
                'tokens. Click on a token to discard it or click ‘Done’ ' \
                'to keep the tokens.'
            end
          end

          def pass_description
            'Done'
          end

          def available_hex(entity, hex)
            return false unless entity == major

            minor.tokens.any? { |t| t.used && t.city && t.hex == hex }
          end

          def process_pass(_action)
            locations = minor.placed_tokens.map { |t| token_location(t) }
            @log << "#{major.id} keeps minor #{minor.id}’s " \
                    "#{locations.one? ? 'token' : 'tokens'} " \
                    "in #{locations.join(' and ')}"
            minor.placed_tokens.each { |t| transfer_minor_token!(t, major) }
            close_minor!
          end

          def process_remove_token(action)
            token = action.city.tokens[action.slot]
            raise GameError, "Cannot remove #{token.corporation.id}’s token." unless token.corporation == minor

            remove_minor_token!(token)
            close_minor! if minor.placed_tokens.empty?
          end

          private

          def major
            @round.corporations_removing_tokens.first
          end

          def minor
            @round.corporations_removing_tokens.last
          end

          def over_limit?
            (major.placed_tokens.size + minor.placed_tokens.size) >
              @game.class::LIMIT_TOKENS_AFTER_MERGER
          end

          def close_minor!
            @game.close_corporation(minor)
            @round.corporations_removing_tokens = nil
          end
        end
      end
    end
  end
end
