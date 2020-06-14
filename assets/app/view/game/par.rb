# frozen_string_literal: true

module View
  module Game
    class Par < Snabberb::Component
      include Actionable

      needs :corporation

      def render
        style = {
          cursor: 'pointer',
          border: 'solid 1px gainsboro',
          display: 'inline-block',
          padding: '0.5rem',
          margin: '0.5rem 0.5rem 0.5rem 0',
        }

        par_values = @game.stock_market.par_prices.map do |share_price|
          par = lambda do
            process_action(Engine::Action::Par.new(
              @game.current_entity,
              corporation: @corporation,
              share_price: share_price,
            ))
          end

          h(:div, { style: style, on: { click: par } }, @game.format_currency(share_price.price))
        end

        h(:div, [
          h(:div, 'Par Price:'),
          *par_values.reverse,
        ])
      end
    end
  end
end
