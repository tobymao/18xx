# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative '../../../step/passable_auction'

module Engine
  module Game
    module GRollingStock
      module Step
        class BuySellSharesBidCompanies < Engine::Step::BuySellParShares
          include Engine::Step::PassableAuction

          def actions(entity)
            return [] unless entity == current_entity
            return %w[bid pass] if @auctioning

            actions = []
            actions << 'buy_shares' if can_buy_any?(entity)
            actions << 'sell_shares' if can_sell_any?(entity)
            actions << 'bid' if can_bid?(entity)

            actions << 'pass' unless actions.empty?
            actions
          end

          def can_bid?(entity)
            biddable = @game.biddable_companies
            !biddable.empty? && max_bid(entity) >= biddable.min_by(&:value).value
          end

          def auctioning_corporation
            @auctioning
          end

          def normal_pass?(_entity)
            !@auctioning
          end

          def active_entities
            return super unless @auctioning

            [@active_bidders[(@active_bidders.index(highest_bid(@auctioning).entity) + 1) % @active_bidders.size]]
          end

          def pass_auction(entity)
            @log << "#{entity.name} passes on #{auctioning.sym}"
            remove_from_auction(entity)
          end

          def log_pass(entity)
            return if @auctioning

            super
          end

          def pass!
            return super unless @auctioning

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

            @log << if @auctioning
                      "#{entity.name} bids #{@game.format_currency(price)} for #{company.sym}"
                    else
                      "#{entity.name} auctions #{company.sym} for #{@game.format_currency(price)}"
                    end
            super(action)

            resolve_bids
          end

          def win_bid(winner, company)
            entity = winner.entity
            price = winner.price

            @log << "#{entity.name} wins bid and buys #{company.sym} for #{@game.format_currency(price)}"
            company.owner = entity
            entity.companies << company
            entity.spend(price, @game.bank)

            @game.update_offering(company)
          end

          def post_win_bid(_winner, _company)
            @round.goto_entity!(@auction_triggerer)
            @round.next_entity!
          end

          def min_bid(company)
            return company.value unless @auctioning

            highest_bid(company).price + min_increment
          end

          def max_bid(player, _company = nil)
            player.cash
          end

          def min_increment
            1
          end

          def pass_description
            if @auctioning
              'Pass (Bid)'
            else
              super
            end
          end

          def visible_corporations
            @game.corporations.select(&:ipoed)
          end

          def can_bid_company?(entity, company)
            return unless company

            @game.biddable_companies.include?(company) && max_bid(entity) >= company.value
          end

          def setup
            setup_auction
            super
          end
        end
      end
    end
  end
end
