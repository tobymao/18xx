# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G1822
      module Step
        class Dividend < Engine::Step::Dividend
          DIVIDEND_TYPES = %i[payout half withhold].freeze

          def actions(entity)
            return [] if !entity.corporation? || (entity.corporation? && entity.type != :major)

            @extra_train_choice ||= ''
            actions = super.dup
            actions << 'choose' if @extra_train_choice.empty? && find_extra_train(entity) && entity.trains.size > 1
            actions
          end

          def choice_name
            train = find_extra_train(current_entity)
            return '' unless train

            route = routes.find { |r| r.train == train }
            "Choose #{train.name}'s dividend (#{@game.format_currency(route.revenue)}) if "\
              'this is to be different from the other trains'
          end

          def choices
            choices = {}
            choices['payout'] = 'Pay out'
            choices['half'] = 'Half Pay'
            choices['withhold'] = 'Withhold'
            choices
          end

          def dividend_options(entity)
            total_revenue = @game.routes_revenue(routes)
            extra_train = defined?(@extra_train_choice) && !@extra_train_choice.empty?
            if extra_train
              train = find_extra_train(entity)
              extra_train_revenue = routes.find { |r| r.train == train }.revenue
              extra_train_payout = send(@extra_train_choice, entity, extra_train_revenue, 0)
              revenue = total_revenue - extra_train_revenue
            else
              revenue = total_revenue
            end
            subsidy = @game.routes_subsidy(routes)
            total_revenue += subsidy
            dividend_types.to_h do |type|
              payout = send(type, entity, revenue, subsidy)
              if extra_train
                payout[:corporation] += extra_train_payout[:corporation]
                payout[:per_share] += extra_train_payout[:per_share]
              end
              payout[:divs_to_corporation] = corporation_dividends(entity, payout[:per_share])
              [type, payout.merge(share_price_change(entity, total_revenue - payout[:corporation]))]
            end
          end

          def find_extra_train(entity)
            train = entity.trains.find { |t| @game.extra_train_permanent?(t) }
            return nil unless train

            revenue = routes.find { |r| r.train == train }&.revenue || 0
            revenue.positive? && revenue != @game.routes_revenue(routes) ? train : nil
          end

          def half(entity, revenue, subsidy)
            withheld = half_pay_withhold_amount(entity, revenue)
            { corporation: withheld + subsidy, per_share: payout_per_share(entity, revenue - withheld) }
          end

          def half_pay_withhold_amount(entity, revenue)
            entity.type == :minor ? revenue / 2.0 : (revenue / 2 / entity.total_shares).to_i * entity.total_shares
          end

          def holder_for_corporation(entity)
            entity
          end

          def log_run_payout(entity, kind, revenue, subsidy, _action, payout)
            @log << "#{entity.name} runs for #{@game.format_currency(revenue)} and pays half" if kind == 'half'

            withhold = payout[:corporation] - subsidy
            if withhold.positive?
              @log << "#{entity.name} withholds #{@game.format_currency(withhold)}"
            elsif payout[:per_share].zero?
              @log << "#{entity.name} does not run"
            end
            @log << "#{entity.name} earns subsidy of #{@game.format_currency(subsidy)}" if subsidy.positive?
          end

          def payout(entity, revenue, subsidy)
            { corporation: subsidy, per_share: payout_per_share(entity, revenue) }
          end

          def payout_shares(entity, revenue)
            super

            per_share = payout_per_share(entity, revenue)
            @game.company_tax_haven_payout(entity, per_share)
          end

          def process_choose(action)
            entity = action.entity
            @extra_train_choice = action.choice
            text =
              case @extra_train_choice
              when 'payout'
                'pay out'
              when 'withhold'
                'withhold'
              when 'half'
                'half pay'
              else
                raise GameError, "#{action.choice} is an illegal choice"
              end
            @log << "#{current_entity.id} chooses to #{text} with the #{find_extra_train(entity).name} train"
          end

          def process_dividend(action)
            entity = action.entity
            revenue = @game.routes_revenue(routes)
            subsidy = @game.routes_subsidy(routes)
            kind = action.kind.to_sym
            payout = dividend_options(entity)[kind]

            entity.operating_history[[@game.turn, @round.round_num]] = OperatingInfo.new(
              routes,
              action,
              revenue,
              @round.laid_hexes
            )

            entity.trains.each { |train| train.operated = true }

            @round.routes = []
            log_run_payout(entity, kind, revenue, subsidy, action, payout)
            @game.bank.spend(payout[:corporation], entity) if payout[:corporation].positive?
            payout_shares(entity, revenue + subsidy - payout[:corporation]) if payout[:per_share].positive?
            change_share_price(entity, payout)

            pass!

            @extra_train_choice = ''
          end

          def skip!
            return super if current_entity.type == :major

            revenue = @game.routes_revenue(routes)
            process_dividend(Action::Dividend.new(
              current_entity,
              kind: revenue.positive? ? 'half' : 'withhold',
            ))
          end

          def share_price_change(entity, revenue = 0)
            return { share_direction: :left, share_times: 1 } unless revenue.positive?

            price = entity.share_price.price
            times = 0
            times = 1 if revenue >= price || entity.type == :minor
            times = 2 if revenue >= price * 2 && entity.type == :major
            if times.positive?
              { share_direction: :right, share_times: times }
            else
              {}
            end
          end

          def withhold(_entity, revenue, subsidy)
            { corporation: revenue + subsidy, per_share: 0 }
          end
        end
      end
    end
  end
end
