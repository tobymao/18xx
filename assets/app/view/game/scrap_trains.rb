# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class ScrapTrains < Snabberb::Component
      include Actionable

      def render
        @corporation = @game.round.active_step.current_entity
        step = @game.round.active_step

        scrappable_trains = step.scrappable_trains(@corporation)
        return nil if scrappable_trains.empty?

        div_props = {
          style: {
            display: 'grid',
            grid: 'auto / minmax(0.7rem, auto) 1fr auto auto',
            gap: '0.5rem',
            alignItems: 'center',
          },
        }

        h(:div, [
          h(:h3, 'Trains to Scrap'),
          h(:div, div_props, scrap_trains(scrappable_trains)),
        ])
      end

      def scrap_trains(scrappable_trains)
        step = @game.round.active_step
        scrappable_trains.flat_map do |train|
          scrap = lambda do
            process_action(Engine::Action::ScrapTrain.new(
              @corporation,
              train: train,
            ))
          end

          [h(:div, train.name),
           h('div.nowrap', train.owner.name),
           h('div.right', step.scrap_info(train)),
           h('button.no_margin', { on: { click: scrap } }, step.scrap_button_text(train))]
        end
      end
    end
  end
end
