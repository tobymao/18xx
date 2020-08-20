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

          free_two_train = Engine::Train.new(
            name: '2',
            distance: [
              {
                nodes: %w[city offboard],
                pay: 2,
                visit: 2,
              },
              {
                nodes: %w[town],
                pay: 99,
                visit: 99,
              },
            ],
            price: 0,
            rusts_on: '4'
          )
          free_two_train.buyable = false
          free_two_train.owner = owner
          owner.trains << free_two_train
          @game.trains << free_two_train
          @game.log << "#{owner.name} adds free 2 train"
        end
      end
    end
  end
end
