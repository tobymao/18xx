# frozen_string_literal: true

require_relative '../special_buy'

module Engine
  module Step
    module G18SJ
      class SpecialBuy < SpecialBuy
        def buyable_items(entity)
          bonus_available?(entity) && @game.round.active_step.respond_to?(:process_run_routes) ? [@gkb_bonus_item] : []
        end

        def short_description
          "Activate bonus each time a #{@game.gkb.name} icon is visited"
        end

        def process_special_buy(action)
          item = action.item
          @game.game_error("Cannot buy unknown item: #{item.description}") unless item == @gkb_bonus_item

          ability = @game.abilities(@game.gkb, :base)
          bonus = @game.format_currency(@game.buy_gkb_bonus(ability.count))
          ability.use!
          @gkb_bonus_bought = true
          @log << "#{action.entity.name} activates bonus #{bonus} per #{@game.gkb.name} icon visit for this OR"
        end

        def setup
          super
          @gkb_bonus_item ||= Item.new(description: 'GKB bonus', cost: 0)
          @gkb_bonus_bought = false
        end

        private

        def bonus_available?(entity)
          return false if entity != gkb_owner || !@game.gkb

          !@gkb_bonus_bought &&
          !@game.gkb.closed? &&
          @game.abilities(@game.gkb, :base)
        end

        def gkb_owner
          @gkb_owner ||= @game.gkb&.owner
        end
      end
    end
  end
end
