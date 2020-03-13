# frozen_string_literal: true

require 'engine/game_error'
require 'engine/round/base'

module Engine
  module Round
    class Auction < Base
      attr_reader :bids, :companies, :min_increment

      def initialize(entities, log:, companies:, bank:, min_increment: 5)
        super

        @companies = companies.reject(&:owner).sort_by(&:value)
        @bank = bank
        @min_increment = min_increment

        @bids = Hash.new { |h, k| h[k] = [] }
        @auctioning_company = nil
        @last_to_act = nil
      end

      def description
        'Bid on Companies'
      end

      def finished?
        @companies.empty? || @entities.all?(&:passed?)
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

      def min_bid(company)
        return unless company
        return company.min_bid if may_purchase?(company)

        high_bid = @bids[company].max_by(&:price)
        (high_bid ? high_bid.price : company.min_bid) + @min_increment
      end

      def pass(entity)
        super
        @last_to_act = nil
        @bids[@auctioning_company]&.reject! { |bid| bid.player == entity }
        resolve_bids
      end

      def auction?
        true
      end

      def may_purchase?(company)
        !@auctioning_company && company == companies.first
      end

      private

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
          raise Engine::GameError, "Minimum bid is #{min}" if bid.price < min

          @log << "#{bid.player.name} bids $#{bid.price} for #{bid.company.name}"
          @bids[bid.company] << bid
        end
      end

      def resolve_bids
        while (bids = @bids[@companies.first])
          break if bids.empty?

          if bids.size == 1
            accept_bid(bids.first)
          else
            @auctioning_company = @companies.first
            break
          end
        end
      end

      def accept_bid(bid)
        price = bid.price
        company = bid.company
        player = bid.player
        company.owner = player
        player.companies << company
        player.spend(price, @bank)
        @companies.delete(company)
        @bids.delete(company)
        @auctioning_company = nil
        @log << "#{player.name} buys #{company.name} for $#{price}"
      end
    end
  end
end
