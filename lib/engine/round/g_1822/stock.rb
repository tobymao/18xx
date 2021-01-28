# frozen_string_literal: true

require_relative '../stock'

module Engine
  module Round
    module G1822
      class Stock < Stock
        attr_accessor :bids, :bidders

        def setup
          super
          @game.setup_bidboxes
        end

        def finish_round
          @game.bidbox_minors.each do |minor|
            if (bid = highest_bid(minor))
              float_minor(bid)
            else
              minor.owner = nil
            end
          end

          @game.bidbox_concessions.each do |concessions|
            if (bid = highest_bid(concessions))
              buy_company(bid)
            else
              concessions.owner = nil
            end
          end

          @game.bidbox_privates.each do |private|
            if (bid = highest_bid(private))
              buy_company(bid)
            else
              private.owner = nil
            end
          end

          super
        end

        def buy_company(bid)
          player = bid.entity
          company = bid.company
          price = bid.price

          company.owner = player
          player.companies << company
          player.spend(price, @game.bank) if price.positive?
          @log << "#{player.name} wins the bid #{company.name} for #{@game.format_currency(price)}"
        end

        def float_minor(bid)
          player = bid.entity
          company = bid.company
          price = bid.price

          ## Find the correct minor in the corporations
          minor_id = company.id[1..-1]
          minor = @game.corporations.find { |m| m.id == minor_id }

          # TODO: Get the correct par price according to phase
          par_price = 50
          share_price = @game.stock_market.par_prices.find { |pp| pp.price == par_price }

          # Temporarily give the player cash to buy the minors PAR shares
          @game.bank.spend(share_price.price * 2, player)

          # Set the parprice of the minor and let the player get the president share
          @game.stock_market.set_par(minor, share_price)
          share = minor.shares.first
          @game.share_pool.buy_shares(player, share.to_bundle)
          @game.after_par(minor)

          # Clear the corporation of par cash
          minor.spend(minor.cash, @game.bank)

          # TODO: Move the correct amount to money to the minor. This is according to phase of the game
          treasury = par_price * 2
          @game.bank.spend(treasury, minor)

          # Spend the whole amount the player have bid
          player.spend(price, @game.bank)

          # Remove the proxy company for the minor
          @game.companies.delete(company)

          # If there is a difference between the treasury and the money the company get from the IPO
          treasury_par_difference = treasury - (par_price * 2)
          @log << "#{minor.name} recives an additional #{@game.format_currency(treasury_par_difference)} "\
                  'from the bid' if treasury_par_difference != 0
        end

        def highest_bid(company)
          @bids[company]&.max_by(&:price)
        end

        def sold_out?(corporation)
          corporation.type == :major && super
        end
      end
    end
  end
end
