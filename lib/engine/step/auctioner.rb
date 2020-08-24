# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    module Auctioner
      attr_reader :bids

      def pass_description
        if auctioning_company
          "Pass (on #{auctioning_company.sym})"
        else
          'Pass'
        end
      end

      def visible?
        true
      end

      def players_visible?
        true
      end

      def pass_auction(entity)
        @log << "#{entity.name} passes on #{auctioning_company.name}"

        @bids[auctioning_company]&.reject! do |bid|
          bid.entity == entity
        end
        resolve_bids
      end

      def min_increment
        @game.class::MIN_BID_INCREMENT
      end

      def setup
        @bids = Hash.new { |h, k| h[k] = [] }
      end

      def may_choose?(_company)
        false
      end

      def current_bid_amount(player, company)
        bids[company]&.find { |b| b.entity == player }&.price || 0
      end

      protected

      def auctioning_company
        active_company_bids { |company, _| company }
      end

      def highest_bid(company)
        @bids[company].max_by(&:price)
      end

      def add_bid(bid)
        company = bid.company
        entity = bid.entity
        price = bid.price
        min = min_bid(company)
        @game.game_error("Minimum bid is #{@game.format_currency(min)} for #{company.name}") if price < min
        if price > max_bid(entity, company)
          @game.game_error("Cannot afford bid. Maximum possible bid is #{max_bid(entity, company)}")
        end
        bids = @bids[company]
        bids.reject! { |b| b.entity == entity }
        bids << bid
      end

      def bids_for_player(player)
        @bids.values.map do |bids|
          bids.find { |bid| bid.entity == player }
        end.compact
      end
    end
  end
end
