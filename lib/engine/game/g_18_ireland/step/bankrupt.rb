# frozen_string_literal: true

require_relative '../../../step/bankrupt'

module Engine
  module Game
    module G18Ireland
      module Step
        class Bankrupt < Engine::Step::Bankrupt
          def process_bankrupt(action)
            corp = action.entity
            player = corp.owner

            unless @game.can_go_bankrupt?(player, corp)
              buying_power = @game.format_currency(@game.total_emr_buying_power(player, corp))
              price = @game.format_currency(@game.depot.min_depot_price)

              msg = "Cannot go bankrupt. #{corp.name}'s cash plus #{player.name}'s cash and "\
                    "sellable shares total #{buying_power}, and the cheapest train in the "\
                    "Depot costs #{price}."
              raise GameError, msg
            end

            @log << "#{player.name} sells all legally sellable shares"

            # player sells all normally allowed shares
            player.shares_by_corporation(sorted: true).each do |c, _|
              next unless (bundle = @game.sellable_bundles(player, c).max_by(&:price))

              @game.sell_shares_and_change_price(bundle)
            end

            # player cash given to corp, corp closed
            player.spend(player.cash, corp) if player.cash.positive?

            @game.declare_bankrupt(player)

            # any corporations the player is president of now close
            player.presidencies.each { |president_corp| @game.close_corporation(president_corp) }

            @round.recalculate_order if @round.respond_to?(:recalculate_order)
          end
        end
      end
    end
  end
end
