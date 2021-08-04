# frozen_string_literal: true

module Engine
  module Game
    module G1867
      module AutomaticLoan
        # Automatically take loans for an entity

        def buying_power(entity)
          @game.buying_power(entity, full: true)
        end

        def try_take_loan(entity, cost)
          return unless cost.positive?
          return unless cost > entity.cash

          @game.take_loan(entity, @game.loans.first) while entity.cash < cost && @game.can_take_loan?(entity)
        end
      end
    end
  end
end
