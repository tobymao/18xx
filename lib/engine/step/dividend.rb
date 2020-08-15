# frozen_string_literal: true

require_relative 'base'
require_relative '../operating_info'
require_relative '../action/dividend'

module Engine
  module Step
    class Dividend < Base
      ACTIONS = %w[dividend].freeze

      def actions(entity)
        return [] if entity.company? || routes.empty?

        ACTIONS
      end

      DIVIDEND_TYPES = %i[payout withhold].freeze
      def dividend_types
        self.class::DIVIDEND_TYPES
      end

      def description
        'Pay or Withhold Dividends'
      end

      def skip!
        process_dividend(Action::Dividend.new(current_entity, kind: 'withhold'))
      end

      def dividend_options(entity)
        revenue = @game.routes_revenue(routes)
        dividend_types.map do |type|
          payout = send(type, entity, revenue)
          payout[:divs_to_company] = company_dividends(entity, payout[:per_share])
          [type, payout.merge(share_price_change(entity, revenue - payout[:company]))]
        end.to_h
      end

      def process_dividend(action)
        entity = action.entity
        revenue = @game.routes_revenue(routes)
        kind = action.kind.to_sym
        payout = dividend_options(entity)[kind]

        rust_obsolete_trains!(entity)

        entity.operating_history[[@game.turn, @round.round_num]] = OperatingInfo.new(
          routes,
          action,
          revenue
        )

        entity.trains.each { |train| train.operated = true }

        @round.routes = []

        unless Dividend::DIVIDEND_TYPES.include?(kind)
          @log << "#{entity.name} runs for #{@game.format_currency(revenue)} and pays #{action.kind}"
        end

        if payout[:company].positive?
          @log << "#{entity.name} withholds #{@game.format_currency(payout[:company])}"
          @game.bank.spend(payout[:company], entity)
        elsif payout[:per_share].zero?
          @log << "#{entity.name} does not run"
        end

        payout_shares(entity, revenue - payout[:company]) if payout[:per_share].positive?

        change_share_price(entity, payout)

        pass!
      end

      def share_price_change(_entity, revenue)
        if revenue.positive?
          { share_direction: :right, share_times: 1 }
        else
          { share_direction: :left, share_times: 1 }
        end
      end

      def withhold(_entity, revenue)
        { company: revenue, per_share: 0 }
      end

      def payout(entity, revenue)
        { company: 0, per_share: payout_per_share(entity, revenue)[0] }
      end

      def dividends_for_entity(entity, holder, per_share)
        return 0 if (percent = holder.percent_of(entity)).zero?
        share_count = 10
        shares = percent / (100 / share_count)
        shares * per_share
      end

      def company_dividends(entity, per_share)
        return 0 if entity.minor?
        dividends_for_entity(entity, holder_for_company(entity), per_share)
      end

      def payout_per_share(_entity_, revenue)
        # TODO: actually count shares when we implement 1817, 18Ireland, 18US, etc
        share_count = 10
        per_share = revenue / share_count
        [per_share, share_count]
      end

      def holder_for_company(entity)
        entity.capitalization == :incremental ? entity : @game.share_pool
      end

      def payout_shares(entity, revenue)
        per_share, share_count = payout_per_share(entity, revenue)
        @log << "#{entity.name} pays out #{@game.format_currency(revenue)} = "\
                "#{@game.format_currency(per_share)} x #{share_count} shares"

        @game.players.each do |player|
          payout_entity(entity, player, per_share)
        end

        payout_entity(entity, holder_for_company(entity), per_share, entity)
      end

      def payout_entity(entity, holder, per_share, receiver = nil)
        amount = dividends_for_entity(entity, holder, per_share)
        return if amount.zero?
        receiver ||= holder
        @game.bank.spend(amount, receiver)
      end

      def change_share_price(entity, payout)
        return unless payout[:share_direction]

        prev = entity.share_price.price
        payout[:share_times].times do
          case payout[:share_direction]
          when :left
            @game.stock_market.move_left(entity)
          when :right
            @game.stock_market.move_right(entity)
          end
        end
        @game.log_share_price(entity, prev)
      end

      def routes
        @round.routes
      end

      def rust_obsolete_trains!(entity)
        (rusted_trains = entity.trains.select(&:obsolete)).each(&:rust!)

        @log << '-- Event: Obsolete trains rust --' if rusted_trains.any?
      end
    end
  end
end
