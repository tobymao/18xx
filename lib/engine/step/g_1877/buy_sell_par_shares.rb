# frozen_string_literal: true

require_relative '../g_1817/buy_sell_par_shares'

module Engine
  module Step
    module G1877
      class BuySellParShares < Step::G1817::BuySellParShares
        def win_bid(winner, _company)
          @winning_bid = winner
          entity = @winning_bid.entity
          corporation = @winning_bid.corporation
          price = @winning_bid.price

          @log << "#{entity.name} wins bid on #{corporation.name} for #{@game.format_currency(price)}"

          share_price = @game.find_share_price(price / 2)

          action = Action::Par.new(entity, corporation: corporation, share_price: share_price)
          process_par(action)

          @corporation_size = nil
          size_corporation(@game.phase.corporation_sizes.first) if @game.phase.corporation_sizes.one?

          @game.share_pool.transfer_shares(ShareBundle.new(corporation.shares), @game.share_pool)

          par_corporation if available_subsidiaries(winner.entity).none?
        end
      end
    end
  end
end
