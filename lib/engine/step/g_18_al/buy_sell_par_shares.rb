# frozen_string_literal: true

require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G18AL
      class BuySellParShares < BuySellParShares
        def setup
          super
          @controller_at_start = current_controller
        end

        def process_pass(action)
          super
          return if @controller_at_start.nil? || @controller_at_start == current_controller

          @log << "#{route_bonus_ability.owner.name} removes route bonuses as presidency changed"
          president_changed(route_bonus_ability.owner)
          @controller_at_start = nil
        end

        private

        def current_controller
          route_bonus_ability&.player
        end

        def route_bonus_ability
          @game.corporations.each do |corporation|
            corporation.abilities(@game.route_bonuses.first) do |ability|
              return ability
            end
          end

          nil
        end

        def president_changed(corporation)
          @game.route_bonuses.each do |type|
            corporation.abilities(type) do |ability|
              corporation.remove_ability(ability)
            end
          end
        end
      end
    end
  end
end
