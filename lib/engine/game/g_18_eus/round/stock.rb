# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G18EUS
      module Round
        class Stock < Engine::Round::Stock
          attr_accessor :bids

          def setup
            @game.setup_bidboxes
            @stored_winning_bids = Hash.new { |h, k| h[k] = [] }
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

            @game.bidbox_privates.each(&check_winning)

            @stored_winning_bids[entity] = winning_bids
          end

          def finish_round
            @game.bidbox_privates.each do |company|
              if (bid = highest_bid(company))
                buy_company(bid)
              else
                discard_company(company)
              end
            end

            # Increase player loans with 50% interest
            # @game.add_interest_player_loans!

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

          def discard_company(company)
            @log << "#{company.name} has no bids and is discarded"
            company.owner = nil
            company.close!
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
end
