# frozen_string_literal: true

require_relative '../buy_company'

module Engine
  module Step
    module G18GA
      class BuyCompany < BuyCompany
        def process_buy_company(action)
          super

          return unless action.company.sym == 'OSR'

          owner = action.company.owner
          return if owner.player? || owner.trains.size == @game.phase.train_limit(owner) || @game.phase.available?('4')

          @game.add_free_two_train(owner)
        end
      end
    end
  end
end
