# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    module Round
      class BuyToken < Snabberb::Component
        include Actionable
        needs :entity
        needs :selected_token, default: nil, store: true

        def render
          step = @game.active_step
          max_price = step.max_price(@entity)

          children = []

          children << h(:h3, 'Select token on map to purchase')

          corp_name = '<select token>'
          hexid = '<select token>'
          corp_name = @selected_token.corporation.name if @selected_token
          hexid = @selected_token.city.hex.id if @selected_token

          other_owner = nil
          if @selected_token && (real_owner(@entity) != real_owner(@selected_token.corporation))
            other_owner = real_owner(@selected_token.corporation)
          end

          children << h(:table, [
            h(:tbody, [
              h(:tr, [
                h(:td, ['Corporation:']),
                h(:td, [corp_name]),
              ]),
              h(:tr, [
                h(:td, ['Hex:']),
                h(:td, [hexid]),
              ]),
            ]),
          ])

          price_input = h(:input, style: { marginRight: '1rem' }, props: {
                            value: 1,
                            step: 1,
                            min: 1,
                            max: max_price,
                            type: 'number',
                            size: max_price.to_s.size,
                          })

          button_click = lambda do
            city = @selected_token.city
            slot = city.tokens.index(@selected_token)
            price = Native(price_input)[:elm][:value].to_i
            buy_token = lambda do
              process_action(Engine::Action::BuyToken.new(
                @entity,
                city: city,
                slot: slot,
                price: price,
              ))
            end

            if other_owner
              check_consent(@entity, other_owner, buy_token)
            else
              buy_token.call
            end
          end

          button_props = {
            attrs: {
              disabled: !@selected_token,
              type: :button,
            },
            on: { click: button_click },
          }
          buy_button = h(:button, button_props, 'Buy Token')

          children << h('div.center', ['Price: ', price_input, buy_button])

          children << h(:h3, 'WARNING! token owned by a different player. Ask for permission to purchase.') if other_owner

          h(:div, children)
        end

        def real_owner(corp)
          @step.respond_to?(:real_owner) ? @step.real_owner(corp) : corp.owner
        end
      end
    end
  end
end
