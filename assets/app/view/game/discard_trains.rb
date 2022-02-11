# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class DiscardTrains < Snabberb::Component
      include Actionable

      def current_entity_actions
        @current_entity_actions ||= @game.round.actions_for(@game.round.active_step&.current_entity) || []
      end

      def render
        block_props = {
          style: {
            display: 'inline-block',
            verticalAlign: 'top',
          },
        }
        step = @game.active_step
        overflow = step.crowded_corps.map do |corporation|
          trains = step.trains(corporation).map do |train|
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
        overflow << h(ScrapTrains, corporation: @current_entity) if current_entity_actions.include?('discard_train')
        overflow << h(Map, game: @game) if @game.round.is_a?(Engine::Round::Operating)

        h(:div, [
          h(:h3, 'Discard Trains'),
          *overflow,
        ])
      end
    end
  end
end
