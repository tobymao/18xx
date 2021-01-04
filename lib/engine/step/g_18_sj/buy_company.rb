# frozen_string_literal: true

require_relative '../buy_company'

module Engine
  module Step
    module G18SJ
      class BuyCompany < BuyCompany
        def process_buy_company(action)
          return super unless action.company == @game.company_khj

          minor = @game.minor_khj
          buyer = action.entity
          train_count = minor.trains.size + buyer.trains.size

          if train_count > @game.phase.train_limit(buyer)
            @game.game_error("Cannot merge minor #{minor.name} as it exceeds train limit")
          end

          super

          @log << "#{minor.name} merges into #{buyer.name}"

          @game.remove_duplicate_tokens(buyer, minor)

          @game.remove_reservation(minor)

          @game.transfer_home_token(buyer, minor)

          transfer_trains(buyer, minor) if minor.trains.any?

          transfer_money(buyer, minor) if minor.cash.positive?

          minor.close!

          # Close company as it no longer has any effect
          action.company.close!
        end

        private

        # Any trains in minor are transfered, and made buyable
        # Rule 7.3 allows train to be reused during the OR.
        def transfer_trains(buyer, minor)
          minor.trains.each do |t|
            t.operated = false
            t.buyable = true
          end
          trains_transfered = minor.transfer(:trains, buyer).map(&:name)
          @log << "#{buyer.name} receives the trains: #{trains_transfered}"
        end

        def transfer_money(buyer, minor)
          @log << "#{buyer.name} receives treasury: #{@game.format_currency(minor.cash)}"
          minor.spend(minor.cash, buyer)
        end
      end
    end
  end
end
