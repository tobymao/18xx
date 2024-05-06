# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1849
      module Step
        class BuyTrain < Engine::Step::BuyTrain
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

            trains_to_buy = trains_to_buy.reject { |t| t.name == 'E' } unless entity.e_token == true
            trains_to_buy.uniq
          end

          def e_train
            @depot.depot_trains.find { |t| t.name == 'E' }
          end

          def can_buy_e?(entity)
            e_train.price <= entity.cash &&
              entity.e_token == true
          end
        end
      end
    end
  end
end
