# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class Offer < Snabberb::Component
      include Actionable

      needs :player
      needs :corporations, default: []
      needs :company
      needs :selected_corp, default: nil, store: true

      def render
        @step = @game.round.active_step

        offer_click = lambda do
          corp_name = Native(@corp_dropdown).elm.value
          corp = @game.corporation_by_id(corp_name)
          price = @step.fixed_price(corp, @company) || @price_input.JS['elm'].JS['value'].to_i
          process_action(Engine::Action::Offer.new(
            @player,
            corporation: corp,
            company: @company,
            price: price,
          ))
        end

        corp_change = lambda do
          store(:selected_corp, @game.corporation_by_id(Native(@corp_dropdown).elm.value))
        end

        dropdown_props = {
          style: {
            height: '1.3rem',
            width: '4rem',
            padding: '0 0 0 0.2rem',
          },
          on: {
            input: corp_change,
          },
        }
        corp_options = @corporations.map do |corp|
          h(:option, { attrs: { value: corp.name } }, corp.name)
        end
        @corp_dropdown = h('select', dropdown_props, corp_options)

        corporation = @selected_corp || @corporations[0]
        @price_input = if (price = @step.fixed_price(corporation, @company))
                         " #{@game.format_currency(price)} "
                       else
                         h(
                           'input.no_margin',
                           style: {
                             height: '1.2rem',
                             width: '3rem',
                             padding: '0 0 0 0.2rem',
                           },
                           attrs: price_range(corporation, @company)
                         )
                       end

        h(:div, [
          'Corp:',
          @corp_dropdown,
          'Price:',
          @price_input,
          h('button.no_margin', { on: { click: offer_click } }, 'Offer'),
        ])
      end

      def price_range(corporation, company)
        min, max = @step.price_minmax(corporation, company)
        {
          type: 'number',
          min: min,
          max: max,
          value: min,
          size: max.to_s.size + 2,
        }
      end
    end
  end
end
