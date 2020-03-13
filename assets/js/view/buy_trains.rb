# frozen_string_literal: true

require 'view/actionable'
require 'view/pass_button'

require 'engine/action/buy_train'

module View
  class BuyTrains < Snabberb::Component
    include Actionable

    def render
      round = @game.round
      depot = round.depot

      available = depot.available.map do |train|
        buy_train = -> { process_action(Engine::Action::BuyTrain.new(round.current_entity, train, train.price)) }

        h(:div, [
          "Train #{train.name} - $#{train.price}",
          h(:button, { on: { click: buy_train } }, 'Buy'),
        ])
      end

      available_chart = h(:div, [
        h(:div, 'Available Trains'),
        *available
      ])

      remaining = depot.upcoming.group_by(&:name).map do |name, trains|
        train = trains.first
        h(:div, "Train: #{name} - $#{train.price} x #{trains.size}")
      end

      remaining_chart = h(:div, [
        h(:div, 'Remaining Trains'),
        *remaining
      ])

      h(:div, {}, [
        available_chart,
        h(PassButton),
        remaining_chart,
      ])
    end
  end
end
