# frozen_string_literal: true

require_relative '../stock'

module Engine
  module Round
    module G1822
      class Stock < Stock
        attr_accessor :bids, :bidders

        def finish_round
          @game.bidbox_minors.map do |minor_company|
            bid = highest_bid(minor_company)
            float_minor(bid) unless bid.nil?
          end

          @game.bidbox_concessions.map do |concessions|
            bid = highest_bid(concessions)
            buy_company(bid) unless bid.nil?
          end

          @game.bidbox_privates.map do |private_company|
            bid = highest_bid(private_company)
            buy_company(bid) unless bid.nil?
          end

          super
        end

        def setup
          super
        end

        def buy_company(bid)
          player = bid.entity
          company = bid.company
          price = bid.price

          company.owner = player
          player.companies << company
          player.spend(price, @game.bank) if price.positive?
          @game.companies.delete(company)
          @log << "#{player.name} buys #{company.name} for #{@game.format_currency(price)}"
        end

        def float_minor(bid)
          player = bid.entity
          company = bid.company
          price = bid.price

          return unless (minor = @game.minors.find { |m| m.id == company.id })

          player.spend(price, @game.bank)

          minor.owner = player
          minor.float!
          @game.bank.spend(100, minor)

          hex = @game.hex_by_id(minor.coordinates)
          hex.tile.cities[minor.city || 0].place_token(minor, minor.next_token)

          share_price = @game.stock_market.par_prices.find { |pp| pp.price == 50 }
          @game.stock_market.set_par(minor, share_price)

          @game.companies.delete(company)
          @log << "#{player.name} buys #{company.name} for #{@game.format_currency(price)}"
          @log << "#{minor.name} floats with parprice 50 and a treasury of 100"
        end

        def highest_bid(company)
          @bids[company]&.max_by(&:price)
        end
      end
    end
  end
end
