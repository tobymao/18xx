# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative '../../../step/passable_auction'

module Engine
  module Game
    module G1862
      module Step
        class CharterAuction < Engine::Step::BuySellParShares
          include Engine::Step::PassableAuction

          attr_reader :companies

          MIN_BID = 0
          MIN_BID_INCREMENT = 5

          def actions(entity)
            return [] unless entity == current_entity
            return @finish_action if @finish_action
            return %w[] if @auctioning && !can_increase_bid?(entity)
            return %w[bid pass] if @auctioning

            actions = []
            actions << 'bid' if can_start_auction?(entity)
            actions << 'pass' if actions.any? && !actions.include?('pass')
            actions
          end

          def description
            if @auctioning
              'Bid on Selected Charter'
            elsif @finish_action&.include?('par')
              'Par Company'
            elsif @finish_action
              'Buy Additional Shares'
            else
              'Select and Bid on Charter'
            end
          end

          def setup
            @finish_action = nil
            setup_auction
            super
          end

          def win_bid(winner, _company)
            entity = winner.entity
            corporation = winner.corporation
            price = winner.price

            @log << "#{entity.name} wins bid on #{corporation.name} for #{@game.format_currency(price)}"
            entity.spend(price, @game.bank) if price.positive?

            @finish_action = ['par']
            @finish_corporation = corporation
            @auctioning = nil

            @game.add_obligation(entity, corporation)

            @round.goto_entity!(winner.entity)
          end

          def can_start_auction?(entity)
            max_bid(entity) >= MIN_BID && !@round.started_auction[entity] &&
            @game.ipoable_corporations.any? do |c|
              @game.can_par?(c, entity) && can_buy?(entity, c.shares.first&.to_bundle)
            end
          end

          def can_bid?(entity)
            max_bid(entity) >= MIN_BID &&
            @game.ipoable_corporations.any? do |c|
              @game.can_par?(c, entity) && can_buy?(entity, c.shares.first&.to_bundle)
            end
          end

          def can_increase_bid?(entity)
            max_bid(entity) >= highest_bid(@auctioning).price + min_increment + min_par * 3
          end

          def min_par
            @game.stock_market.par_prices.min_by(&:price).price
          end

          def get_par_prices(entity, _corp)
            @game.stock_market.par_prices.select { |sp| sp.price * 3 <= entity.cash }
          end

          def can_buy_multiple?(entity, corporation, _owner)
            entity.percent_of(corporation) < 50
          end

          def ipo_type(_entity)
            if @finish_action
              :par
            else
              :bid
            end
          end

          def auctioning_corporation
            return @winning_bid.corporation if @winning_bid

            @auctioning
          end

          def normal_pass?(_entity)
            !@auctioning
          end

          def active_entities
            return super unless @auctioning

            [@active_bidders[(@active_bidders.index(highest_bid(@auctioning).entity) + 1) % @active_bidders.size]]
          end

          def log_pass(entity)
            return if @auctioning
            return super unless @finish_action

            @log << "#{entity.name} passes buying additional shares"
          end

          def pass!
            @finish_action = nil
            return super unless @auctioning

            pass_auction(current_entity)
            resolve_bids
          end

          def process_par(action)
            super

            if action.entity.cash >= action.share_price.price
              @finish_action = %w[buy_shares pass]
            else
              @log << "#{entity.name} skips buying additional shares"
              pass!
            end
          end

          def process_buy_shares(action)
            super

            entity = action.entity
            corporation = action.bundle.corporation
            return if entity.cash >= corporation.par_price.price && entity.percent_of(corporation) < 50

            @log << if entity.cash < corporation.par_price.price
                      "#{entity.name} skips buying additional shares"
                    else
                      "#{entity.name} finishes buying additional shares"
                    end

            pass!
          end

          def process_bid(action)
            price = action.price
            raise GameError, "Bid must be a multiple of #{MIN_BID_INCREMENT}" if (price % MIN_BID_INCREMENT).positive?

            if auctioning
              add_bid(action)
            else
              selection_bid(action)
              @round.started_auction[action.entity] = true
            end
          end

          def add_bid(action)
            entity = action.entity
            corporation = action.corporation
            price = action.price

            @log << if @auctioning
                      "#{entity.name} bids #{@game.format_currency(price)} for #{corporation.name}"
                    else
                      "#{entity.name} auctions #{corporation.name} for #{@game.format_currency(price)}"
                    end
            super(action)

            resolve_bids
          end

          def min_bid(corporation)
            return self.class::MIN_BID unless @auctioning

            highest_bid(corporation).price + min_increment
          end

          def max_bid(player, _corporation = nil)
            player.cash
          end

          def pass_description
            if @auctioning
              'Pass (Bid)'
            else
              super
            end
          end

          def visible_corporations
            if @finish_action
              [@finish_corporation]
            else
              @game.ipoable_corporations
            end
          end

          def round_state
            super.merge(
              {
                started_auction: {},
              }
            )
          end
        end
      end
    end
  end
end
