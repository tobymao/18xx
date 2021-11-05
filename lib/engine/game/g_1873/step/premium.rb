# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1873
      module Step
        class Premium < Engine::Step::Base
          attr_reader :companies

          AUCTION_ACTIONS = %w[bid pass].freeze
          BUY_ACTION = %w[bid par].freeze
          PASS_ACTION = %w[pass].freeze
          MIN_BID_RAISE = 10

          def setup
            @bids = {}
            @order = []
            setup_auction
          end

          def auctioning
            :turn if in_auction?
          end

          def bids
            {}
          end

          def visible?
            true
          end

          def available
            []
          end

          def players_visible?
            true
          end

          def name
            'Buy/Par'
          end

          def description
            'Bid on Premium'
          end

          def finished?
            @game.premium
          end

          def actions(entity)
            return [] if finished?
            return [] unless entity == current_entity
            return AUCTION_ACTIONS if min_player_bid <= max_player_bid(entity)

            PASS_ACTION
          end

          def process_pass(action)
            player = action.entity

            @log << "#{player.name} passes bidding"

            @bids.delete(player)
            @order << player

            resolve_auction
          end

          def process_bid(action)
            player = action.entity
            price = action.price

            if price > max_player_bid(player)
              raise GameError, "Cannot afford bid. Maximum possible bid is #{max_player_bid(player)}"
            end

            raise GameError, "Must bid at least #{min_player_bid}" if price < min_player_bid
            raise GameError, "Must bid multiple of #{MIN_BID_RAISE}" unless (price % MIN_BID_RAISE).zero?

            @log << "#{player.name} bids #{@game.format_currency(price)}"

            @bids[player] = price
            resolve_auction
          end

          def active_entities
            return [@bids.min_by { |_k, v| v }.first] if in_auction?

            super
          end

          def min_increment
            MIN_BID_RAISE
          end

          def min_player_bid
            any_bids? ? highest_player_bid + MIN_BID_RAISE : 0
          end

          def max_player_bid(entity)
            entity.cash
          end

          def visible
            true
          end

          def committed_cash(player, _show_hidden = false)
            if @bids[player] && !@bids[player].negative?
              @bids[player]
            else
              0
            end
          end

          private

          def in_auction?
            @bids.any?
          end

          def highest_player_bid
            any_bids? ? @bids.max_by { |_k, v| v }.last : 0
          end

          def highest_bid
            in_auction? ? @bids.max_by { |_k, v| v }.last : 0
          end

          def any_bids?
            in_auction? && !@bids.max_by { |_k, v| v }.last.negative?
          end

          def setup_auction
            @bids.clear
            @first_player = current_entity
            start_idx = entity_index
            size = entities.size
            # initialize bids to preserve player order starting with current player
            entities.each_index do |idx|
              @bids[entities[idx]] = -size + ((idx - start_idx) % size)
            end
          end

          def resolve_auction
            return if @bids.size > 1
            return if @bids.one? && highest_bid.negative?

            if @bids.any?
              winning_bid = @bids.to_a.flatten
              player = winning_bid.first
              price = winning_bid.last
            else
              player = @first_player
              price = 0
            end
            @log << "#{player.name} wins auction for #{@game.format_currency(price)}"
            @log << "Premium is set to #{@game.format_currency(price)}"
            @order << player
            @game.premium = price
            @game.premium_order = @order.uniq.reverse
            @game.premium_winner = player
          end
        end
      end
    end
  end
end
