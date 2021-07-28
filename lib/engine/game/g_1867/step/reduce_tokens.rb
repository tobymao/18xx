# frozen_string_literal: true

require_relative '../../../step/reduce_tokens'

module Engine
  module Game
    module G1867
      module Step
        class ReduceTokens < Engine::Step::ReduceTokens
          def move_tokens_to_surviving(surviving, others)
            super

            return unless surviving.tokens.size < 3

            # Add the $40 token back
            new_token = Engine::Token.new(surviving, price: 40)
            surviving.tokens << new_token
          end

          def help
            'When merging more than 2 minor corporations the new corporation can only keep 2 tokens.'\
              ' Choose which tokens to remove.'\
              ' After merging an additional token will be available on the charter.'
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
