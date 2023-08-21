# frozen_string_literal: true

require_relative '../../g_1822/round/stock'

module Engine
  module Game
    module G1822Africa
      module Round
        class Stock < G1822::Round::Stock
          def setup
            @game.reset_sold_in_sr!
            super
          end

          def update_stored_winning_bids(entity)
            winning_bids = []
            check_winning = lambda { |bid_target|
              return unless (bid = highest_bid(bid_target))
              return unless bid.entity == entity

              winning_bids << bid_target
            }

            @game.bidbox.each(&check_winning)

            @stored_winning_bids[entity] = winning_bids
          end

          def finish_round
            float_minors = []
            minor_count = 0
            remove_l_count = 0
            remove_minor = nil
            concession_to_remove = nil

            minors, companies = @game.bidbox.partition { |c| @game.minor?(c) }

            companies.each_with_index do |company, index|
              if (bid = highest_bid(company))
                buy_company(bid)
              else
                company.owner = nil
                concession_to_remove = company if index.zero? && @game.concession?(company)
              end
            end

            minors.each_with_index do |minor, index|
              if (bid = highest_bid(minor))
                float_minors << [bid, index]
              else
                minor.owner = nil
                remove_l_count += 1
                remove_minor = minor if index.zero?
              end
              minor_count += 1
            end

            # Sort the minors first according to bid price, highest first. If a tie, lowest index first
            float_minors.sort_by { |m| [m[0].price, minor_count - m[1]] }.reverse_each do |arr|
              float_minor(arr[0])
            end

            # Every minor with no bids will export a L/2 train. If no bid on first minors an additional
            # train will be exported, additionally the minor is also removed from the game.
            # This will procced the whole game
            remove_l_trains(remove_l_count) if remove_l_count.positive? && @game.depot.upcoming.first.name == 'L'
            remove_minor_and_first_train(remove_minor) if remove_minor

            # Remove all if nothing was purchased, or just concession from first bidbox
            if @game.nothing_sold_in_sr?
              clear_bidboxes
            elsif concession_to_remove
              @game.log << "No bids on concession #{concession_to_remove.id}, it will be removed from the game"
              close_company(concession_to_remove)
            end

            # Refill the bidbox
            @game.bidbox_refill!

            # Increase player loans with 50% interest
            @game.add_interest_player_loans!

            # Move sold out corps stock value right
            corporations_to_move_price.sort.each do |corp|
              next unless corp.share_price

              old_price = corp.share_price

              sold_out_stock_movement(corp) if sold_out?(corp)

              @game.log_share_price(corp, old_price)
            end
          end

          def clear_bidboxes
            @game.log << 'No bids were made, items in all bid boxes will be removed from the game'

            @game.bidbox.each do |company|
              @game.log << "#{company.name} is removed from the game"
              if @game.minor?(company)
                minor = @game.find_corporation(company)
                @game.close_corporation(minor)
              end

              close_company(company)
            end
          end

          def close_company(company)
            company.close!
            @game.companies.delete(company)
          end

          def sold_out_stock_movement(corp)
            @game.stock_market.move_right(corp)
          end
        end
      end
    end
  end
end
