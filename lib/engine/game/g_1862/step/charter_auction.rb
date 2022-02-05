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
            @round.won_auction[entity] = true

            @log << "#{entity.name} wins bid on #{corporation.name} for #{@game.format_currency(price)}"
            entity.spend(price, @game.bank) if price.positive?

            @finish_action = ['par']
            @finish_corporation = corporation
            @auctioning = nil

            @game.add_obligation(entity, corporation)

            @round.goto_entity!(winner.entity)
          end

          def can_start_auction?(entity)
            max_bid(entity) >= MIN_BID && !@round.won_auction[entity] &&
            @game.ipoable_corporations.any? do |c|
              @game.can_par?(c, entity) && can_buy?(entity, c.ipo_shares.first&.to_bundle)
            end
          end

          def can_bid?(entity)
            @game.ipoable_corporations.any? do |c|
              @game.can_par?(c, entity) && can_buy?(entity, c.ipo_shares.first&.to_bundle)
            end
          end

          def can_increase_bid?(entity)
            max_bid(entity) >= min_required(entity) && can_bid?(entity)
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
            @game.convert_to_full!(action.corporation)
            super

            if action.entity.cash >= action.share_price.price
              @finish_action = %w[buy_shares pass]
            else
              @log << "#{action.entity.name} skips buying additional shares"
              pass!
            end
          end

          def process_buy_shares(action)
            super

            entity = action.entity
            corporation = action.bundle.corporation
            return if entity.cash >= corporation.par_price.price && entity.percent_of(corporation) < 50

            @log << if entity.percent_of(corporation) >= 50
                      "#{entity.name} finishes buying additional shares"
                    else
                      "#{entity.name} skips buying additional shares"
                    end

            pass!
          end

          def process_bid(action)
            price = action.price
            raise GameError, "Bid must be a multiple of #{MIN_BID_INCREMENT}" if (price % MIN_BID_INCREMENT).positive?

            if @auctioning
              add_bid(action)
            else
              selection_bid(action)
            end
          end

          def auction_entity(entity)
            @auctioning = entity
            @active_bidders, cannot_bid = initial_auction_entities.partition do |player|
              player == @auction_triggerer || can_increase_bid?(player)
            end
            cannot_bid.each do |player|
              if max_bid(player) < min_required(player)
                @game.log << "#{player.name} cannot afford minimum bid + 3 x minimum par of "\
                             "#{@game.format_currency(min_required(player))} and is out of the auction for #{auctioning.name}"
              else
                @game.log << "#{player.name} cannot acquire #{auctioning.name}"
              end
            end
            resolve_bids
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

            passing = @active_bidders.reject do |player|
              player == entity || can_increase_bid?(player)
            end
            passing.each do |player|
              @game.log << "#{player.name} cannot afford minimum bid + 3 x minimum par of "\
                           "#{@game.format_currency(min_required(player))} and is out of the auction for #{auctioning.name}"
              remove_from_auction(player)
            end

            resolve_bids
          end

          def min_required(_entity)
            highest_bid(@auctioning).price + min_increment + (min_par * 3)
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
                won_auction: {},
              }
            )
          end
        end
      end
    end
  end
end
