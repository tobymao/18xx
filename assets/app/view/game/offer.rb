# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class Offer < Snabberb::Component
      include Actionable

      needs :player
      needs :corporations, default: []
      needs :company

      def render
        @step = @game.round.active_step

        offer_click = lambda do
          corp_name = Native(@corp_dropdown).elm.value
          corp = @game.corporation_by_id(corp_name)
          price = @step.fixed_price(@company) || @price_input.JS['elm'].JS['value'].to_i
          process_action(Engine::Action::Offer.new(
            @player,
            corporation: corp,
            company: @company,
            price: price,
          ))
        end

        dropdown_props = {
          style: {
            height: '1.3rem',
            width: '4rem',
            padding: '0 0 0 0.2rem',
          },
        }
        corp_options = @corporations.map do |corp|
          h(:option, { attrs: { value: corp.name } }, corp.name)
        end
        @corp_dropdown = h('select', dropdown_props, corp_options)

        @price_input = if (price = @step.fixed_price(@company))
                         " #{@game.format_currency(price)} "
                       else
                         h(
                           'input.no_margin',
                           style: {
                             height: '1.2rem',
                             width: '3rem',
                             padding: '0 0 0 0.2rem',
                           },
                           attrs: price_range(@company)
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

      def input
        dropdown_props = {
          style: {
            height: '1.3rem',
            width: '4rem',
            padding: '0 0 0 0.2rem',
          },
        }
        corp_options = @corporations.map do |corp|
          h(:option, { attrs: { value: corp.name } }, corp.name)
        end
        @corp_dropdown = h('select', dropdown_props, corp_options)
        h(:div, [
          'Corp:',
          @corp_dropdown,
          'Price:',
          h(
            'input.no_margin',
            style: {
              height: '1.2rem',
              width: '3rem',
              padding: '0 0 0 0.2rem',
            },
            attrs: price_range(@company)
          ),
        ])
      end

      def price_range(company)
        {
          type: 'number',
          min: company.min_price,
          max: company.max_price,
          value: company.min_price,
          size: company.max_price.to_s.size + 2,
        }
      end
    end
  end
end
