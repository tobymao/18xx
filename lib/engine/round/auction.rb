# frozen_string_literal: true

require 'engine/game_error'
require 'engine/round/base'

module Engine
  module Round
    class Auction < Base
      attr_reader :bids, :companies, :last_to_act, :min_increment

      def initialize(entities, game:, min_increment: 5)
        super
        @companies = game.companies.reject(&:owner).sort_by(&:value)
        @bank = game.bank
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

      def change_entity(_action)
        if (bids = @bids[@auctioning_company]).any?
          @current_entity = bids.min_by(&:price).entity
        else
          # if someone bought a share outright, then we find the next person who hasn't passed
          loop do
            @current_entity = next_entity
            break if !@current_entity.passed? || finished?
          end
        end
      end

      def min_bid(company)
        return unless company
        return company.min_bid if may_purchase?(company)

        high_bid = @bids[company].max_by(&:price)
        (high_bid ? high_bid.price : company.min_bid) + @min_increment
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
          add_bid(bid)
        else
          placement_bid(bid)
        end
      end

      def action_processed(action)
        action.entity.unpass!
      end

      def pass_processed(_action)
        @bids[@auctioning_company]&.reject! { |bid| bid.entity == @current_entity }
        resolve_bids
      end

      def placement_bid(bid)
        if @companies.first == bid.company
          @last_to_act = bid.entity
          accept_bid(bid)
          resolve_bids
        else
          min = min_bid(bid.company)
          raise Engine::GameError, "Minimum bid is #{min}" if bid.price < min

          add_bid(bid)
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
        player = bid.entity
        company.owner = player
        player.companies << company
        player.spend(price, @bank)
        @companies.delete(company)
        @bids.delete(company)
        @auctioning_company = nil
        @log << "#{player.name} buys #{company.name} for $#{price}"
      end

      def add_bid(bid)
        bids = @bids[bid.company]
        bids.reject! { |b| b.entity == bid.entity }
        bids << bid
        @log << "#{bid.entity.name} bids $#{bid.price} for #{bid.company.name}"
      end
    end
  end
end
