# frozen_string_literal: true

require_relative '../base'
require_relative '../auctioner'

module Engine
  module Step
    module G1873
      class ConcessionAuction < Base
        include Auctioner
        ACTIONS = %w[bid pass].freeze

        attr_reader :companies

        def description
          if @auctioning
            'Bid on Selected Concession or Puchase Option'
          else
            'Bid on Concession or Purchase Option'
          end
        end

        def available
          auctioning ? [auctioning] : @companies
        end

        def process_pass(action)
          entity = action.entity

          if auctioning
            pass_auction(action.entity)
          else
            @log << "#{entity.name} passes bidding"
            entity.pass!
            @round.next_entity_index!
          end
        end

        def process_bid(action)
          action.entity.unpass!

          if auctioning
            add_bid(action)
          else
            start_auction(action)
          end
        end

        def active_entities
          active_auction do |_, bids|
            return [bids.min_by(&:price).entity]
          end

          super
        end

        def actions(entity)
          return [] if @companies.empty?

          correct = false

          active_auction do |_company, bids|
            correct = bids.min_by(&:price).entity == entity
          end

          correct || entity == current_entity ? ACTIONS : []
        end

        def setup
          setup_auction
          @companies = @game.auction_companies
        end

        def min_bid(company)
          return unless company

          high_bid = highest_bid(company)
          high_bid ? high_bid.price + min_increment : company.min_bid
        end

        def may_purchase?(_company)
          false
        end

        def committed_cash(player, _show_hidden = false)
          bids_for_player(player).sum(&:price)
        end

        def max_bid(player, _company)
          player.cash
        end

        protected

        def resolve_bids
          return unless @bids[@auctioning].one?

          bid = @bids[@auctioning].first
          @auctioning = nil
          price = bid.price
          company = bid.company
          player = bid.entity
          @bids.delete(company)
          buy_company(player, company, price)
        end

        def active_auction
          company = @auctioning
          bids = @bids[company]
          yield company, bids if bids.size.positive?
        end

        def can_auction?(company)
          company == @companies.first && @bids[company].size > 1
        end

        def buy_company(player, company, price)
          if (available = max_bid(player, company)) < price
            raise GameError, "#{player.name} has #{@game.format_currency(available)} "\
              'available and cannot spend '\
              "#{@game.format_currency(price)}"
          end

          company.owner = player
          player.companies << company
          player.spend(price, @game.bank) if price.positive?
          @companies.delete(company)
          @log << "#{player.name} wins the auction for #{company.name} "\
            "with a bid of #{@game.format_currency(price)}"
        end

        private

        def start_auction(bid)
          @auctioning = bid.company
          @log << "#{@auctioning.name} goes up for auction"
          add_bid(bid)
          starter = bid.entity
          start_price = bid.price

          bids = @bids[@auctioning]

          players = entities
          players.rotate!(players.find_index(starter))
          players.each_with_index do |player, idx|
            next if player == starter
            next if max_bid(player, @auctioning) <= start_price

            bids << (Engine::Action::Bid.new(player,
                                             corporation: @auctioning,
                                             price: idx - players.size))
          end
        end

        def add_bid(bid)
          super

          @log << "#{bid.entity.name} bids #{@game.format_currency(bid.price)} for #{bid.company.name}"
        end
      end
    end
  end
end
