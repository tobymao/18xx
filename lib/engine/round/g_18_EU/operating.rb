# frozen_string_literal: true

require_relative '../operating'
require_relative '../../token'
require_relative '../half_pay'

module Engine
  module Round
    module G18EU
      class Operating < Operating
        MINOR_STEPS = %i[
          track
          route
          dividend
        ].freeze

        STEPS = %i[
          issue
          track
          token
          route
          dividend
          train
        ].freeze

        STEP_DESCRIPTION = {
          issue: 'Issue or Redeem Shares',
          track: 'Lay Track',
          token: 'Place Token',
          route: 'Run Routes',
          dividend: 'Pay or Withhold Dividends',
          train: 'Buy Trains',
        }.freeze

        SHORT_STEP_DESCRIPTION = {
          issue: 'Issue/Redeem',
          track: 'Lay Track',
          token: 'Place Token',
          route: 'Routes',
          train: 'Train',
        }.freeze

        DIVIDEND_TYPES = %i[payout withhold half].freeze

        def select(entities, _game, _round_num)
          minors, corporations = entities.partition(&:minor?)
          corporations.select!(&:floated?)
          corporations.sort!
          minors + corporations
        end

        def steps
          @current_entity.minor? ? self.class::MINOR_STEPS : self.class::STEPS
        end

        def issuable_shares
          num_shares = @current_entity.num_player_shares - @current_entity.num_market_shares
          bundles = @current_entity.bundles_for_corporation(@current_entity)
          share_price = @game.stock_market.find_share_price(@current_entity, :left).price

          bundles
            .each { |bundle| bundle.share_price = share_price }
            .reject { |bundle| bundle.num_shares > num_shares }
        end

        def redeemable_shares
          share_price = @game.stock_market.find_share_price(@current_entity, :right).price

          @game
            .share_pool
            .bundles_for_corporation(@current_entity)
            .each { |bundle| bundle.share_price = share_price }
            .reject { |bundle| @current_entity.cash < bundle.price }
        end

        private

        def skip_issue
          issuable_shares.empty? && redeemable_shares.empty?
        end

        def skip_dividend
          return super if @current_entity.corporation?

          revenue = @current_routes.sum(&:revenue)
          process_dividend(Action::Dividend.new(
            @current_entity,
            kind: revenue.positive? ? 'payout' : 'withhold',
          ))
          true
        end

        def skip_token_or_track
          skip_track && skip_token
        end

        def process_sell_shares(action)
          return super if action.entity.player?

          @game.share_pool.sell_shares(action.bundle)
        end

        def process_buy_shares(action)
          @game.share_pool.buy_shares(@current_entity, action.bundle)
        end

        def payout(revenue)
          return super if @current_entity.corporation?

          @log << "#{@current_entity.name} pays out #{@game.format_currency(revenue)}"

          amount = revenue / 2

          [@current_entity, @current_entity.owner].each do |entity|
            @log << "#{entity.name} receives #{@game.format_currency(amount)}"
            @bank.spend(amount, entity)
          end
        end

        def change_share_price(_direction, revenue = 0)
          return if @current_entity.minor?

          price = @current_entity.share_price.price
          @stock_market.move_left(@current_entity) if revenue.zero
          @stock_market.move_right(@current_entity) if revenue >= price
          log_share_price(@current_entity, price)
        end
      end
    end
  end
end
