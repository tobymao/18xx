# frozen_string_literal: true

require_relative '../../g_1822/round/stock'

module Engine
  module Game
    module G1822Africa
      module Round
        class Stock < G1822::Round::Stock
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
            return @game.end_game! if @game.nothing_sold_in_sr?

            float_minors = []
            minor_count = 0
            remove_l_count = 0
            remove_minor = nil

            minors, companies = @game.bidbox.partition { |c| c.id[0] == @game.class::COMPANY_MINOR_PREFIX }

            companies.each do |company|
              if (bid = highest_bid(company))
                buy_company(bid)
              else
                company.owner = nil
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

            # Refill the bidbox
            @game.bidbox_refill!

            # Increase player loans with 50% interest
            @game.add_interest_player_loans!

            super
          end
        end
      end
    end
  end
end
