# frozen_string_literal: true

require_relative '../game_error'
require_relative 'base'

module Engine
  module Round
    class Auction < Base
      attr_reader :bids, :companies, :last_to_act, :min_increment

      def initialize(entities, game:, min_increment: 5)
        super
        @companies = game.companies.sort_by(&:value)
        @cheapest = @companies.first
        @bank = game.bank
        @min_increment = min_increment

        @bids = Hash.new { |h, k| h[k] = [] }
        @auctioning_company = nil
        @last_to_act = nil
      end

      def name
        'Auction Round'
      end

      def description
        'Bid on Companies'
      end

      def finished?
        @companies.empty?
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

      def may_bid?(company)
        !@auctioning_company || company == @auctioning_company
      end

      private

      def all_passed?
        @entities.all?(&:passed?)
      end

      def _process_action(bid)
        if @auctioning_company
          add_bid(bid)
        else
          placement_bid(bid)
        end
      end

      def action_processed(_action)
        @entities.each(&:unpass!)
      end

      def change_entity(_action)
        if (bids = @bids[@auctioning_company]).any?
          @current_entity = bids.min_by(&:price).entity
        else
          # if someone bought a share outright, then we find the next person who hasn't passed
          @current_entity = @last_to_act if @last_to_act

          loop do
            @current_entity = next_entity
            break if !@current_entity.passed? || all_passed?
          end
        end
      end

      def action_finalized(_action)
        @last_to_act = nil if @bids[@companies.first].empty? && !finished?
        return if !all_passed? || finished?

        if @companies.include?(@cheapest)
          value = @cheapest.min_bid
          @cheapest.discount += 5
          new_value = @cheapest.min_bid
          @log << "#{@cheapest.name} minimum bid decreases from "\
                  "#{@game.format_currency(value)} to #{@game.format_currency(new_value)}"

          if new_value <= 0
            buy_company(@current_entity, @cheapest, 0)
            resolve_bids
            change_entity(nil)
          end
        else
          payout_companies
          @entities.each(&:unpass!)
        end
      end

      def pass_processed(_action)
        @bids[@auctioning_company]&.reject! do |bid|
          @current_entity.unpass!
          bid.entity == @current_entity
        end
        resolve_bids
      end

      def placement_bid(bid)
        if @companies.first == bid.company
          @last_to_act = bid.entity
          accept_bid(bid)
          resolve_bids
        else
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
        buy_company(player, company, price)
        @bids.delete(company)
        @auctioning_company = nil
      end

      def add_bid(bid)
        company = bid.company
        entity = bid.entity
        price = bid.price
        min = min_bid(company)
        raise Engine::GameError, "Minimum bid is #{min} #{@current_entity.name} #{company.name}" if bid.price < min
        raise GameError, 'Cannot afford bid' if bids_for_player(entity).sum(&:price) > entity.cash

        bids = @bids[company]
        bids.reject! { |b| b.entity == entity }
        bids << bid

        @log << "#{entity.name} bids #{@game.format_currency(price)} for #{bid.company.name}"
      end

      def buy_company(player, company, price)
        company.owner = player
        player.companies << company
        player.spend(price, @bank)
        @companies.delete(company)
        @log << "#{player.name} buys #{company.name} for #{@game.format_currency(price)}"
      end

      def bids_for_player(player)
        @bids.values.map do |bids|
          bids.find { |bid| bid.entity == player }
        end.compact
      end
    end
  end
end
