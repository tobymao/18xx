# frozen_string_literal: true

require_relative '../../../step/bankrupt'

module Engine
  module Game
    module G18Rhl
      module Step
        class Bankrupt < Engine::Step::Bankrupt
          def process_bankrupt(action)
            corp = action.entity
            player = corp.owner

            @log << "-- #{player.name} goes bankrupt and sells remaining shares --"

            # validate after emergency issuing to fix the math in the exception message
            unless @game.can_go_bankrupt?(player, corp)
              buying_power = @game.format_currency(@game.total_emr_buying_power(player, corp))
              price = @game.format_currency(@game.depot.min_depot_price)

              msg = "Cannot go bankrupt. #{corp.name}'s cash plus #{player.name}'s cash and "\
                    "sellable shares total #{buying_power}, and the cheapest train in the "\
                    "Depot costs #{price}."

              raise GameError, msg
            end

            # next the president sells all normally allowed shares
            player.shares_by_corporation(sorted: true).each do |corporation, _|
              next unless corporation.share_price # if a corporation has not parred
              next unless (bundle = @game.sellable_bundles(player, corporation).max_by(&:price))

              @game.sell_shares_and_change_price(bundle)
            end

            president_contribution = player.cash

            # finally, the president discards all their remaining shares, regardless of 50% and
            # presidency restrictions, not changing any share prices
            player.shares_by_corporation(sorted: true).each do |corporation, shares|
              next unless corporation.share_price # if a corporation has not parred
              next if shares.empty?

              bundle = ShareBundle.new(shares)
              @game.share_pool.transfer_shares(bundle, @game.share_pool, allow_president_change: true)

              next if corporation.owner != player || !corporation.share_price.price.positive?

              @log << "-- #{corporation.name} enters receivership (it has no president) --"
              @log << 'As long as it is in receivership it cannot lay track or put token - and will withhold'
              corporation.owner = @game.share_pool
            end

            # reset last share sold stuff so that the new president isn't
            # restricted from buying any trains
            @game.active_step.last_share_sold_price = nil

            unless player.companies.empty?
              @log << "#{player.name}'s companies close: #{player.companies.map(&:sym).join(', ')}"
              player.companies.dup.each(&:close!)
            end

            if player.cash.positive?
              @log << "#{@game.format_currency(player.cash)} is transferred from "\
                      "#{player.name} to bank"
              player.spend(player.cash, @game.bank)
            end

            @game.declare_bankrupt(player)

            return unless corp.owner == @game.share_pool

            remaining = corp.cash
            cheapest = @game.depot.min_depot_train
            price = cheapest.price - remaining - president_contribution
            source = cheapest.owner
            @log << "#{corp.name} buys a #{cheapest.name} train for #{cheapest.price} from #{source.name}, "\
                    "using previous president's cash of #{format(president_contribution)}, the treasury "\
                    "of #{format(remaining)} and the Bank paying the remaining #{format(price)}"
            corp.spend(remaining, @game.bank) if remaining.positive?
            @game.buy_train(corp, cheapest, :free)
            @game.phase.buying_train!(corp, cheapest, source)
            fee = 100
            bank_loan = price + fee
            corp.spend(bank_loan, @game.bank, check_cash: false)
            @log << "#{corp.name} need to borrow #{format(bank_loan)} from the Bank, including the #{format(fee)} fee"
          end

          def format(amount)
            @game.format_currency(amount)
          end
        end
      end
    end
  end
end
