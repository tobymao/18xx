# frozen_string_literal: true

require_relative '../../../step/base'
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

            trains_to_buy = trains_to_buy.reject { |t| t.name == 'E' } unless @game.e_token?(entity)

            trains_to_buy.uniq
          end
        end
      end
    end
  end
end
