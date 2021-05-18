# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G1862
      module Round
        class Stock < Engine::Round::Stock
          # prolong the round for missed obligations
          def finished?
            @game.finished || (@entities.all?(&:passed?) && @pending_forced_sales.empty?)
          end

          def finish_round
            @game.enforce_obligations
          end
        end
      end
    end
  end
end
