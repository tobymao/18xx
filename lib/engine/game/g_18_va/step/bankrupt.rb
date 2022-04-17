# frozen_string_literal: true

require_relative '../../../step/bankrupt'

module Engine
  module Game
    module G18VA
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

            corps_to_close = {}
            # finally, the president discards all their remaining shares, regardless of 50% and
            # presidency restrictions, not changing any share prices
            player.shares_by_corporation(sorted: true).each do |corporation, shares|
              next unless corporation.share_price # if a corporation has not parred
              next if shares.empty?

              bundle = ShareBundle.new(shares)
              @game.share_pool.transfer_shares(bundle, @game.share_pool, allow_president_change: true)

              if corporation.owner == player && corporation.share_price.price.positive?
                @log << "-- #{corporation.name} is closed (it has no president) --"
                corps_to_close[corporation] = true
              end
            end

            # reset last share sold stuff so that the new president isn't
            # restricted from buying any trains
            @game.active_step.last_share_sold_price = nil

            unless player.companies.empty?
              @log << "#{player.name}'s companies close: #{player.companies.map(&:sym).join(', ')}"
              player.companies.dup.each(&:close!)
            end
            unless corps_to_close[corp]
              @log << "#{@game.format_currency(player.cash)} is transferred from "\
                      "#{player.name} to #{corp.name}"
              player.spend(player.cash, corp) if player.cash.positive?
            end

            corps_to_close.keys.each { |c| @game.close_corporation(c) }

            player.spend(player.cash, @game.bank) if player.cash.positive?
            @game.declare_bankrupt(player)
          end
        end
      end
    end
  end
end
