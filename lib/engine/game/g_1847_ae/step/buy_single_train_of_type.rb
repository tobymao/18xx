# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1847AE
      module Step
        class BuySingleTrainOfType < Engine::Step::BuySingleTrainOfType
          def buyable_trains(entity)
            # Can't buy trains from other corporations in phase 3
            return super if @game.phase.status.include?('can_buy_trains')

            super.select(&:from_depot?)
          end

          def process_buy_train(action)
            from_discard = @depot.discarded.include?(action.train)
            super

            lfk = @game.lfk
            return if @game.train_bought_this_round || !lfk.floated? || from_discard

            lfk_owner = lfk.owner
            if lfk_owner.player?
              lfk_revenue = action.train.price / 10
              @game.bank.spend(lfk_revenue, lfk_owner)
              @log << "#{lfk.name} pays #{@game.format_currency(lfk_revenue)} to #{lfk_owner.name}"
            end
            old_lfk_price = lfk.share_price
            @game.stock_market.move_right(lfk)
            @game.log_share_price(lfk, old_lfk_price)
            @game.train_bought_this_round = true
          end

          def can_sell?(entity, bundle)
            # LFK is always sellable
            return super unless bundle.corporation == @game.lfk

            return false if entity != bundle.owner

            selling_minimum_shares?(bundle)
          end
        end
      end
    end
  end
end
