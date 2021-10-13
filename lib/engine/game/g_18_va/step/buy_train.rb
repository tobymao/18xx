# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18VA
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            return ['choose_ability'] if entity == @game.token_company && current_entity == @game.token_company.owner

            actions = super

            return ['pass'] if actions.empty? && @game.token_company.owner == entity

            super
          end

          def buyable_trains(entity)
            depot_trains = @depot.depot_trains
            other_trains = @depot.other_trains(entity)

            if entity.cash < @depot.min_depot_price
              depot_trains = [@depot.min_depot_train]

              other_trains.reject! { |t| t.price < spend_minmax(entity, t).first } if @last_share_sold_price
            end

            # A corp with zero cash may buy trains from other corps if and only if the president sells no shares.
            other_trains = [] if entity.cash.zero? && @last_share_sold_price

            other_trains.reject! { |t| entity.cash < t.price && must_buy_at_face_value?(t, entity) }

            # Trainbuying in 18VA is like 1836jr except 4D trains are exempt
            other_trains + (depot_trains.reject do |x|
                              @round.bought_depot_trains.include?(x.sym) &&
                              !@game.depot.discarded.include?(x) && x.name != '4D'
                            end)
          end

          def round_state
            {
              bought_depot_trains: [],
            }
          end

          def setup
            super
            @round.bought_depot_trains = []
          end

          def choices_ability(entity)
            return {} unless entity.company?

            { 'close' => 'Close to increase train limit by 1 permanently' }
          end

          def process_choose_ability(_action)
            @game.log << "#{@game.token_company.name} closes to give #{current_entity.name} an increased train limit"
            current_entity.add_ability(
              Ability::TrainLimit.new(
                type: 'train_limit',
                description: '+1 train limit',
                increase: 1
              )
            )
            @game.token_company.close!
          end

          def spend_minmax(entity, train)
            if entity.cash.zero? && (buying_power(entity) < train.price)
              [1, [train.price, buying_power(entity) + entity.owner.cash].min]
            else
              [1, buying_power(entity)]
            end
          end

          def process_buy_train(action)
            # Since the train won't be in the depot after being bought store the state now.
            from_depot = action.train.from_depot?
            super

            return unless from_depot

            @round.bought_depot_trains << action.train.sym

            pass! if buyable_trains(action.entity).empty?
          end
        end
      end
    end
  end
end
