# frozen_string_literal: true

require_relative '../bankrupt'

module Engine
  module Step
    module G1817
      class Bankrupt < Bankrupt
        def active?
          active_entities.any?
        end

        def active_entities
          return [] unless @round.cash_crisis_player

          # Rotate players to order starting with the current player
          players = @game.players.rotate(@game.players.index(@round.cash_crisis_player))
          players.select { |p| p.cash.negative? }
        end

        def process_bankrupt(action)
          player = action.entity

          @log << "-- #{player.name} goes bankrupt and sells remaining shares --"

          # next the president sells all normally allowed shares
          player.shares_by_corporation.each do |corporation, _|
            next unless corporation.share_price # if a corporation has not parred
            next unless (bundle = @game.sellable_bundles(player, corporation).max_by(&:price))

            @game.sell_shares_and_change_price(bundle)
          end
          # @todo: shorts

          # finally, the president sells all their shares, regardless of 50% and
          # presidency restrictions
          player.shares_by_corporation.each do |corporation, shares|
            next unless corporation.share_price # if a corporation has not parred
            next if shares.empty?

            bundle = ShareBundle.new(shares)

            if corporation.owner == player
              @log << "-- #{corporation.name} enters liquidation (it has no president) --"
              @game.liquidate!(corporation)
              corporation.owner = @game.share_pool
            end

            # Sell shares after liquidating
            @game.sell_shares_and_change_price(bundle)
          end

          if @cash_crisis_due_to_interest
            corp = @cash_crisis_due_to_interest
            @log << "#{@game.format_currency(player.cash)} is transferred from "\
                    "#{player.name} to #{corp.name}"
            player.spend(player.cash, corp) if player.cash.positive?
          end
          # Clear cash crisis
          @game.bank.spend(-player.cash, player) if player.cash.negative?

          @game.declare_bankrupt(player)
        end
      end
    end
  end
end
