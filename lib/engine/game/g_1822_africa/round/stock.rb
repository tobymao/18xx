# frozen_string_literal: true

require_relative '../../g_1822/round/stock'

module Engine
  module Game
    module G1822Africa
      module Round
        class Stock < Engine::Game::G1822::Round::Stock
          def setup
            @game.reset_sold_in_sr!
            super
          end

          def update_stored_winning_bids(entity)
            winning_bids = []
            check_winning = lambda { |bid_target|
              next unless (bid = highest_bid(bid_target))
              next unless bid.entity == entity

              winning_bids << bid_target
            }

            @game.bidbox.each(&check_winning)

            @stored_winning_bids[entity] = winning_bids
          end

          def finish_round
            float_minors = []
            minor_count = 0
            bidless_minors = []
            first_bidbox_minor = nil
            concession_to_remove = nil

            @game.bidbox.each_with_index do |company, index|
              if @game.minor?(company)
                if (bid = highest_bid(company))
                  float_minors << [bid, index]
                else
                  bidless_minors << company
                  first_bidbox_minor = company if index.zero?
                end
                minor_count += 1
              elsif (bid = highest_bid(company))
                buy_company(bid)
              else
                company.owner = nil
                concession_to_remove = company if @game.concession?(company) && index.zero?
              end
            end

            # Sort the minors first according to bid price, highest first. If a tie, lowest index first
            float_minors.sort_by { |m| [m[0].price, minor_count - m[1]] }.reverse_each do |arr|
              float_minor(arr[0])
            end

            # Every minor with no bids exports a L/2 train. The minor at bidbox position 0 additionally
            # removes a non-L train and is closed. All other bid-less minors are also closed per rules.
            remove_l_trains(bidless_minors.size) if !bidless_minors.empty? && @game.depot.upcoming.first.name == 'L'
            remove_minor_and_first_train(first_bidbox_minor) if first_bidbox_minor
            (bidless_minors - [first_bidbox_minor]).each { |company| close_minor(company) }

            # Snapshot taken after all minor removals to avoid stale references in clear_bidboxes
            current_bidbox_items = @game.bidbox

            # Remove all if nothing was purchased, or just concession from first bidbox
            if @game.nothing_sold_in_sr?
              clear_bidboxes(current_bidbox_items)
            elsif concession_to_remove
              @game.log << "No bids on #{concession_to_remove.name}, it is removed from the game"
              close_company(concession_to_remove)
            end

            # Refill the bidbox
            @game.bidbox_refill!

            # Increase player loans with 50% interest in SR x.2
            @game.add_interest_player_loans! if round_num == 2
          end

          private

          def clear_bidboxes(bidbox_items)
            @game.log << 'No bids were made, items in all bid boxes will be removed from the game'

            bidbox_items.each do |company|
              @game.log << "#{company.name} is removed from the game"

              if @game.minor?(company)
                minor = @game.find_corporation(company)
                @game.close_corporation(minor)
              end

              close_company(company)
            end
          end

          def close_minor(company)
            @game.log << "No bids on minor #{company.id}, it is removed from the game"
            minor = @game.find_corporation(company)
            @game.close_corporation(minor)
            company.close!
            @game.companies.delete(company)
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
