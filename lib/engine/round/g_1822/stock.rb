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
          float_minors = []
          minor_count = 0
          remove_l_count = 0
          remove_minor = nil
          @game.bidbox_minors.each_with_index do |minor, index|
            if (bid = highest_bid(minor))
              float_minors << [bid, index]
            else
              minor.owner = nil
              remove_l_count += 1
              remove_minor = minor if index.zero?
            end
            minor_count += 1
          end

          @game.bidbox_concessions.each do |concessions|
            if (bid = highest_bid(concessions))
              buy_company(bid)
            else
              concessions.owner = nil
            end
          end

          @game.bidbox_privates.each do |company|
            if (bid = highest_bid(company))
              buy_company(bid)
            else
              company.owner = nil
            end
          end

          # Sort the minors first according to bid price, highest first. If a tie, lowest index first
          float_minors.sort_by { |m| [m[0].price, minor_count - m[1]] }.reverse.each do |arr|
            float_minor(arr[0])
          end

          # Every minor with no bids will export a L/2 train. If no bid on first minors bidbidbox an additional
          # train will be exported, additionally the minor is also removed from the game.
          # This will procced the whole game
          remove_l_trains(remove_l_count) if remove_l_count.positive? && @game.depot.upcoming.first.name == 'L'
          remove_minor_and_train(remove_minor) if remove_minor

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

        def find_minor(company)
          minor_id = company.id[1..-1]
          @game.corporations.find { |m| m.id == minor_id }
        end

        def float_minor(bid)
          player = bid.entity
          company = bid.company
          price = bid.price

          # Find the correct minor in the corporations
          minor = find_minor(company)

          # Get the correct par price according to phase
          current_phase = @game.phase.name.to_i
          max_par_price = @game.stock_market.par_prices.map(&:price).max
          par_price_to_find = current_phase == 1 ? @game.class::MINOR_START_PAR_PRICE : price / 2
          par_price_to_find = max_par_price if par_price_to_find > max_par_price

          share_price = @game.stock_market.par_prices.find { |pp| pp.price <= par_price_to_find }
          par_price = share_price.price

          # Temporarily give the player cash to buy the minors PAR shares
          @game.bank.spend(share_price.price * 2, player)

          # Set the parprice of the minor and let the player get the president share
          @game.stock_market.set_par(minor, share_price)
          share = minor.shares.first
          @game.share_pool.buy_shares(player, share.to_bundle)
          @game.after_par(minor)

          # Clear the corporation of par cash
          minor.spend(minor.cash, @game.bank)

          # Move the correct amount to money to the minor. This is according to phase of the game
          treasury = if current_phase < 3
                       par_price * 2
                     else
                       price
                     end
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

        def remove_l_trains(count)
          @game.log << "#{count} minors with no bids. If available up to #{count} L trains will be removed"
          while (train = @game.depot.upcoming.first).name == 'L' && count.positive?
            @game.remove_train(train)
            count -= 1
          end
        end

        def remove_minor_and_train(company)
          # Remove the next train
          train = @game.depot.upcoming.first
          @game.log << "No bids on minor #{company.id}, it will close and a #{train.name} train is removed"
          @game.remove_train(train)
          @game.phase.buying_train!(nil, train)

          ## Find the correct minor in the corporations and close it
          minor = find_minor(company)
          @game.close_corporation(minor)

          # Remove the proxy company for the minor
          @game.companies.delete(company)
        end

        def sold_out?(corporation)
          corporation.type == :major && super
        end
      end
    end
  end
end
