# frozen_string_literal: true

require_relative '../dividend'

module Engine
  module Step
    module G18Mag
      class Dividend < Dividend
        MIN_CORP_PAYOUT = 10
        CORP_TYPES = %i[variable withhold].freeze

        def actions(entity)
          return [] if entity.minor?
          return [] if !entity.corporation? || entity.receivership? || entity.cash < MIN_CORP_PAYOUT

          ACTIONS
        end

        def skip!
          if current_entity.minor?
            revenue = @game.routes_revenue(routes)
            process_dividend(Action::Dividend.new(
              current_entity,
              kind: revenue.positive? ? 'payout' : 'withhold',
            ))
          else
            amount = (current_entity.cash / MIN_CORP_PAYOUT).to_i * MIN_CORP_PAYOUT
            process_dividend(Action::Dividend.new(
              current_entity,
              kind: 'variable',
              amount: amount,
            ))
          end
        end

        def process_dividend(action)
          return super if action.entity.minor?

          entity = action.entity
          kind = action.kind.to_sym
          amount = action.amount || 0
          payout = corp_dividend_options(entity, amount)[kind]

          raise GameError, "Amount must be multiples of #{MIN_CORP_PAYOUT}" if amount % MIN_CORP_PAYOUT != 0

          entity.operating_history[[@game.turn, @round.round_num]] = OperatingInfo.new(
            routes,
            action,
            amount
          )

          @round.routes = []

          corp_log_run_payout(entity, amount)

          corp_payout_shares(entity, amount) if amount.positive?

          change_share_price(entity, payout)

          pass!
        end

        def corp_payout_shares(entity, amount)
          per_share = payout_per_share(entity, amount)

          payouts = {}
          @game.players.each do |payee|
            corp_payout_entity(entity, payee, per_share, payouts)
          end

          corp_payout_entity(entity, holder_for_corporation(entity), per_share, payouts, @game.bank)
          receivers = payouts
            .sort_by { |_r, c| -c }
            .map { |receiver, cash| "#{@game.format_currency(cash)} to #{receiver.name}" }.join(', ')

          @log << "#{entity.name} pays out #{@game.format_currency(amount)} = "\
            "#{@game.format_currency(per_share)} (#{receivers})"
        end

        def corp_payout_entity(entity, holder, per_share, payouts, receiver = nil)
          amount = dividends_for_entity(entity, holder, per_share)
          return if amount.zero?

          receiver ||= holder
          payouts[receiver] = amount
          entity.spend(amount, receiver, check_positive: false)
        end

        def dividend_types
          return super if current_entity.minor?

          self.class::CORP_TYPES
        end

        def corp_dividend_options(entity, amount = 0)
          dividend_types.map do |type|
            payout = send(type, entity, amount)
            payout[:divs_to_corporation] = 0
            [type, payout.merge(share_price_change(entity, amount - payout[:corporation]))]
          end.to_h
        end

        def withhold(entity, _revenue)
          return super if entity.minor?

          { corporation: 0, per_share: 0 }
        end

        def variable(entity, amount)
          { corporation: 0, per_share: payout_per_share(entity, amount) }
        end

        def corp_log_run_payout(entity, amount)
          if amount.positive?
            @log << "#{entity.name} pays out #{@game.format_currency(amount)}"
            return
          end
          @log << "#{entity.name} does not pay out"
        end

        def share_price_change(entity, revenue = 0)
          return {} if entity.minor?

          if revenue.zero?
            { share_direction: :left, share_times: 1 }
          elsif revenue <= 20
            {}
          elsif revenue <= 50
            { share_direction: :right, share_times: 1 }
          elsif revenue <= 100
            { share_direction: :right, share_times: 2 }
          elsif revenue <= 200
            { share_direction: :right, share_times: 3 }
          else
            { share_direction: :right, share_times: 4 }
          end
        end

        def payout(entity, revenue)
          return super if entity.corporation?

          amount = revenue / 2
          { corporation: amount, per_share: amount }
        end

        def payout_shares(entity, revenue)
          return super if entity.corporation?

          @log << "#{entity.owner.name} receives #{@game.format_currency(revenue)}"
          @game.bank.spend(revenue, entity.owner)
        end

        def min_increment
          MIN_CORP_PAYOUT
        end

        def variable_max
          (current_entity.cash / MIN_CORP_PAYOUT).to_i * MIN_CORP_PAYOUT
        end
      end
    end
  end
end
