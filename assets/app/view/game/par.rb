# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class Par < Snabberb::Component
      include Actionable

      needs :corporation

      def render
        return h(:div, 'Cannot Par') unless @corporation.can_par?(@game.current_entity)

        par_buttons = @game.par_prices_for_entity.map do |share_price|
          par = lambda do
            process_action(Engine::Action::Par.new(
              @game.current_entity,
              corporation: @corporation,
              share_price: share_price,
            ))
          end

          props = {
            style: {
              width: 'calc(17.5rem/6)',
              padding: '0.2rem 0',
            },
            on: { click: par },
          }
          h('button.small.par_price', props, @game.format_currency(share_price.price))
        end.compact

        div_class = par_buttons.size < 5 ? '.inline' : ''
        h(:div, [
          h("div#{div_class}", { style: { marginTop: '0.5rem' } }, 'Par Price: '),
          *par_buttons.reverse,
        ]) unless par_buttons.empty?
      end
    end
  end
end
