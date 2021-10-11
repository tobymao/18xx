# frozen_string_literal: true

require_relative '../../../step/buy_company'

module Engine
  module Game
    module G18GA
      module Step
        class BuyCompany < Engine::Step::BuyCompany
          def process_buy_company(action)
            super

            return unless action.company.sym == 'OSR'

            owner = action.company.owner
            return if owner.player? || owner.trains.size == @game.train_limit(owner) || @game.phase.available?('4')

            @game.add_free_two_train(owner)
          end
        end
      end
    end
  end
end
