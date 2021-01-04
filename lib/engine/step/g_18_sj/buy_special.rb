# frozen_string_literal: true

require_relative '../buy_special'

module Engine
  module Step
    module G18SJ
      class BuySpecial < BuySpecial
        def can_buy_special?(entity)
          bonus_available?(entity) && @game.round.active_step.respond_to?(:process_run_routes)
        end

        def short_description
          "Activate bonus each time a #{@game.gkb.name} icon is visited"
        end

        def process_buy_special(action)
          item = action.item
          @game.game_error("Cannot buy unknown item: #{item.description}") if item != @items.first

          ability = @game.abilities(@game.gkb, :base)
          bonus = @game.format_currency(@game.buy_gkb_bonus(ability.count))
          ability.use!
          @gkb_bonus_bought = true
          @log << "#{action.entity.name} activates bonus #{bonus} per #{@game.gkb.name} icon visit for this OR"
        end

        def setup
          super
          @items << Item.new(description: 'GKB bonus', cost: 0)
          @gkb_bonus_bought = false
        end

        private

        def bonus_available?(entity)
          return false unless entity == gkb_owner

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
