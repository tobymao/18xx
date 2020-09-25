# frozen_string_literal: true

require_relative '../base'
require_relative '../emergency_money'

module Engine
  module Step
    module G1817
      class CashCrisis < Base
        include EmergencyMoney

        def actions(entity)
          return [] unless entity == current_entity

          ['sell_shares']
        end

        def description
          'Cash Crisis'
        end

        def active?
          active_entities.any?
        end

        def active_entities
          return [] unless @round.cash_crisis_player

          # Rotate players to order starting with the current player
          players = @game.players.rotate(@game.players.index(@round.cash_crisis_player))
          players.select { |p| p.cash.negative? }
        end

        def needed_cash(entity)
          -entity.cash
        end

        def available_cash(_player)
          0
        end
      end
    end
  end
end
