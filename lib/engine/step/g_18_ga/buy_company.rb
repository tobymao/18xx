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
          return if owner.player? || owner.trains.size == @game.phase.train_limit || @game.phase.available?('4')

          free_two_train = @game.trains.select { |t| t.name == '2' }.last.dup
          free_two_train.buyable = false
          free_two_train.index = 5
          owner.buy_train(free_two_train, :free)
          @game.log << "#{owner.name} adds free 2 train"
        end
      end
    end
  end
end
