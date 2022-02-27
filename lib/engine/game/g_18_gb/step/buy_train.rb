# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18GB
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            return [] if entity.receivership? && entity.trains.any?
            return [] if entity != current_entity

            actions = []
            actions << 'convert' if can_convert?(entity)
            actions << 'buy_train' if can_buy_train?(entity)
            actions << 'pass' if !actions.empty? && !must_buy_train?(entity)
            actions
          end

          def help
            return super unless can_convert?(current_entity)

            "#{current_entity.id} may choose to convert to a 10-share corporation, dropping 3 steps in price and issuing 5 new "\
              "shares to the market. As president, #{current_entity.owner.name} will then be permitted to purchase one share."
          end

          def can_convert?(corporation)
            return false unless corporation&.corporation?

            corporation.type == :'5-share' && corporation.trains.empty? && corporation.cash < @game.depot.min_depot_price
          end

          def convert_text
            capital_str = @game.format_currency(@game.convert_capital(current_entity, true))
            "Convert to 10-share (#{capital_str})"
          end

          def process_convert(action)
            return unless action.entity.corporation? && can_convert?(action.entity)

            @game.convert_to_ten_share(action.entity, 3)
            @round.emergency_converted = true
          end

          def president_may_contribute?
            false
          end

          def spend_minmax(_entity, train)
            [1, train.price * 2]
          end

          def illegal_train_buy?(entity, train)
            entity.receivership? || train.owner.receivership? || (!entity.trains.empty? && train.owner.trains.size < 2)
          end

          def buyable_trains(entity)
            depot_trains = @depot.depot_trains
            depot_trains = [] if entity.cash < @depot.min_depot_price

            other_trains = @depot.other_trains(entity)
            other_trains = [] if entity.cash.zero? || must_buy_new_train?(entity)
            other_trains.reject! { |t| illegal_train_buy?(entity, t) }

            depot_trains + other_trains
          end

          def must_buy_new_train?(entity)
            must_buy_train?(entity) && @round.emergency_converted
          end

          def must_buy_train?(entity)
            mandatory = @game.depot.max_depot_price
            entity.trains.empty? && mandatory.positive? && entity.cash >= mandatory
          end
        end
      end
    end
  end
end
