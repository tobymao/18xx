# frozen_string_literal: true

require_relative '../../../step/auctioner'

module Engine
  module Game
    module G18EUS
      module BidboxAuction
        include Engine::Step::Auctioner

        def actions(entity)
          actions = []
          actions << 'bid' << 'pass' if !@game.buyable_bank_owned_companies.empty?
          actions.concat(super).uniq
        end

        def setup
          # This sets the initial value of @bids
          setup_auction
          super

          @bid_actions = 0
          @bids = @round.bids if @round.bids
          # Set initial value of @bids on the round if there's none.
          @round.bids = @bids unless @round.bids
        end

        def can_buy_company?(_player, _company)
          false # Only companies are privates
        end
    
        def min_bid(company)
          return unless company

          high_bid = highest_bid(company)
          (high_bid ? high_bid.price + min_increment : company.min_bid)
        end

        def max_bid(player, _company)
          player.cash - committed_cash(player)
        end

        def committed_cash(player, _show_hidden = false)
          bids_for_player(player, only_committed_bids: true).sum(&:price)
        end

        def find_bid(player, company)
          @bids[company]&.find { |b| b.entity == player }
        end

        def highest_player_bid?(player, company)
          return false unless find_bid(player, company)

          current_bid_amount(player, company) >= (highest_bid(company)&.price || 0)
        end

        protected

        def active_auction
          company = @auctioning
          bids = @bids[company]
          yield company, bids if bids.size > 1
        end

        def bids_for_player(player, only_committed_bids: false)
          @bids.values.map do |bids|
            if only_committed_bids
              highest_bid = bids.max_by(&:price)
              highest_bid if highest_bid&.entity == player
            else
              bids.find { |bid| bid.entity == player }
            end
          end.compact
        end

        def num_certs_with_bids(entity)
          @game.num_certs(entity) + bids_for_player(entity, only_committed_bids: true).size
        end

        def pass!
          # This should only be updated at the end of the round, not after each bid.
          @round.update_stored_winning_bids(current_entity)
          store_bids!
          super
        end

        def pass_description
          return 'Pass (Bids)' if @bid_actions.positive?

          super
        end

        def process_bid(action)
          action.entity.unpass!
          add_bid(action)
          store_bids!
        end

        def bidding_tokens(player)
          @game.bidding_token_per_player - (bids_for_player(player)&.size || 0)
        end

        def can_bid_company?(entity, company)
          return false unless num_certs_with_bids(entity) < @game.cert_limit
          return false if max_bid(entity, company) < min_bid(company) || highest_player_bid?(entity, company)

          !(!find_bid(entity, company) && bidding_tokens(entity).zero?)
        end

        def store_bids!
          @round.bids = @bids
        end

        def add_bid(action)
          super

          company = action.company
          price = action.price
          entity = action.entity

          track_action(action, bid_target(action))

          @log << "#{entity.name} bids #{@game.format_currency(price)} for #{company.name}"
          @bid_actions += 1

          return if @bid_actions < @game.class::BIDDING_TOKENS_PER_ACTION

          log_pass(entity)
          pass!
        end
      end
    end
  end
end
