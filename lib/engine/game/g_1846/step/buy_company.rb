# frozen_string_literal: true

require_relative '../../../token'
require_relative '../../../step/buy_company'
require_relative 'receivership_skip'

module Engine
  module Game
    module G1846
      module Step
        class BuyCompany < Engine::Step::BuyCompany
          include ReceivershipSkip

          def description
            'Buy/Use Companies'
          end

          def assignable_corporations(company = nil)
            (@game.corporations + @game.minors).reject { |c| c.assigned?(company&.id) }
          end

          def room?(entity)
            entity.trains.reject(&:obsolete).size < @game.train_limit(entity)
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
            @game.buy_train(entity, train, :free)
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
end
