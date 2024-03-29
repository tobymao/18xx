# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/emergency_money'

module Engine
  module Game
    module G1817
      module Step
        class CashCrisis < Engine::Step::Base
          include Engine::Step::EmergencyMoney

          def actions(entity)
            return [] unless entity == current_entity

            if @active_entity.nil?
              @active_entity = entity
              @game.log << "#{@active_entity.name} enters Cash Crisis and owes"\
                           " the bank #{@game.format_currency(needed_cash(@active_entity))}"
            end

            ['sell_shares']
          end

          def description
            'Cash Crisis'
          end

          def cash_crisis?
            true
          end

          def active?
            active_entities.any?
          end

          def active_entities
            return [] unless @round.cash_crisis_player

            # Rotate players to order starting with the current player
            [@game.players.rotate(@game.players.index(@round.cash_crisis_player))
            .find { |p| p.cash.negative? }].compact
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

          def can_sell?(entity, bundle)
            super && !(bundle.corporation.share_price.acquisition? || bundle.corporation.share_price.liquidation?)
          end

          def swap_sell(_player, _corporation, _bundle, _pool_share); end
        end
      end
    end
  end
end
