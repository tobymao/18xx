# frozen_string_literal: true

require_relative '../auctioner'

module Engine
  module Step
    module G1822
      module BidboxAuction
        include Auctioner

        def min_bid(company)
          return unless company

          high_bid = highest_bid(company)
          (high_bid ? high_bid.price + min_increment : company.min_bid)
        end

        def max_bid(player, _company)
          player.cash - committed_cash(player)
        end

        def remove_from_auction(entity)
          super
        end

        def setup_auction
          super
        end

        def committed_cash(player, _show_hidden = false)
          bids_for_player(player, true).sum(&:price)
        end

        def find_bid(player, company)
          @bids[company]&.find { |b| b.entity == player }
        end

        def highest_player_bid?(player, company)
          return false if find_bid(player, company).nil?

          current_bid_amount(player, company) >= (highest_bid(company)&.price || 0)
        end

        protected

        def active_auction
          company = @auctioning
          bids = @bids[company]
          yield company, bids if bids.size > 1
        end

        def bids_for_player(player, only_highest_bid_committed = false)
          @bids.values.map do |bids|
            if only_highest_bid_committed
              highest_bid = bids.max_by(&:price)
              highest_bid if highest_bid&.entity == player
            else
              bids.find { |bid| bid.entity == player }
            end
          end.compact
        end
      end
    end
  end
end
