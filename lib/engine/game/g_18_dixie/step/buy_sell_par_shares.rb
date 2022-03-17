# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative '../../../step/passable_auction'

module Engine
  module Game
    module G18Dixie
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          include Engine::Step::PassableAuction
          MIN_BID = 100

          def actions(entity)
            return [] unless entity.player?
            return [] unless entity == current_entity
            return %w[bid pass] if @auctioning

            actions = super
            actions << 'bid' if !bought? && can_auction_any_company?(entity)
            actions << 'pass' if actions.any? && !actions.include?('pass') && !must_sell?(entity)
            actions
          end

          def auctionable_companies
            @game.companies.select { |company| company.owner == @game.bank && @game.must_auction_company?(company) }
          end

          def can_auction_any_company?(player)
            auctionable_companies.any? { |company| can_auction_company?(player, company) }
          end

          def can_auction_company?(player, company)
            company.owner == @game.bank &&
              @game.must_auction_company?(company) && @game.bidding_power(player) > min_bid(company)
          end

          def can_bid_company?(player, company)
            @game.buyable_bank_owned_companies.include?(company) &&
              player.cash >= company.value && @game.must_auction_company?(company)
          end

          def can_buy_company?(_, company)
            super && !@game.must_auction_company?(company)
          end

          def normal_pass?(_entity)
            !@auctioning
          end

          def active_entities
            return super unless @auctioning

            [@active_bidders[(@active_bidders.index(highest_bid(@auctioning).entity) + 1) % @active_bidders.size]]
          end

          def auctioning_corporation
            return @winning_bid.corporation if @winning_bid

            @auctioning
          end

          def pass_description
            if @auctioning
              'Pass (Bid)'
            else
              super
            end
          end

          def pass!
            return par_corporation if @winning_bid

            unless @auctioning
              @round.current_actions << @corporate_action
              return super
            end

            pass_auction(current_entity)
            resolve_bids
          end

          def process_bid(action)
            if auctioning
              add_bid(action)
            else
              selection_bid(action)
            end
          end

          def add_bid(action)
            entity = action.entity
            company = action.company
            price = action.price

            if @auctioning
              @log << "#{entity.name} bids #{@game.format_currency(price)} for #{company.name}"
            else
              @log << "#{entity.name} auctions #{company.name} for #{@game.format_currency(price)}"
              @round.last_to_act = action.entity
              @round.current_actions.clear
            end
            super(action)

            resolve_bids
          end

          def contribution_can_exceed_corporation_cash?
            false
          end

          def win_bid(winner, _company)
            player = winner.entity
            company = winner.company
            price = winner.price
            company.owner = player
            player.companies << company

            player.spend(price, @game.bank) if price.positive?
            @game.after_buy_company(player, company, price)
            @companies.delete(company)
            @log <<
                "#{player.name} wins the auction for #{company.name} "\
                "with a bid of #{@game.format_currency(price)}"
          end

          def committed_cash
            0
          end

          def min_bid(entity)
            return entity.value unless @auctioning

            highest_bid(entity).price + min_increment
          end

          def max_bid(entity, _corporation = nil)
            return 0 if @game.num_certs(entity) >= @game.cert_limit

            @game.bidding_power(entity)
          end

          def starting_bid(company)
            company.value
          end

          def setup
            setup_auction
            super
            @companies = auctionable_companies
          end

          def round_state
            super.merge({ auctioning: nil })
          end

          def auction_entity(entity)
            v = super
            @round.auctioning = @auctioning
            v
          end

          def resolve_bids
            super
            @round.auctioning = @auctioning
            return unless @auctioning

            entities.each(&:unpass!)
            @round.goto_entity!(@auction_triggerer)
            @round.next_entity_index!
          end

          def process_buy_company(action)
            super
            company = action.company
            sym = company.sym
            @game.float_minor(sym, action.entity) unless sym[0] == 'P'
            @round.next_entity_index!
          end
        end
      end
    end
  end
end
