# frozen_string_literal: true

require_relative '../../../step/bankrupt'

module Engine
  module Game
    module G1841
      module Step
        class Bankrupt < Engine::Step::Bankrupt
          def process_bankrupt(action)
            corp = action.entity
            player = corp.player
            option = action.option

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

            # next the president sells all normally allowed shares at half price
            player.shares_by_corporation(sorted: true).each do |corporation, _|
              next unless corporation.share_price # if a corporation has not parred
              next unless (bundle = @game.sellable_bundles(player, corporation).max_by(&:price))

              bundle.share_price = corporation.share_price.price / 2.0
              @game.sell_shares_and_change_price(bundle)
            end

            # finally, the president sells all their shares at half price, regardless of
            # 50% and presidency restrictions, not changing any share prices
            player.shares_by_corporation(sorted: true).each do |corporation, shares|
              next unless corporation.share_price # if a corporation has not parred
              next if shares.empty?

              bundle = ShareBundle.new(shares)
              bundle.share_price = corporation.share_price.price / 2.0
              if @game.historical?(corporation) && @game.phase.name.to_i < 4
                # deal with selling a historical corp
                @game.share_pool.sell_shares(bundle, allow_president_change: false)
                if bundle.presidents_share
                  # dumped a historical corp presidency
                  corporation.owner = @game.share_pool
                end
              else
                @game.share_pool.sell_shares(bundle, allow_president_change: true)
              end
              @game.update_frozen!
            end

            if player.cash.positive?
              @log << "#{player.name} transfers #{@game.format_currency(player.cash)} to #{corp.name}"
              player.spend(player.cash, corp)
            end

            # move any concessions to bank
            player.companies.dup.each do |company|
              player.companies.delete(company)
              company.owner = @game.bank
              @log << "#{company.name} concession is moved to the bank"
            end

            @game.declare_bankrupt(player, option)

            if @round.token_emr_entity
              # went bankrupt because of a L.50 token! => in rules limbo
              # just give the company a stupid token and move on
              #
              @log << "Giving #{corp.name} a discounted token due to bankruptcy"
              corp << Token.new(corp, price: 0)
              corp.spend(corp.cash, @game.bank) if corp.cash.positive?

              @round.token_emr_entity = nil
              @round.token_emr_amount = 0

              @game.transform_finish if @game.transform_state
            else
              # went bankrupt because of a train purchase
              # let the company off the hook (for this round)
              @game.done_operating!(corp)
              @game.done_this_round[corp] = true
            end
            @round.clear_cache!
          end
        end
      end
    end
  end
end
