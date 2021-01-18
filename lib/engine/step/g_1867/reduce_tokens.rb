# frozen_string_literal: true

require_relative '../reduce_tokens'

module Engine
  module Step
    module G1867
      class ReduceTokens < ReduceTokens
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
      end
    end
  end
end
