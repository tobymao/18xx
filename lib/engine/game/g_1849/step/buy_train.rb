# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1849
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          attr_accessor :e_token

          def setup
            super
          end

          def pass!
            super
            @game.reorder_corps if @moved_any
            @moved_any = false
          end

          def process_sell_shares(action)
            price_before = action.bundle.shares.first.price
            super
            return unless price_before != action.bundle.shares.first.price

            @game.moved_this_turn << action.bundle.corporation
            @moved_any = true
          end

          def can_sell?(entity, bundle)
            # Corporation must complete its first operating round before its shares can be sold
            corporation = bundle.corporation
            return false unless corporation.operated?
            return false if @round.current_operator == corporation && corporation.operating_history.size < 2

            super
          end

          def buyable_trains(entity)
            # Cannot buy E-train without E-token
            trains_to_buy = super

            trains_to_buy = trains_to_buy.reject { |t| t.name == 'E' }
            trains_to_buy << e_train if @game.electric_dreams? && can_buy_e?(entity)
            trains_to_buy.uniq
          end

          def e_train
            @depot.depot_trains.find { |t| t.name == 'E' }
          end

          def can_buy_e?(entity)
            entity.e_token &&
              e_train.price <= entity.cash
          end

          def check_for_cheapest_train(train)
            entity = @game.round.current_operator

            cheapest = @depot.send(@game.electric_dreams? && !entity.e_token ? :min_depot_train_no_e_token : :min_depot_train)
            cheapest_names = names_of_cheapest_variants(cheapest)

            raise GameError, "Cannot purchase #{train.name} train: cheaper train available (#{cheapest_names.first})" unless
             cheapest_names.include?(train.name)
          end
        end
      end
    end
  end
end
