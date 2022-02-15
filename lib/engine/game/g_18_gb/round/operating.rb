# frozen_string_literal: true

require_relative '../../../round/operating'
require_relative '../../../action/buy_train'
require_relative '../../../action/dividend'
require_relative '../../../action/pass'
require_relative '../../../action/run_routes'

module Engine
  module Game
    module G18GB
      module Round
        class Operating < Engine::Round::Operating
          attr_accessor :emergency_converted

          def start_operating
            super

            @emergency_converted = false
          end

          def after_process(action)
            entity = @entities[@entity_index]

            if entity.receivership? || @game.insolvent?(entity)
              case action
              when Engine::Action::RunRoutes
                # once an insolvent or receivership corporation runs its routes, automatically submit a Withhold for them
                process_action(Engine::Action::Dividend.new(entity, kind: 'withhold')) if action.routes.any?
              end
            end

            if entity.receivership? && @game.insolvent?(entity)
              case action
              when Engine::Action::Dividend
                # after dividend (withheld, as above) for a receivership corporation in insolvency, it reaches train buying

                # if the corporation is 5-share and cannot afford the cheapest train available, it will first convert to 10-share
                @game.convert_to_ten_share(entity, 3) if entity.type == '5-share' && entity.cash < @game.depot.min_depot_price

                # now the corporation buys the most expensive train that it can afford
                affordable_trains = @game.depot.depot_trains.select { |train| train.price < entity.cash }
                if affordable_trains.empty?
                  # none affordable - pass instead
                  process_action(Engine::Action::Pass.new(entity))
                else
                  train = affordable_trains.max_by(&:price)
                  process_action(Engine::Action::BuyTrain.new(entity, train: train, price: train.price))
                end
              end
            end

            super
          end

          def next_entity!
            after_operating(@entities[@entity_index])
            super
          end

          def after_operating(entity)
            return unless entity.corporation?

            if entity.trains.empty?
              @game.make_insolvent(entity)
            else
              @game.clear_insolvent(entity)
            end
          end
        end
      end
    end
  end
end
