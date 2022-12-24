# frozen_string_literal: true

require_relative 'base'
require_relative '../operating_info'
require_relative '../action/dividend'

module Engine
  module Step
    class Dividend < Base
      ACTIONS = %w[dividend].freeze

      def actions(entity)
        return [] if entity.company? || @game.routes_revenue(routes).zero?

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

        current_entity.operating_history[[@game.turn, @round.round_num]] =
          OperatingInfo.new([], @game.actions.last, 0, @round.laid_hexes)
      end

      def dividend_options(entity)
        revenue = @game.routes_revenue(routes) + dividend_adjustment(entity)
        dividend_types.to_h do |type|
          payout = send(type, entity, revenue)
          payout[:divs_to_corporation] = corporation_dividends(entity, payout[:per_share])
          [type, payout.merge(share_price_change(entity, revenue - payout[:corporation]))]
        end
      end

      def dividend_adjustment(_entity)
        0
      end

      def process_dividend(action)
        entity = action.entity
        revenue = @game.routes_revenue(routes) + dividend_adjustment(entity)
        kind = action.kind.to_sym
        payout = dividend_options(entity)[kind]

        entity.operating_history[[@game.turn, @round.round_num]] = OperatingInfo.new(
          routes,
          action,
          revenue,
          @round.laid_hexes
        )

        entity.trains.each { |train| train.operated = true }

        rust_obsolete_trains!(entity)

        @round.routes = []

        log_run_payout(entity, kind, revenue, action, payout)

        payout_corporation(payout[:corporation], entity)

        payout_shares(entity, revenue - payout[:corporation]) if payout[:per_share].positive?

        change_share_price(entity, payout)

        pass!
      end

      def payout_corporation(amount, entity)
        @game.bank.spend(amount, entity) if amount.positive?
      end

      def log_run_payout(entity, kind, revenue, action, payout)
        unless Dividend::DIVIDEND_TYPES.include?(kind)
          @log << "#{entity.name} runs for #{@game.format_currency(revenue)} and pays #{action.kind}"
        end

        if payout[:corporation].positive?
          @log << "#{entity.name} withholds #{@game.format_currency(payout[:corporation])}"
        elsif payout[:per_share].zero?
          @log << "#{entity.name} does not run"
        end
      end

      def share_price_change(_entity, revenue)
        if revenue.positive?
          { share_direction: :right, share_times: 1 }
        else
          { share_direction: :left, share_times: 1 }
        end
      end

      def withhold(_entity, revenue)
        { corporation: revenue, per_share: 0 }
      end

      def payout(entity, revenue)
        { corporation: 0, per_share: payout_per_share(entity, revenue) }
      end

      def dividends_for_entity(entity, holder, per_share)
        # 1817 2 share half pay uses floats, for 18MEX num_shares can be a float for NdM
        (holder.num_shares_of(entity, ceil: false) * per_share).ceil
      end

      def corporation_dividends(entity, per_share)
        return 0 if entity.minor?

        dividends_for_entity(entity, holder_for_corporation(entity), per_share)
      end

      def payout_per_share(entity, revenue)
        revenue / entity.total_shares
      end

      def holder_for_corporation(entity)
        entity.capitalization == :incremental ? entity : @game.share_pool
      end

      def payout_shares(entity, revenue)
        per_share = payout_per_share(entity, revenue)

        payouts = {}
        (@game.players + @game.corporations).each do |payee|
          payout_entity(entity, payee, per_share, payouts)
        end

        receivers = payouts
                      .sort_by { |_r, c| -c }
                      .map { |receiver, cash| "#{@game.format_currency(cash)} to #{receiver.name}" }.join(', ')

        log_payout_shares(entity, revenue, per_share, receivers)
      end

      def payout_entity(entity, holder, per_share, payouts)
        amount =
          if entity == holder
            corporation_dividends(entity, per_share)
          else
            dividends_for_entity(entity, holder, per_share)
          end
        return if amount.zero?

        receiver ||= holder
        payouts[receiver] = amount
        @game.bank.spend(amount, receiver, check_positive: false)
      end

      def change_share_price(entity, payout)
        return unless payout[:share_direction]

        # For any company without a share price, skip price movement
        return unless entity.share_price

        old_price = entity.share_price

        right_times = 0
        Array(payout[:share_times]).zip(Array(payout[:share_direction])).each do |share_times, direction|
          share_times.times do
            case direction
            when :left
              @game.stock_market.move_left(entity)
            when :right
              @game.stock_market.move_right(entity)
              right_times += 1
            when :up
              @game.stock_market.move_up(entity)
            when :down
              @game.stock_market.move_down(entity)
            end
          end
        end
        @game.log_share_price(entity, old_price, right_times)
      end

      def routes
        @round.routes
      end

      def rust_obsolete_trains!(entity, log: true)
        rusted_trains = entity.trains.select(&:obsolete).each do |train|
          @game.rust(train)
        end

        @log << '-- Event: Obsolete trains rust --' if log && !rusted_trains.empty?
      end

      def pass!
        return unless (entity = current_entity)

        @game.close_companies_on_event!(entity, 'operated') if entity.operating_history.size == 1
        super
      end

      private

      def log_payout_shares(entity, revenue, per_share, receivers)
        @log << "#{entity.name} pays out #{@game.format_currency(revenue)} = "\
                "#{@game.format_currency(per_share)} per share (#{receivers})"
      end
    end
  end
end
