# frozen_string_literal: true

require_relative '../../../round/operating'
require_relative '../../../action/dividend'
require_relative '../../../action/run_routes'

module Engine
  module Game
    module G1846
      module Round
        class Operating < Engine::Round::Operating
          attr_accessor :emergency_issued

          def after_setup
            super unless @game.block_for_steamboat?
          end

          def start_operating
            super

            @emergency_issued = false
          end

          def after_process(action)
            if (entity = @entities[@entity_index]).receivership?
              case action
              when Engine::Action::Bankrupt
                receivership_train_buy(self, :process_action) unless @game.bankruptcy_limit_reached?
              when Engine::Action::RunRoutes
                process_action(Engine::Action::Dividend.new(entity, kind: 'withhold'))
              end
            end

            super
          end

          def receivership_train_buy(obj, method)
            entity = @entities[@entity_index]

            return unless entity.receivership?

            return unless entity.trains.empty?

            train = @game.depot.min_depot_train
            name, variant = train.variants.min_by { |_, v| v[:price] }
            price = variant[:price]

            return if entity.cash < price

            action = Action::BuyTrain.new(
              entity,
              train: train,
              price: price,
              variant: name,
            )

            obj.send(method, action)
          end
        end
      end
    end
  end
end
