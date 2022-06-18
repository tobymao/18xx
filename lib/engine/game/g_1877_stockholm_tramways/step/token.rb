# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G1877StockholmTramways
      module Step
        class Token < Engine::Step::Token
          def actions(entity)
            return [] if @game.sl

            super
          end

          def log_skip(entity)
            super unless @game.sl
          end
        end
      end
    end
  end
end
