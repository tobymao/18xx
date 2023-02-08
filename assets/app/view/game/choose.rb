# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class Choose < Snabberb::Component
      include Actionable

      needs :entity, default: nil

      def render
        choices = if @game.round.active_step.respond_to?(:entity_choices)
                    @game.round.active_step.entity_choices(@entity)
                  else
                    @game.round.active_step.choices
                  end

        choice_is_amount = if @game.round.active_step.respond_to?(:choice_is_amount?)
                             @game.round.active_step.choice_is_amount?
                           else
                             false
                           end

        return render_choice_amount(choices) if choice_is_amount

        choice_buttons = choices.map do |choice, label|
          label ||= choice
          click = lambda do
            process_action(Engine::Action::Choose.new(
              @game.current_entity,
              choice: choice,
            ))
          end

          props = {
            style: {
              padding: '0.2rem 0.2rem',
            },
            on: { click: click },
          }
          h('button', props, label)
        end

        div_class = choice_buttons.size < 5 ? '.inline' : ''
        h(:div, [
          h("div#{div_class}", { style: { marginTop: '0.5rem' } }, "#{@game.round.active_step.choice_name}: "),
          h(:div, choice_buttons),
        ])
      end

      def render_choice_amount(amounts)
        min, max = amounts

        input = h('input.no_margin',
                  style: {
                    height: '1.6rem',
                    width: '4rem',
                    padding: '0 0 0 0.2rem',
                  },
                  attrs: {
                    type: 'number',
                    min: min,
                    max: max,
                    value: min,
                    size: max.to_s.size + 2,
                  })

        click = lambda do
          amount = input.JS['elm'].JS['value'].to_i
          process_action(Engine::Action::Choose.new(
                           @game.current_entity,
                           choice: amount
                         ))
        end

        h(:div,
          [
            h('div.inline',
              { style: { marginTop: '0.5rem' } },
              [
                h('span', "#{@game.round.active_step.choice_name}: "),
                input,
                h('button', { style: { padding: '0.2rem 0.2rem' }, on: { click: click } }, 'Transfer'),
              ]),
          ])
      end
    end
  end
end
