# frozen_string_literal: true

require_relative '../../../step/bankrupt'

module Engine
  module Game
    module G1846
      module Step
        class Bankrupt < Engine::Step::Bankrupt
          def process_bankrupt(action)
            corp = action.entity
            player = corp.owner

            @log << "-- #{player.name} goes bankrupt and sells remaining shares --"

            # first, the corporation issues as many shares as they can
            if (bundle = @game.emergency_issuable_bundles(corp).max_by(&:num_shares))
              @game.share_pool.sell_shares(bundle)

              price = corp.share_price.price
              bundle.num_shares.times { @game.stock_market.move_left(corp) }
              @game.log_share_price(corp, price)

              @game.round.emergency_issued = true
            end

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

            # finally, the president sells all their shares, regardless of 50% and
            # presidency restrictions, not changing any share prices
            player.shares_by_corporation(sorted: true).each do |corporation, shares|
              next unless corporation.share_price # if a corporation has not parred
              next if shares.empty?

              bundle = ShareBundle.new(shares)
              @game.share_pool.sell_shares(bundle, allow_president_change: true)

              if corporation.owner == player && corporation.share_price.price.positive?
                @log << "-- #{corporation.name} enters receivership (it has no president) --"
                corporation.owner = @game.share_pool
              end
            end

            # reset last share sold stuff so that the new president isn't
            # restricted from buying any trains
            @game.active_step.last_share_issued_price = nil
            @game.active_step.last_share_sold_price = nil

            @game.minors
              .select { |minor| minor.owner == player }
              .each { |minor| @game.close_corporation(minor, quiet: true) }

            if player.companies.any?
              @log << "#{player.name}'s companies close: #{player.companies.map(&:sym).join(', ')}"
              player.companies.dup.each(&:close!)
            end

            @log << "#{@game.format_currency(player.cash)} is transferred from "\
                    "#{player.name} to #{corp.name}"
            player.spend(player.cash, corp) if player.cash.positive?

            @game.corporations.dup.each do |corporation|
              @game.close_corporation(corporation) if corporation.share_price&.type == :close
            end

            @game.declare_bankrupt(player)
          end
        end
      end
    end
  end
end
