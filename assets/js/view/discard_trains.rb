# frozen_string_literal: true

require 'view/actionable'

module View
  class DiscardTrains < Snabberb::Component
    include Actionable

    needs :corporations

    def render
      overflow = @corporations.map do |corporation|
        trains = corporation.trains.map do |train|
          train_props = {
            style: {
              display: 'inline-block',
              cursor: 'pointer',
              border: 'solid 1px gainsboro',
              'margin-left': '1rem',
              'padding': '0.5rem',
            },
            on: { click: -> { process_action(Engine::Action::DiscardTrain.new(corporation, train)) } },
          }

          h(:div, train_props, train.name)
        end

        h(:div, [
          corporation.name,
          *trains,
        ])
      end

      h(:div, [
        'Discard Trains',
        *overflow,
      ])
    end
  end
end
