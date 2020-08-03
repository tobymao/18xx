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
          next unless share_price.price * 2 <= @game.current_entity.cash

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

        div_class = par_values.size < 5 ? '.inline' : ''
        h(:div, [
          h("div#{div_class}", { style: { marginTop: '0.5rem' } }, 'Par Price: '),
          *par_values.reverse,
        ]) unless par_values.empty?
      end
    end
  end
end
