# frozen_string_literal: true

require_relative '../base'
require_relative '../../action/par'

module Engine
  module Step
    module G18FL
      class BuyCert < Base
        attr_reader :companies

        AUCTION_ACTIONS = %w[bid].freeze
        MIN_BID_RAISE = 5
        BID_CHOICES = [0, 5, 10].freeze

        def bid_choices
          BID_CHOICES
        end

        def setup
          @companies = @game.companies.sort
          @first_comp = @companies.first
          refresh_bids
          setup_auction
        end

        def available
          @companies
        end

        def may_purchase?(_company)
          true
        end

        def auctioning
          :turn if in_auction?
        end

        def visible?
          true
        end

        def bids
          {}
        end

        def players_visible?
          true
        end

        def name
          'Buy'
        end

        def description
          in_auction? ? 'Pay Bid (0, 5, 10)' : 'You must buy a company'
        end

        def finished?
          @companies.empty?
        end

        def actions(entity)
          return [] if finished?
          return [] unless entity == current_entity

          # NO PASSING
          AUCTION_ACTIONS
        end

        def process_bid(action)
          player = action.entity
          price = action.price

          if !in_auction?
            buy_company(player, action.company)
          else
            if price > max_player_bid(player)
              raise GameError, "Cannot afford bid. Maximum possible bid is #{max_player_bid(player)}"
            end

            raise GameError, "Must bid at least #{min_player_bid}" if price < min_player_bid

            @bids[player] = price
            resolve_auction
          end
        end

        def active_entities
          return super if !@bids || @bids.empty?
          return [@bids.find { |_e, b| b.nil? }.first] if in_auction?

          [@bids.max { |a, b| a[1] <=> b[1] }.first]
        end

        def min_increment
          5
        end

        def min_player_bid
          0
        end

        def max_player_bid(_entity)
          10
        end

        def min_bid(company)
          company.min_price
        end

        def companies_pending_par
          false
        end

        def visible
          true
        end

        def committed_cash(_player, _show_hidden = false)
          0
        end

        private

        def refresh_bids
          @bids = entities.map { |e| [e, nil] }.to_h
        end

        def in_auction?
          @bids.find { |_e, b| b.nil? }
        end

        def setup_auction
          @bids.clear
          @first_player = current_entity

          refresh_bids
        end

        def resolve_auction
          return if @bids.any? { |_e, b| b.nil? }

          winner = @bids.max_by { |_k, v| v }
          @log << "-- #{winner.first.name} wins auction with #{@game.format_currency(winner.last)} --"
          @bids.each do |player, bid|
            next unless bid.positive?

            @log << "#{player.name} pays #{@game.format_currency(bid)} for their bid"
            player.spend(bid, @game.bank)
          end
        end

        def buy_company(player, company)
          price = company.min_auction_price
          company.owner = player
          player.companies << company
          player.spend(price, @game.bank) if price.positive?
          @log << "#{player.name} buys #{company.name} for #{@game.format_currency(price)}"
          grant_priority(player) if company == @first_comp
          @companies.delete(company)
          setup_auction
        end

        def grant_priority(player)
          @round.goto_entity!(player)
          @game.log << "#{player.name} gets priority deal in SR1"
        end
      end
    end
  end
end
