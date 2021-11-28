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
            return [] if entity.corporation? && entity.receivership?
            return %w[sell_shares sell_company] if entity == current_entity&.owner # for EMR action
            return [] if entity != current_entity

            if must_buy_power?(entity)
              actions = %w[buy_power]
              if ebuy_president_can_contribute?(entity)
                actions << 'sell_shares'
                actions << 'sell_company' if sellable_companies(entity.owner).any?
              end
              return actions
            end
            return %w[buy_power pass] if can_buy_power?(entity)

            []
          end

          def round_state
            super.merge(
              {
                emergency_buy: false,
              }
            )
          end

          def setup
            @round.emergency_buy = false
          end

          # go to EMR if pres has done normal buy, or if normal buy isn't possible
          def must_buy_power?(entity)
            @round.emergency_buy ||
              (@game.must_buy_power?(entity) && entity.cash < @game.current_power_cost)
          end

          def description
            if must_buy_power?(current_entity)
              'Emergency Buy Train Power'
            else
              'Buy Train Power'
            end
          end

          def pass_description
            if @game.must_buy_power?(current_entity)
              'Skip (to Forced Power Purchase)'
            else
              'Skip (Power)'
            end
          end

          def skip!
            entity = current_entity
            return super if !entity.corporation? || !entity.receivership?

            if entity.cash > @game.current_power_cost &&
                @game.current_corporation_power(entity) < @game.class::MAX_TRAIN
              quantity = (entity.cash / @game.current_power_cost).to_i
              new_power = [@game.class::MAX_TRAIN, (@game.current_corporation_power(entity) + quantity)].min
              delta = new_power - @game.current_corporation_power(entity)
              cost = delta * @game.current_power_cost

              @log << "#{entity.name} (in receivership) buys #{delta} power for #{@game.format_currency(cost)}"
              @game.buy_power(entity, delta, cost, ebuy: true)
            else
              @log << "#{entity.name} (in receivership) skips buying power"
            end
            pass!
          end

          def sellable_companies(entity)
            return [] unless @game.turn > 1
            return [] unless entity.player?

            entity.companies
          end

          def sellable_bundle?(bundle)
            seller = bundle.owner

            corporation = bundle.corporation

            return true unless corporation.president?(seller)
            return true unless president_swap_concern?(corporation)

            !causes_president_swap?(corporation, bundle)
          end

          def causes_president_swap?(corporation, bundle)
            seller = bundle.owner
            share_holders = corporation.player_share_holders
            remaining = share_holders[seller] - bundle.percent
            next_highest = share_holders.reject { |k, _| k == seller }.values.max || 0
            remaining < next_highest || remaining < 20
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

            raise GameError, 'Must buy exactly minimum required power during emergency buy' if ebuy_power_needed(entity) != delta

            return unless ebuy_cash_needed(entity) > entity.cash + entity.owner.cash

            raise GameError, 'Not enough funds raised for emergency buy'
          end

          def process_pass(action)
            if @game.must_buy_power?(action.entity)
              @log << "#{action.entity.name} passes Buy Train Power, entering Emergency Buy"
              @round.emergency_buy = true
              return
            end

            log_pass(action.entity)
            pass!
          end

          def process_buy_power(action)
            delta = action.power
            entity = action.entity

            check_spend(entity, delta)
            cost = cash_needed(entity, delta)
            ebuy = false

            raise GameError, 'Power purchased is too large' if delta > @game.class::MAX_TRAIN
            raise GameError, 'Power purchased is too small' unless delta.positive?

            emergency = ''
            if must_buy_power?(entity)
              # emergency buy
              ebuy = true
              cost = ebuy_cash_needed(entity)
              remaining = cost - entity.cash
              if remaining.positive?
                player = entity.owner
                player.spend(remaining, entity)
                @log << "#{player.name} contributes #{@game.format_currency(remaining)}"
              end
              emergency = 'emergency '
            end

            @log << "#{entity.name} #{emergency}buys #{delta} power for #{@game.format_currency(cost)}"

            @game.buy_power(entity, delta, cost, ebuy: ebuy)

            if @game.must_buy_power?(action.entity)
              @log << "Insufficient power purchased. #{action.entity.name} enters EMR"
              raise GameError, 'Emergency Buy already true' if @round.emergency_buy

              @round.emergency_buy = true
              return
            end

            pass!
          end

          def process_sell_company(action)
            company = action.company
            player = action.entity
            price = action.price
            raise GameError, "#{player.name} doesn't own #{company.name}" if player != company.owner

            company.owner = @game.bank
            player.companies.delete(company)
            @game.bank.spend(price, player) if price.positive?
            @log << "#{player.name} sells #{company.name} to bank for #{@game.format_currency(price)}"
          end

          # So I don't have to create a new IssueShares view...
          def must_buy_train?(entity)
            must_buy_power?(entity)
          end

          def president_may_contribute?(_entity)
            false
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

          # ebuy doesn't affect progress track, but is twice as expensive and has a different target power
          def ebuy_cash_needed(corporation)
            return 0 unless @game.corporation_power[corporation] < @game.min_ebuy_power

            diff = @game.min_ebuy_power - @game.corporation_power[corporation]
            diff * @game.class::POWER_COST[@game.phase.name] * 1.5
          end

          def ebuy_power_needed(corporation)
            return 0 unless @game.corporation_power[corporation] < @game.min_ebuy_power

            @game.min_ebuy_power - @game.corporation_power[corporation]
          end

          def cash_needed(_corporation, delta_power)
            if delta_power + @game.power_progress > @game.class::MAX_PROGRESS
              delta_power * @game.class::POWER_COST[@game.next_phase_name]
            else
              delta_power * @game.class::POWER_COST[@game.phase.name]
            end
          end

          def power_minmax(corporation)
            if must_buy_power?(corporation)
              power = ebuy_power_needed(corporation)
              return [power, power]
            end
            min = 1
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

          def needed_cash(_entity)
            ebuy_cash_needed(current_entity)
          end

          def chart(entity)
            lines = []
            lines << %w[Power Cost]
            min_possible = must_buy_power?(entity) ? ebuy_power_needed(entity) : 1
            max_possible = if must_buy_power?(entity)
                             ebuy_power_needed(entity)
                           else
                             @game.class::MAX_TRAIN - @game.current_corporation_power(entity)
                           end

            max_possible.times do |p|
              next unless p + 1 >= min_possible

              if (p + 1) == min_possible && must_buy_power?(entity) &&
                (lines << [(p + 1).to_s, @game.format_currency(ebuy_cash_needed(entity))])
                break
              end

              break if entity.cash < (cash = cash_needed(entity, p + 1))

              note = ''
              note = 'minimum' if (p + 1 + @game.current_corporation_power(entity)) == @game.min_train
              if (p + 1 + @game.power_progress) > @game.class::MAX_PROGRESS && @game.phase.name != '8+'
                note += ', ' if note != ''
                note += "Phase #{@game.phase.upcoming[:name]}"
              end
              note = " (#{note})" if note != ''

              lines << ["#{p + 1}#{note}", @game.format_currency(cash)]
            end
            lines
          end
        end
      end
    end
  end
end
