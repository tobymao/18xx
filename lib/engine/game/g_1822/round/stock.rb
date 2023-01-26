# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G1822
      module Round
        class Stock < Engine::Round::Stock
          attr_accessor :bids

          def setup
            @game.setup_bidboxes
            # Store bids the player was winning at the end of their turn.
            @stored_winning_bids = Hash.new { |h, k| h[k] = [] }
            # Super attempts to skip players, must happen after setting up variables.
            super
          end

          def player_enabled_program(entity)
            # Update winning bids to exclude being outbid prior to enabling program.
            update_stored_winning_bids(entity)
          end

          def stored_winning_bids(entity)
            @stored_winning_bids[entity]
          end

          def update_stored_winning_bids(entity)
            winning_bids = []
            check_winning = lambda { |bid_target|
              return unless (bid = highest_bid(bid_target))
              return unless bid.entity == entity

              winning_bids << bid_target
            }

            @game.bidbox_minors.each(&check_winning)
            @game.bidbox_concessions.each(&check_winning)
            @game.bidbox_privates.each(&check_winning)

            @stored_winning_bids[entity] = winning_bids
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
            float_minors.sort_by { |m| [m[0].price, minor_count - m[1]] }.reverse_each do |arr|
              float_minor(arr[0])
            end

            # Every minor with no bids will export a L/2 train. If no bid on first minors bidbidbox an additional
            # train will be exported, additionally the minor is also removed from the game.
            # This will procced the whole game
            remove_l_trains(remove_l_count) if remove_l_count.positive? && @game.depot.upcoming.first.name == 'L'
            remove_minor_and_first_train(remove_minor) if remove_minor

            # Refill the minors bidbox
            @game.bidbox_minors_refill!

            # Increase player loans with 50% interest
            @game.add_interest_player_loans!

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
            bid_amount = bid.price

            # Find the correct minor in the corporations
            minor = @game.find_corporation(company)
            minor.reservation_color = :white

            # Get the correct par price according to phase
            current_phase = @game.phase.name.to_i
            max_par_price = @game.stock_market.par_prices.map(&:price).max
            par_price_to_find = current_phase == 1 ? @game.class::MINOR_START_PAR_PRICE : bid_amount / 2
            par_price_to_find = max_par_price if par_price_to_find > max_par_price

            share_price = @game.stock_market.par_prices.find { |pp| pp.price <= par_price_to_find }
            presidency_price = share_price.price * 2

            # Set the par price of the minor, player buys presidency
            @game.stock_market.set_par(minor, share_price)
            share = minor.shares.first
            @game.share_pool.buy_shares(player, share.to_bundle)
            @game.after_par(minor)

            # Clear the corporation of par cash
            minor.spend(minor.cash, @game.bank)

            # Move the correct amount to money to the minor. This is according to phase of the game
            treasury = if current_phase < 3
                         presidency_price
                       else
                         bid_amount
                       end

            # Spend the remaining bid amount
            excess = bid_amount - presidency_price
            player.spend(excess, @game.bank) unless excess.zero?

            @game.bank.spend(treasury, minor)

            # Remove the proxy company for the minor
            @game.companies.delete(company)

            # If there is a difference between the treasury and the price. The rest is paid to the bank.
            price_treasury_difference = bid_amount - treasury
            if price_treasury_difference.positive?
              @log << "#{player.name} pays #{@game.format_currency(price_treasury_difference)} "\
                      'to the bank'
            end

            # If there is a difference between the treasury and the money the company get from the IPO
            return if (treasury_par_diff = treasury - presidency_price).zero?

            @log << "#{minor.name} receives an additional #{@game.format_currency(treasury_par_diff)} from the bid"
          end

          def highest_bid(company)
            @bids[company]&.max_by(&:price)
          end

          def remove_l_trains(count)
            total_count = count
            removed_trains = 0
            while (train = @game.depot.upcoming.first).name == 'L' && count.positive?
              @game.remove_train(train)
              count -= 1
              removed_trains += 1
            end
            @game.log << if total_count != removed_trains
                           "#{total_count} minors with no bids. The last #{removed_trains} L trains have been removed"
                         else
                           "#{total_count} minors with no bids. #{removed_trains} L trains have been removed"
                         end
          end

          def remove_minor_and_first_train(company)
            train = remove_train
            @game.log << "No bids on minor #{company.id}, it will close and a #{train.name} train is removed"

            ## Find the correct minor in the corporations and close it
            minor = @game.find_corporation(company)
            @game.close_corporation(minor)

            # Remove the proxy company for the minor
            company.close!
            @game.companies.delete(company)
          end

          def remove_first_train
            train = remove_train
            @game.log << "No minor in first bidbox and with this no bids, a #{train.name} train is removed"
          end

          def remove_train
            # Remove the next train
            train = @game.depot.upcoming.first
            source = train.owner
            @game.remove_train(train)
            @game.phase.buying_train!(nil, train, source)
            train
          end

          def sold_out?(corporation)
            corporation.type == :major && super
          end
        end
      end
    end
  end
end
