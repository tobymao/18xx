# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/emergency_money'

module Engine
  module Game
    module G18Carolinas
      module Step
        class BuyPower < Engine::Step::Base
          include Engine::Step::EmergencyMoney

          def actions(entity)
            return ['sell_shares'] if entity == current_entity&.owner
            return [] if entity != current_entity
            return %w[sell_shares buy_power] if president_may_contribute?(entity)
            return %w[buy_power pass] if can_buy_power?(entity)

            []
          end

          def description
            'Buy Train Power'
          end

          def pass_description
            'Skip (Power)'
          end

          def can_buy_power?(entity)
            return false unless @game.corporation_power[entity] < @game.class::MAX_TRAIN

            entity.cash >= if @game.power_progress < @game.class::MAX_PROGRESS
                             @game.current_power_cost
                           else
                             @game.next_power_cost
                           end
          end

          def min_train
            @game.min_train
          end

          def check_spend(entity, delta)
            unless must_buy_power?(entity)
              raise GameError, 'Power too large' if delta > power_minmax(entity).last
              raise GameError, 'Cannot afford power' if cash_needed(entity, delta) > entity.cash

              return
            end

            return unless cash_needed(entity, delta) > entity.cash

            if ebuy_power_needed(entity) != delta
              raise GameError, 'Must buy exactly minimum required power during emergency buy'
            end

            return unless ebuy_cash_needed(entity) > entity.cash + entity.owner.cash

            raise GameError, 'Not enough funds raised for emergency buy'
          end

          def process_buy_power(action)
            delta = action.power
            entity = action.entity

            check_spend(entity, delta)
            cost = cash_needed(entity, delta)
            ebuy = false

            raise GameError, 'Power purchased is too large' if delta > @game.class::MAX_TRAIN
            raise GameError, 'Power purchased is too small' unless delta.positive?

            if must_buy_power?(entity) && cost > entity.cash
              # emergency buy
              ebuy = true
              cost = ebuy_cash_needed(entity) - entity.cash
              remaining = cost - entity.cash
              player = entity.owner
              player.spend(remaining, entity)
              @log << "#{player.name} contributes #{@game.format_currency(remaining)}"
            end

            @log << "#{entity.name} buys #{delta} power for #{@game.format_currency(cost)}"

            @game.buy_power(entity, delta, cost, ebuy: ebuy)

            pass!
          end

          def must_buy_power?(entity)
            @game.must_buy_power?(entity)
          end

          # So I don't have to create a new IssueShares view...
          def must_buy_train?(entity)
            must_buy_power?(entity)
          end

          def president_may_contribute?(entity)
            must_buy_power?(entity)
          end

          def ebuy_president_can_contribute?(corporation)
            corporation.cash < min_cash_needed(corporation)
          end

          def can_ebuy_sell_shares?(_entity)
            @game.class::EBUY_CAN_SELL_SHARES
          end

          def min_cash_needed(corporation)
            return 0 unless @game.must_buy_power?(corporation)

            diff = @game.min_train - @game.current_corporation_power(corporation)
            if diff + @game.power_progress > @game.class::MAX_PROGRESS
              (@game.class::MIN_TRAIN[@game.next_phase_name] -
               (@game.current_corporation_power(corporation) / 3).to_i) * @game.next_power_cost
            else
              diff * @game.current_power_cost
            end
          end

          def min_power_needed(corporation)
            return 0 unless @game.must_buy_power?(corporation)

            diff = @game.min_train - @game.current_corporation_power(corporation)
            if diff + @game.power_progress > @game.class::MAX_PROGRESS
              diff = @game.class::MIN_TRAIN[@game.next_phase_name] -
                (@game.current_corporation_power(corporation) / 3).to_i
            end
            diff
          end

          # ebuy doesn't affect progress track, but is twice as expensive
          def ebuy_cash_needed(corporation)
            return 0 unless @game.corporation_power[corporation] < @game.class::MIN_TRAIN[@game.phase.name]

            diff = @game.min_train - @game.corporation_power[corporation]
            diff * @game.class::POWER_COST[@game.phase.name] * 2
          end

          def ebuy_power_needed(corporation)
            return 0 unless @game.corporation_power[corporation] < @game.class::MIN_TRAIN[@game.phase.name]

            @game.min_train - @game.corporation_power[corporation]
          end

          def cash_needed(_corporation, delta_power)
            if delta_power + @game.power_progress > @game.class::MAX_PROGRESS
              delta_power * @game.class::POWER_COST[@game.next_phase_name]
            else
              delta_power * @game.class::POWER_COST[@game.phase.name]
            end
          end

          def power_minmax(corporation)
            min = [min_power_needed(corporation), 1].max
            max = min
            max_possible = @game.class::MAX_TRAIN - @game.current_corporation_power(corporation)
            max_possible.times do |p|
              break unless corporation.cash >= cash_needed(corporation, p + 1)

              max = [max, p + 1].max
            end
            [min, max]
          end

          def available_cash(entity)
            return current_entity.cash if entity == current_entity

            entity.cash + current_entity.cash
          end

          def needed_cash(entity)
            ebuy_cash_needed(entity)
          end

          def chart(entity)
            lines = []
            lines << %w[Power Cost]
            if @game.must_buy_power?(entity)
              lines << [min_power_needed(entity), @game.format_currency(min_cash_needed(entity))]
            else
              max_possible = @game.class::MAX_TRAIN - @game.current_corporation_power(entity)
              max_possible.times do |p|
                break unless entity.cash >= (cash = cash_needed(entity, p + 1))

                lines << [p + 1, @game.format_currency(cash)]
              end
            end
            lines
          end
        end
      end
    end
  end
end
