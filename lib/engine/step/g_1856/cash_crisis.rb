# frozen_string_literal: true

require_relative '../base'
require_relative '../emergency_money'

module Engine
  module Step
    module G1856
      class CashCrisis < Base
        include EmergencyMoney
        # 1856 Has several situations outside of buying trains where
        #  a president is forced to contribute funds (and may even go bankrupt)
        #  so reusing the 1817 CashCrisis makes sense
        def actions(entity)
          return [] unless entity == current_entity

          unless @active_entity
            @active_entity = entity
            @game.log << "#{@active_entity.name} enters Emergency Fundraising and owes"\
            " the bank #{@game.format_currency(needed_cash(@active_entity))}"
          end

          ['sell_shares']
        end

        def description
          'Emergency Fundraising'
        end

        def active?
          active_entities.any?
        end

        def active_entities
          return [] unless @round&.cash_crisis_player&.cash&.negative?

          [@round.cash_crisis_player]
        end

        def needed_cash(entity)
          -entity.cash
        end

        def available_cash(_player)
          0
        end

        def process_sell_shares(action)
          super
          return if action.entity.cash.negative?

          @active_entity = nil
        end

        def sellable_bundle?(bundle)
          player = bundle.owner
          # Can't sell president's share
          return false unless bundle.can_dump?(player)

          # Can't oversaturate the market
          return false unless @game.share_pool.fit_in_bank?(bundle)

          # Can't swap presidency
          corporation = bundle.corporation
          if corporation.president?(player) && (
              @round.cash_crisis_due_to_interest == corporation ||
              corporation == current_entity)
            share_holders = corporation.player_share_holders
            remaining = share_holders[player] - bundle.percent
            next_highest = share_holders.reject { |k, _| k == player }.values.max || 0
            return false if remaining < next_highest
          end

          # Otherwise we're good
          true
        end
        # Use EmergencyMoney can_sell?

        def swap_sell(_player, _corporation, _bundle, _pool_share); end
      end
    end
  end
end
