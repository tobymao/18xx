# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class FormCorporation < Snabberb::Component
      include Actionable

      needs :corporation

      def render
        entity = @game.current_entity
        return h(:div, 'Cannot Par') unless @game.can_par?(@corporation, entity)

        step = @game.round.active_step
        prices = step.get_par_prices(entity, @corporation).sort_by(&:price)

        par = lambda do
          process_action(Engine::Action::Par.new(
            @game.current_entity,
            corporation: @corporation,
            share_price: prices.first, # price is not used
          ))
        end

        props = {
          style: {
            padding: '0.2rem 0.2rem',
          },
          on: { click: par },
        }

        text = @game.form_button_text(@corporation)

        h(:div, [h('button', props, text)])
      end
    end
  end
end
