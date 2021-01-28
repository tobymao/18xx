# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class UpgradeTrains < Snabberb::Component
      include Actionable

      def render
        block_props = {
          style: {
            display: 'inline-block',
            verticalAlign: 'top',
          },
        }
        step = @game.active_step
        corporation = step.buying_entity

        puts step.trains.size
        trains = step.trains.map do |train|
          train_props = {
            style: {
              border: 'solid 1px gainsboro',
              padding: '0.5rem',
              width: 'fit-content',
            },
          }
          h('div.margined', [
              h('span.margined', train_props, train.name),
              h(:button, {
                  on: {
                    click: lambda {
                      process_action(Engine::Action::DiscardTrain.new(corporation, train: train))
                    },
                  },
                }, 'Upgrade'),
              h(:button, {
                  on: {
                    click: lambda {
                      process_action(Engine::Action::DiscardTrain.new(corporation, train: train))
                    },
                  },
                }, 'Discard'),
            ])
        end
        children = []

        children << h(:div, block_props, [
          h(Corporation, corporation: corporation),
          h(:div, trains),
        ])

        children << h(Map, game: @game) if @game.round.is_a?(Engine::Round::Operating)

        h(:div, [
          h(:div, { style: { marginBottom: '1rem', fontWeight: 'bold' } }, 'Keep, Discard or Upgrade Trains'),
          *children,
        ])
      end
    end
  end
end
