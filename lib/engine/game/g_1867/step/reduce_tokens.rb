# frozen_string_literal: true

require_relative '../../../step/reduce_tokens'

module Engine
  module Game
    module G1867
      module Step
        class ReduceTokens < Engine::Step::ReduceTokens
          def description
            "Choose tokens to remove"
          end

          def survivor_tokens_in_same_hex(corporation)
            corporation.placed_tokens.size - corporation.placed_tokens.map(&:hex).uniq.size
          end

          def survivor_tokens_over_limit?(corporation)
            corporation.placed_tokens.size - survivor_tokens_in_same_hex(corporation) >
              @game.class::LIMIT_TOKENS_AFTER_MERGER
          end

          def move_tokens_to_surviving(surviving, others)
            super

            return unless surviving.tokens.size < 3

            # Add the $40 token back
            new_token = Engine::Token.new(surviving, price: 40)
            surviving.tokens << new_token
          end

          def help
            corporation = current_entity
            issues = []
            if survivor_tokens_over_limit?(corporation)
              issues << 'can only keep two tokens'
            end
            if survivor_tokens_in_same_hex(corporation).positive?
              issues << 'cannot have two tokens in the same hex'
            end

            "The new public company #{issues.join(' and ')}. Choose which tokens to remove."
          end

          def available_hex(entity, hex)
            return false unless entity == surviving

            # 1867 only has the surviving corp, so see if tokens are used
            surviving_tokens = entity.tokens.select { |t| t.used && t.city.hex == hex }
            # Force user to clear up the NY tile first, then choose the others
            if surviving_tokens.size > 1
              [hex]
            else
              super
            end
          end
        end
      end
    end
  end
end
