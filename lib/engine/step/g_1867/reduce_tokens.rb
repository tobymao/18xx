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
      end
    end
  end
end
