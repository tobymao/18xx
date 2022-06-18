# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares_via_bid'

module Engine
  module Game
    module G1877StockholmTramways
      module Step
        class BuySellParShares < Engine::Step::BuySellParSharesViaBid
          MIN_BID = 0

          def actions(entity)
            return [] unless entity == current_entity
            return @finish_action if @finish_action

            super
          end

          def description
            if @finish_action&.include?('par')
              'Par Company'
            elsif @finish_action
              'Buy Additional Shares'
            else
              super
            end
          end

          def setup
            @finish_action = nil
            @next_entity = nil
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

            @round.goto_entity!(winner.entity)
          end

          def can_bid?(entity)
            max_bid(entity) >= MIN_BID && !bought? &&
            @game.ipoable_corporations.any? do |c|
              @game.can_par?(c, entity)
            end
          end

          def min_par
            @game.stock_market.par_prices.min_by(&:price).price
          end

          def get_par_prices(entity, _corp)
            @game.stock_market.par_prices.select { |sp| sp.price * 2 <= entity.cash }
          end

          def can_buy_multiple?(entity, corporation, _owner)
            entity.percent_of(corporation) < 50 && @finish_action
          end

          def ipo_type(_entity)
            if @finish_action
              :par
            else
              :bid
            end
          end

          def max_bid(player, corporation = nil)
            # player cannot bid if they are at cert limit
            return 0 if corporation && !can_gain?(player, @game.share_pool.shares_by_corporation[corporation].first.to_bundle)

            player.cash - (2 * min_par)
          end

          def log_pass(entity)
            return if @auctioning
            return super unless @finish_action

            @log << "#{entity.name} skips buying additional shares"
          end

          def pass!
            @round.goto_entity!(@next_entity) if @finish_action
            @finish_action = nil
            @next_entity = nil unless @auctioning
            super
          end

          def process_par(action)
            share_price = action.share_price
            corporation = action.corporation
            entity = action.entity
            @game.stock_market.set_par(corporation, share_price)
            share = @game.share_pool.shares_by_corporation[corporation].first
            @round.players_bought[entity][corporation] += share.percent
            buy_shares(entity, share.to_bundle)
            @game.after_par(corporation)
            track_action(action, action.corporation)

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

            pass!
          end

          def process_bid(action)
            @next_entity = @game.current_entity unless @auctioning
            super
          end

          def visible_corporations
            if @finish_action
              [@finish_corporation]
            else
              @game.sorted_corporations
            end
          end
        end
      end
    end
  end
end
