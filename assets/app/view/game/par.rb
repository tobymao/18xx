# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class Par < Snabberb::Component
      include Actionable

      needs :corporation

      def render
        return h(:div, 'Cannot Par') unless @corporation.can_par?(@game.current_entity)

        par_values = @game.stock_market.par_prices.map do |share_price|
          par = lambda do
            process_action(Engine::Action::Par.new(
              @game.current_entity,
              corporation: @corporation,
              share_price: share_price,
            ))
          end

          props = {
            style: { width: 'calc(17.5rem/6)' },
            on: { click: par },
          }
          h('button.small.par_price', props, @game.format_currency(share_price.price))
        end

        div_class = par_values.size < 5 ? '.inline' : ''
        h(:div, [
          h("div#{div_class}", { style: { marginTop: '0.5rem' } }, 'Par Price: '),
          *par_values.reverse,
        ])
      end
    end
  end
end
