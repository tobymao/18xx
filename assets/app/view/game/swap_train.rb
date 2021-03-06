# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class SwapTrain < Snabberb::Component
      include Actionable

      def render
        @corporation = @game.round.active_step.current_entity

        div_props = {
          style: {
            display: 'grid',
            grid: 'auto / repeat(2, max-content)',
            gap: '0.5rem',
          },
        }

        children = @corporation.shells.flat_map do |shell|
          [h(:h3, "#{shell.name} Shell Trains"),
           h(:div, div_props, shell_trains(shell.trains))]
        end

        props = {
          style: {
            display: 'grid',
            rowGap: '0.5rem',
            marginBottom: '1rem',
          },
        }

        h('div#swap_train', props, children)
      end

      def shell_trains(trains)
        return [h(:div, 'Empty')] if trains.empty?

        trains.flat_map do |train|
          swap_train = -> { process_action(Engine::Action::SwapTrain.new(@corporation, train: train)) }

          [h(:div, train.name),
           h('button.no_margin', { on: { click: swap_train } }, 'Swap')]
        end
      end
    end
  end
end
