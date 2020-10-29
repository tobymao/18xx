# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class Par < Snabberb::Component
      include Actionable

      needs :corporation

      def render
        entity = @game.current_entity
        return h(:div, 'Cannot Par') unless @corporation.can_par?(entity)

        prices = @game.round.active_step
          .get_par_prices(entity, @corporation)
          .sort_by(&:price)

        par_buttons = prices.map do |share_price|
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
              padding: '0.2rem',
            },
            on: { click: par },
          }
          purchasable_shares = (entity.cash / share_price.price).to_i
          text = "#{@game.format_currency(share_price.price)} (#{purchasable_shares})"
          h('button.small.par_price', props, text)
        end

        div_class = par_buttons.size < 5 ? '.inline' : ''
        h(:div, [
          h("div#{div_class}", { style: { marginTop: '0.5rem' } }, 'Par Price: '),
          *par_buttons,
        ])
      end
    end
  end
end
