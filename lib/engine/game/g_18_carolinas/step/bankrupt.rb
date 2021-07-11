# frozen_string_literal: true

require_relative '../../../step/bankrupt'

module Engine
  module Game
    module G18Carolinas
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

            # the president sells all normally allowed shares
            player.shares_by_corporation(sorted: true).each do |corporation, _|
              next unless corporation.share_price # if a corporation has not parred
              next unless (bundle = @game.sellable_bundles(player, corporation).max_by(&:price))

              @game.sell_shares_and_change_price(bundle)
            end

            # bankrupt the corporation involved
            @game.bankrupt_corporation!(corp)

            # move any private companys to bank
            if player.companies.any?
              @log << "#{player.name}'s companies move to the bank: #{player.companies.map(&:sym).join(', ')}"
              player.companies.dup.each do |c|
                c.owner = @game.bank
                player.companies.delete(c)
              end
            end

            # remove all cash from player
            player.spend(player.cash, @game.bank) if player.cash.positive?

            @game.declare_bankrupt(player)

            @round.steps.each(&:pass!)
          end
        end
      end
    end
  end
end
