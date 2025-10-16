# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G1840
      module Step
        class Dividend < Engine::Step::Dividend
          DIVIDEND_TYPES = %i[payout variable withhold].freeze
          def actions(entity)
            return [] if entity.company?

            if entity.type == :major
              return [] if @game.major_revenue(entity).zero?

              return ACTIONS
            end

            return [] if routes.empty?

            ACTIONS
          end

          def change_share_price(entity, payout)
            return if entity.type == :minor

            super
          end

          def process_dividend(action)
            entity = action.entity

            return super if entity.type == :minor || entity.type == :city

            kind = action.kind.to_sym
            amount = action.amount || 0
            payout = corp_dividend_options(entity, amount)[kind]

            if (amount > variable_max(entity)) || amount.negative?
              raise GameError,
                    "Dividend cannot be larger than total revenue of #{@game.format_currency(variable_max(entity))} "\
                    "or smaller than #{@game.format_currency(0)}"
            end
            raise GameError, "Dividend must be multiples of #{variable_input_step}" if amount % variable_input_step != 0

            entity.operating_history[[@game.turn, @round.round_num]] = OperatingInfo.new(
              routes,
              action,
              amount,
              @round.laid_hexes
            )

            @game.update_last_revenue(entity)
            @round.routes = []

            withhold_value = @game.major_revenue(entity) - amount
            corp_log_run_payout(entity, amount, withhold_value)
            @game.corporate_card_minors(entity).each { |item| item.spend(item.cash, @game.bank, check_positive: false) }

            corp_payout_shares(entity, amount, withhold_value)

            change_share_price(entity, payout)

            pass!
          end

          def corp_log_run_payout(entity, amount, withhold_value)
            text = if amount.positive?
                     "#{entity.name} pays out #{@game.format_currency(amount)}"
                   else
                     "#{entity.name} does not pay out"
                   end

            text += " and withholds #{@game.format_currency(withhold_value)}" if withhold_value.positive?
            @log << text
          end

          def payout_corporation(amount, entity)
            @game.bank.spend(amount, entity) if amount.positive?

            return unless amount.negative?

            to_pay = -amount
            major = @game.owning_major_corporation(entity)

            if major.cash < to_pay
              difference = to_pay - major.cash

              @game.take_player_loan(major.owner, difference - major.owner.cash) if major.owner.cash < difference
              major.owner.spend(difference, major)
              @log << "#{major.owner.name} subvents #{major.name} with #{@game.format_currency(difference)}"
            end

            major.spend(to_pay, @game.bank)
          end

          def log_run_payout(entity, kind, revenue, _subsidy, action, payout)
            unless Dividend::DIVIDEND_TYPES.include?(kind)
              @log << "#{entity.name} runs for #{@game.format_currency(revenue)} and pays #{action.kind}"
            end

            if payout[:corporation].positive?
              @log << "#{entity.name} withholds #{@game.format_currency(payout[:corporation])}"
            elsif payout[:corporation].negative?
              @log << "#{entity.name} has to pay #{@game.format_currency(-payout[:corporation])}"
            elsif payout[:per_share].zero?
              @log << "#{entity.name} does not run"
            end
          end

          def corp_payout_shares(entity, amount, withhold_value)
            @game.bank.spend(withhold_value, entity, check_positive: false)

            return if amount.zero?

            per_share = payout_per_share(entity, amount)

            payouts = {}
            @game.players.each do |payee|
              corp_payout_entity(entity, payee, per_share, payouts)
            end

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
            @game.bank.spend(amount, receiver, check_positive: false)
          end

          def corp_dividend_options(entity, amount = 0)
            dividend_types.to_h do |type|
              payout = send(type, entity, amount)
              [type, payout.merge(share_price_change(entity, amount))]
            end
          end

          def share_price_change(entity, revenue = 0)
            return {} if entity.minor?

            return { share_direction: :left, share_times: 1 } if revenue.zero?

            times = 0
            times = 1 if revenue >= 100 && revenue <= 190
            times = 2 if revenue >= 200 && revenue <= 390
            times = 3 if revenue >= 400 && revenue <= 590
            times = 4 if revenue >= 600 && revenue <= 990
            times = 5 if revenue >= 1000 && revenue <= 1490
            times = 6 if revenue >= 1500 && revenue <= 2490
            times = 7 if revenue >= 2500
            if times.positive?
              { share_direction: :right, share_times: times }
            else
              {}
            end
          end

          def variable(entity, amount)
            { corporation: 0, per_share: payout_per_share(entity, amount) }
          end

          def min_increment
            10
          end

          def variable_max(entity)
            @game.major_revenue(entity)
          end

          def help_str(max)
            "Choose dividend paid to shareholders out of revenue, between #{@game.format_currency(0)} "\
              "and #{@game.format_currency(max)}. Excess revenue is paid to corporation treasury."
          end

          def chart
            @game.price_movement_chart
          end

          def variable_input_step
            10
          end
        end
      end
    end
  end
end
