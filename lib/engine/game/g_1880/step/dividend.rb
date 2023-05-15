# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/minor_withold'

module Engine
  module Game
    module G1880
      module Step
        class Dividend < Engine::Step::Dividend
          include Engine::Step::MinorWithold

          def share_price_change(entity, revenue = 0)
            return {} if @game.communism

            super
          end
        end
      end
    end
  end
end
