# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/auctioner'

module Engine
  module Game
    module G1887
      module Step
        # The opening auction: each selected industry is auctioned in turn. The
        # first auction is opened by the first player, the second by the second
        # player, and so on. Players bid or pass in turn order; a player who
        # passes is out of that auction. An industry nobody bids on is removed.
        class IndustryAuction < Engine::Step::Base
          include Engine::Step::Auctioner

          ACTIONS = %w[bid pass].freeze

          attr_reader :companies

          def setup
            setup_auction
            @companies = @game.auction_industries.dup
            @auction_number = 0
            start_auction
          end

          def description
            'Industry Auction'
          end

          def available
            @companies
          end

          def active?
            !@companies.empty?
          end

          def active_entities
            return [] unless active?

            [@bidders[@turn]]
          end

          def actions(entity)
            return [] unless active?

            entity == current_entity ? ACTIONS : []
          end

          def may_bid?(company)
            company == @companies.first
          end

          def may_purchase?(_company)
            false
          end

          # Cash tied up in the player's standing bid on the current industry
          def committed_cash(player, _show_hidden = false)
            company = @companies.first
            return 0 unless company

            @bids[company].find { |b| b.entity == player }&.price || 0
          end

          def min_increment
            @game.class::INDUSTRY_BID_INCREMENT
          end

          def min_bid(company)
            return unless company

            high = highest_bid(company)
            high ? high.price + min_increment : company.value
          end

          def max_bid(entity, _company)
            entity.cash
          end

          def process_bid(action)
            player = action.entity
            company = action.company
            price = action.price

            raise GameError, "#{company.name} is not being auctioned" unless company == @companies.first
            raise GameError, "Minimum bid is #{@game.format_currency(min_bid(company))}" if price < min_bid(company)

            unless (price % min_increment).zero?
              raise GameError,
                    "Bids must be a multiple of #{@game.format_currency(min_increment)}"
            end
            raise GameError, "#{player.name} cannot afford #{@game.format_currency(price)}" if price > player.cash

            @bids[company].reject! { |b| b.entity == player }
            @bids[company] << action
            @log << "#{player.name} bids #{@game.format_currency(price)} for #{company.name}"
            next_bidder!
            resolve
          end

          def process_pass(action)
            player = action.entity
            @log << "#{player.name} passes on #{@companies.first.name}"
            index = @bidders.index(player)
            @bidders.delete_at(index)
            @turn -= 1 if index < @turn
            @turn = 0 if @turn >= @bidders.size
            resolve
          end

          protected

          def active_auction
            company = @companies.first
            yield company, @bids[company] if company
          end

          private

          def start_auction
            players = @game.players
            @bidders = players.rotate(@auction_number % players.size)
            @turn = 0
            @log << "#{@bidders.first.name} opens the auction for #{@companies.first.name}"
          end

          def next_bidder!
            @turn = (@turn + 1) % @bidders.size
          end

          def resolve
            company = @companies.first
            high = highest_bid(company)
            if @bidders.empty?
              @log << "#{company.name} receives no bids and is removed from the game"
              @game.remove_industry(company)
              next_auction!
            elsif high && @bidders == [high.entity]
              @game.float_industry(company, high.entity, high.price)
              next_auction!
            end
          end

          def next_auction!
            @companies.shift
            @auction_number += 1
            start_auction unless @companies.empty?
          end
        end
      end
    end
  end
end
