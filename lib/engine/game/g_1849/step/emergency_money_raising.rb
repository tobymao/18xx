# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/emergency_money'

module Engine
  module Game
    module G1849
      module Step
        class EmergencyMoneyRaising < Engine::Step::Base
          include Engine::Step::EmergencyMoney

          def actions(entity)
            current = current_entity
            return [] if entity != current && entity != current.owner

            @active_entity = nil if @active_entity != cash_crisis_entity
            if !@active_entity && current == entity
              @active_entity = entity
              @game.log << "#{@active_entity.name} enters #{description} and owes"\
                           " the bank #{@game.format_currency(needed_cash(@active_entity))} in loan interest"
            end

            actions = []
            actions << 'sell_shares' if can_sell_shares?(entity)
            actions << 'payoff_debt' if entity.corporation? || owner_can_payoff_debt?(entity)

            actions
          end

          def description
            'Emergency Money Raising'
          end

          def cash_crisis?
            true
          end

          def active?
            !active_entities.empty?
          end

          def active_entities
            return [] unless cash_crisis_entity&.cash&.negative?

            [cash_crisis_entity]
          end

          def issuable_shares(entity)
            super.select { |bundle| selling_minimum_shares?(bundle) }
          end

          def needed_cash(entity)
            return needed_cash(@active_entity) if @active_entity.corporation? && @active_entity.owner == entity

            -entity.cash
          end

          def can_sell_shares?(entity)
            return issuable_shares(entity).any? if entity.corporation?

            entity.cash < needed_cash(entity)
          end

          def available_cash(entity)
            entity.cash.positive? ? entity.cash : 0
          end

          def owner_can_payoff_debt?(entity)
            @active_entity.corporation? && @active_entity.owner == entity && available_cash(entity) >= needed_cash(@active_entity)
          end

          def process_payoff_debt(action)
            payee = action.entity
            debtor = @active_entity
            amount = needed_cash(debtor)

            payee.spend(amount, debtor)
            @game.log << "#{payee.name} pays off #{debtor.name}'s debt of #{@game.format_currency(amount)}"
            @active_entity = nil
          end

          def process_sell_shares(action)
            super
            return if @active_entity.cash.negative?

            @active_entity = nil
          end

          # needed for bonds variant
          def cash_crisis_entity
            @game.corporations.find { |corp| corp.cash.negative? }
          end
        end
      end
    end
  end
end
