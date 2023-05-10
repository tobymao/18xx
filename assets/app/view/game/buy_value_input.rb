# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class BuyValueInput < Snabberb::Component
      include Actionable
      needs :value
      needs :min_value
      needs :max_value
      needs :size
      needs :selected_entity

      def render
        @corporation = @game.current_entity

        input = h(:input, style: { marginRight: '1rem' }, props: {
                    value: @value,
                    type: 'number',
                    min: @min_value,
                    max: @max_value,
                    size: @size + 2,
                  })

        buy_click = lambda do
          price = input.JS['elm'].JS['value'].to_i
          buy = lambda do
            if @selected_entity.corporation? || @selected_entity.minor?
              to_merge = if @selected_corporation.corporation?
                           { corporation: @selected_entity }
                         else
                           { minor: @selected_entity }
                         end
              process_action(Engine::Action::BuyCorporation.new(
                @corporation,
                **to_merge,
                price: price,
              ))
              store(:selected_corporation, nil, skip: true)
            else
              process_action(Engine::Action::BuyCompany.new(
                  @corporation,
                  company: @selected_entity,
                  price: price,
                ))
              store(:selected_company, nil, skip: true)
            end
          end

          if @selected_entity.owner == @corporation.owner || !@selected_entity.owner
            buy.call
          else
            check_consent(@corporation, @selected_entity.owner, buy)
          end
        end

        props = {
          style: {
            textAlign: 'center',
            margin: '1rem',
          },
        }

        h(:div, props, [
          input,
          h(:button, { on: { click: buy_click } }, 'Buy'),
        ])
      end
    end
  end
end
