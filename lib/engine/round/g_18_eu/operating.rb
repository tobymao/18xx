# frozen_string_literal: true

require_relative '../operating'
require_relative '../../token'
#require_relative '../half_pay'
#require_relative '../issue_shares'
#require_relative '../minor_half_pay'

module Engine
  module Round
    module G18EU
      class Operating < Operating
        #include HalfPay
        #include IssueShares
        #include MinorHalfPay

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

        def change_share_price(revenue = 0)
          return if @current_entity.minor?

          price = @current_entity.share_price.price
          @stock_market.move_left(@current_entity) if revenue.zero?
          @stock_market.move_right(@current_entity) if revenue >= price
          log_share_price(@current_entity, price)
        end
      end
    end
  end
end
