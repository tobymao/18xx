# frozen_string_literal: true

require 'engine/game_error'
require 'engine/round/base'

module Engine
  module Round
    class PrivateAuction < Base
      attr_reader :bids, :companies, :min_increment

      def finished?
        @companies.empty?
      end

      def next_entity
        bids = @bids[@auctioning_company]
        if bids&.any?
          bids.min_by(&:price).player
        else
          @current_entity = @last_to_act if @last_to_act
          super
        end
      end

      def active_entities
        [@current_entity]
      end

      def min_bid(company)
        return unless company
        return company.min_bid if !@auctioning_company && company == companies.first
        high_bid = @bids[company].max_by(&:price)
        (high_bid ? high_bid.price : company.min_bid) + @min_increment
      end

      def pass(entity)
        @bids[@auctioning_company]&.reject! { |bid| bid.player == entity }
        resolve_bids
      end

      private

      def init_round(opts)
        @bank = opts[:bank]
        @companies = opts[:companies].sort_by(&:value)
        @bids = Hash.new { |h, k| h[k] = [] }
        @min_increment = opts[:min_bid] || 5

        @auctioning_company = nil
        @last_to_act = nil
      end

      def _process_action(bid)
        if @auctioning_company
          bids = @bids[bid.company]
          bids.reject! { |b| b.player == bid.player }
          bids << bid
        else
          placement_bid(bid)
        end
      end

      def placement_bid(bid)
        if @companies.first == bid.company
          @last_to_act = bid.player
          accept_bid(bid)
          resolve_bids
        else
          min = min_bid(bid.company)
          raise Engine::GameError.new("Minimum bid is #{min}") if bid.price < min

          @bids[bid.company] << bid
        end
      end

      def resolve_bids
        while bids = @bids[@companies.first]
          break if bids.empty?

          if bids.size == 1
            accept_bid(bids.first)
            company = @companies.first
          else
            @auctioning_company = @companies.first
            break
          end
        end
      end

      def accept_bid(bid)
        price = bid.price
        company = bid.company
        bid.player.companies << company
        bid.player.remove_cash(price)
        @bank.add_cash(price)
        @companies.delete(company)
        @bids.delete(company)
        @auctioning_company = nil
      end
    end
  end
end
