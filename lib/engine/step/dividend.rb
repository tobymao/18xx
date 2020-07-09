# frozen_string_literal: true

require_relative 'base'
require_relative '../operating_info'
require_relative '../action/dividend'

module Engine
  module Step
    class Dividend < Base
      ACTIONS = %w[dividend].freeze

      def actions(_entity)
        return [] unless routes.any?

        ACTIONS
      end

      def skip!
        process_dividend(Action::Dividend.new(current_entity, kind: 'withhold'))
      end

      def process_dividend(action)
        entity = action.entity
        revenue = routes.sum(&:revenue)
        rust_obsolete_trains!(routes)

        entity.operating_history[[@game.turn, @round_num]] = OperatingInfo.new(
          routes,
          action,
          revenue
        )

        entity.trains.each { |train| train.operated = true }
        @round.routes = []
        send(action.kind, entity, revenue)
        pass!
      end

      def withhold(entity, revenue = 0)
        name = entity.name
        if revenue.positive?
          @log << "#{name} withholds #{@game.format_currency(revenue)}"
          @bank.spend(revenue, entity)
        else
          @log << "#{name} does not run"
        end
        change_share_price(entity, 0)
      end

      def payout(entity, revenue)
        # TODO: actually count shares when we implement 1817, 18Ireland, 18US, etc
        share_count = 10
        per_share = revenue / share_count
        @log << "#{entity.name} pays out #{@game.format_currency(revenue)} = "\
                "#{@game.format_currency(per_share)} x #{share_count} shares"

        @game.players.each do |player|
          payout_entity(entity, player, per_share)
        end

        if entity.capitalization == :incremental
          payout_entity(entity, entity, per_share, entity)
        else
          payout_entity(entity, @game.share_pool, per_share, entity)
        end
        change_share_price(entity, revenue)
      end

      def payout_entity(entity, holder, per_share, receiver = nil)
        return if (percent = holder.percent_of(entity)).zero?

        receiver ||= holder
        # TODO: actually count shares when we implement 1817, 18Ireland, 18US, etc
        share_count = 10
        shares = percent / (100 / share_count)
        amount = shares * per_share
        @log << "#{receiver.name} receives #{@game.format_currency(amount)} = "\
                "#{@game.format_currency(per_share)} x #{shares} shares"
        @game.bank.spend(amount, receiver)
      end

      def change_share_price(entity, revenue)
        prev = entity.share_price.price
        revenue.zero? ? @game.stock_market.move_left(entity) : @game.stock_market.move_right(entity)
        @game.log_share_price(entity, prev)
      end

      def routes
        @round.routes
      end

      def rust_obsolete_trains!(routes)
        rusted_trains = []

        routes.each do |route|
          train = route.train
          next unless train.obsolete

          rusted_trains << train.name
          train.rust!
        end

        @log << '-- Event: Obsolete trains rust --' if rusted_trains.any?
      end
    end
  end
end
