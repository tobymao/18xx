# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class ScrapTrains < Snabberb::Component
      include Actionable
      needs :corporation, default: nil

      def render
        @corporation ||= @game.round.active_step.current_entity
        step = @game.round.step_for(@corporation, 'scrap_train')

        scrappable_trains = step.scrappable_trains(@corporation)
        return nil if scrappable_trains.empty?

        if step.respond_to?(:scrap_trains_button_only?) && step.scrap_trains_button_only?
          render_buttons(scrappable_trains)
        else
          render_section(scrappable_trains)
        end
      end

      def render_buttons(scrappable_trains)
        h(:div, generate_scrap_train_actions(scrappable_trains) do |scrap, train, step|
          h(:button, { on: { click: scrap } }, step.scrap_info(train))
        end)
      end

      def render_section(scrappable_trains)
        div_props = {
          style: {
            display: 'grid',
            grid: 'auto / minmax(0.7rem, auto) 1fr auto auto',
            gap: '0.5rem',
            alignItems: 'center',
          },
        }
        h(:div,
          [h(:h3, 'Trains to Scrap'),
           h(:div, div_props, scrap_trains(scrappable_trains))])
      end

      def scrap_trains(scrappable_trains)
        generate_scrap_train_actions(scrappable_trains) do |scrap, train, step|
          [h(:div, train.name),
           h('div.nowrap', train.owner.name),
           h('div.right', step.scrap_info(train)),
           h('button.no_margin', { on: { click: scrap } }, step.scrap_button_text(train))]
        end
      end

      def generate_scrap_train_actions(scrappable_trains)
        step = @game.round.step_for(@corporation, 'scrap_train')
        scrappable_trains.flat_map do |train|
          scrap = lambda do
            process_action(Engine::Action::ScrapTrain.new(
              @corporation,
              train: train,
            ))
          end
          yield(scrap, train, step)
        end
      end
    end
  end
end
