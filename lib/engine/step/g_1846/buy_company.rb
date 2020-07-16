# frozen_string_literal: true

require_relative '../../token'

module Engine
  module Step
    module G1846
      class BuyCompany < BuyCompany
        def room?(entity)
          entity.trains.reject(&:obsolete).size < @game.phase.train_limit
        end

        def process_buy_company(action)
          entity = action.entity
          super

          company = action.company
          return unless (minor = @game.minor_by_id(company.id))
          raise GameError, 'Cannot buy minor because train tight' unless room?(entity)

          cash = minor.cash
          minor.spend(cash, entity) if cash.positive?
          train = minor.trains[0]
          train.buyable = true
          entity.buy_train(train, :free)
          minor.tokens[0].swap!(Engine::Token.new(entity))
          @log << "#{entity.name} receives #{@game.format_currency(cash)}"\
            ", a 2 train, and a token on #{minor.coordinates}"
          @game.minors.delete(minor)
          @game.graph.clear
        end
      end
    end
  end
end
