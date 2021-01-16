# frozen_string_literal: true

require_relative '../bankrupt'

module Engine
  module Step
    module G1849
      class Bankrupt < Bankrupt
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
          player.shares_by_corporation.each do |c, _|
            next unless (bundle = @game.sellable_bundles(player, c).max_by(&:price))

            @game.sell_shares_and_change_price(bundle)
            @game.sold_this_turn << bundle.corporation
          end

          # player cash given to corp, corp closed
          player.spend(player.cash, corp) if player.cash.positive?
          @game.close_corporation(corp)

          @game.reorder_corps

          # play continues if the player has any assets at all
          return if !player.shares.empty? || !player.companies.empty?

          # player will be given option to leave game or take loan
          @game.loan_choice_player = player
        end
      end
    end
  end
end
