# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G18Mag
      module Step
        class Dividend < Engine::Step::Dividend
          MIN_CORP_PAYOUT = 10
          CORP_TYPES = %i[variable withhold].freeze
          STANDARD_CORP_TYPES = %i[payout withhold].freeze

          def actions(entity)
            return [] if entity.minor?
            return [] if !entity.corporation? || entity.receivership? || entity.cash < MIN_CORP_PAYOUT

            ACTIONS
          end

          def corp_revenue(entity)
            (entity.cash / MIN_CORP_PAYOUT).to_i * MIN_CORP_PAYOUT
          end

          def skip!
            if current_entity.minor?
              revenue = @game.routes_revenue(routes)
              process_dividend(Action::Dividend.new(
                current_entity,
                kind: revenue.positive? ? 'payout' : 'withhold',
              ))
            else
              amount = corp_revenue(current_entity)
              if @game.standard_divs?
                process_dividend(Action::Dividend.new(
                  current_entity,
                  kind: amount.positive? ? 'payout' : 'withhold',
                ))
              else
                process_dividend(Action::Dividend.new(
                  current_entity,
                  kind: 'variable',
                  amount: amount,
                ))
              end
            end
          end

          def process_dividend(action)
            if action.entity.minor?
              subsidy = @game.routes_subsidy(routes)
              if subsidy.positive?
                @game.bank.spend(subsidy, action.entity)
                @log << "#{action.entity.name} retains a subsidy of #{@game.format_currency(subsidy)}"
              end
              return super
            end

            entity = action.entity
            action_kind = action.kind
            case action_kind
            when 'withhold'
              amount = 0
              action_kind = 'variable'
            when 'payout'
              amount = corp_revenue(entity)
              action_kind = 'variable'
            else
              amount = action.amount || 0
            end
            kind = action_kind.to_sym
            payout = corp_dividend_options(entity, amount)[kind]

            raise GameError, "Amount must be multiples of #{MIN_CORP_PAYOUT}" if amount % MIN_CORP_PAYOUT != 0

            entity.operating_history[[@game.turn, @round.round_num]] = OperatingInfo.new(
              routes,
              action,
              amount,
              @round.laid_hexes
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

            @game.standard_divs? ? self.class::STANDARD_CORP_TYPES : self.class::CORP_TYPES
          end

          def dividend_options(entity)
            return super if entity.minor?

            revenue = corp_revenue(entity)
            dividend_types.to_h do |type|
              payout = send(type, entity, revenue)
              payout[:divs_to_corporation] = 0
              [type, payout.merge(share_price_change(entity, revenue - payout[:corporation]))]
            end
          end

          def corp_dividend_options(entity, amount = 0)
            self.class::CORP_TYPES.to_h do |type|
              payout = send(type, entity, amount)
              payout[:divs_to_corporation] = 0
              [type, payout.merge(share_price_change(entity, amount - payout[:corporation]))]
            end
          end

          def withhold(entity, revenue)
            return super if entity.minor? || @game.standard_divs?

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
            elsif revenue <= (@game.multiplayer? ? 20 : 10)
              {}
            elsif revenue <= (@game.multiplayer? ? 50 : 40)
              { share_direction: :right, share_times: 1 }
            elsif revenue <= (@game.multiplayer? ? 100 : 80)
              { share_direction: :right, share_times: 2 }
            elsif revenue <= (@game.multiplayer? ? 200 : 120)
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

          def help_str(max)
            "Select dividend per share to distribute to shareholders, between #{@game.format_currency(0)}"\
              " and #{@game.format_currency(max)}."
          end

          def chart
            @game.price_movement_chart
          end

          def variable_share_multiplier(corporation)
            corporation.total_shares
          end

          def variable_input_step
            1
          end
        end
      end
    end
  end
end
