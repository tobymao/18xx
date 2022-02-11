# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1866
      module Step
        class BuyInfrastructure < Engine::Step::BuyTrain
          def actions(entity)
            if entity.corporation? && @game.corporation?(entity) && !@game.buyable_infrastructure.empty? &&
              can_buy_train?(entity)
              return %w[buy_train pass]
            end

            []
          end

          def buyable_trains(entity)
            @game.buyable_infrastructure.reject { |i| entity.trains.any? { |t| i.name == t.name } }
          end

          def buying_power(entity)
            @game.buying_power_with_loans(entity)
          end

          def can_buy_train?(entity = nil, _shell = nil)
            min_infrastructure = @game.buyable_infrastructure.min_by(&:price)
            room?(entity) && min_infrastructure.price <= buying_power(entity)
          end

          def ebuy_president_can_contribute?(_corporation)
            false
          end

          def description
            'Buy Infrastructure'
          end

          def must_buy_train?(_entity)
            false
          end

          def pass_description
            @acted ? 'Done (infrastructure)' : 'Skip (infrastructure)'
          end

          def president_may_contribute?(_entity, _shell = nil)
            false
          end

          def process_buy_train(action)
            entity = action.entity
            train = action.train
            if entity.trains.any? { |t| t.name == train.name }
              raise GameError, "Can't buy #{train.name} infrastructure, already got one"
            end

            @game.buy_infrastructure(entity, train)
          end

          def room?(entity, _shell = nil)
            entity.trains.count { |t| @game.infrastructure_train?(t) } < @game.infrastructure_limit(entity)
          end

          def skip!
            pass!
          end
        end
      end
    end
  end
end
