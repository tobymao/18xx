# frozen_string_literal: true

require_relative '../../../step/reduce_tokens'

module Engine
  module Game
    module G1817
      module Step
        class ReduceTokens < Engine::Step::ReduceTokens
          def description
            'Choose token to remove in hexes with multiple tokens, and then remove tokens to drop below limit of '\
              "#{@game.class::LIMIT_TOKENS_AFTER_MERGER} tokens"
          end
        end
      end
    end
  end
end
