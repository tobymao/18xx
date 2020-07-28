# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/undo_and_pass'

module View
  module Game
    class DiscardTrains < Snabberb::Component
      include Actionable

      def render
        block_props = {
          style: {
            display: 'inline-block',
            verticalAlign: 'top',
          },
        }
        overflow = @game.active_step.crowded_corps.map do |corporation|
          trains = corporation.trains.map do |train|
            train_props = {
              style: {
                display: 'inline-block',
                cursor: 'pointer',
                border: 'solid 1px gainsboro',
                padding: '0.5rem',
              },
              on: { click: -> { process_action(Engine::Action::DiscardTrain.new(corporation, train: train)) } },
            }

            h('div.margined', train_props, train.name)
          end

          h(:div, block_props, [
            h(Corporation, corporation: corporation),
            h(:div, trains),
          ])
        end

        h(:div, [
          h(:div, { style: { marginBottom: '1rem', fontWeight: 'bold' } }, 'Discard Trains'),
          *overflow,
        ])
      end
    end
  end
end
