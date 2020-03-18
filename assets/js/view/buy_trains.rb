# frozen_string_literal: true

require 'view/actionable'

require 'engine/action/buy_train'

module View
  class BuyTrains < Snabberb::Component
    include Actionable

    def render
      round = @game.round
      corporation = round.current_entity
      depot = round.depot

      available = depot.available(corporation).group_by(&:owner)

      from_depot = available.delete(depot).map do |train|
        buy_train = -> { process_action(Engine::Action::BuyTrain.new(corporation, train, train.price)) }

        h(:div, [
          "Train #{train.name} - $#{train.price}",
          h(:button, { on: { click: buy_train } }, 'Buy'),
        ])
      end

      corporations = available.sort_by { |c, _| c.owner == corporation.owner ? 0 : 1 }

      others = corporations.flat_map do |other, trains|
        trains.map do |train|
          input = h(
            :input,
            attrs: {
              type: 'number',
              min: 1,
              max: corporation.cash,
              value: 1,
            },
          )

          buy_train = lambda do
            price = input.JS['elm'].JS['value'].to_i
            process_action(Engine::Action::BuyTrain.new(corporation, train, price))
          end

          h(:div, [
            "Train #{train.name} - from #{other.name}",
            input,
            h(:button, { on: { click: buy_train } }, 'Buy'),
          ])
        end
      end

      children = []

      children << h(:div, [h(:div, 'Available Trains'), *from_depot])
      children.concat(others)

      remaining = depot.upcoming.group_by(&:name).map do |name, trains|
        train = trains.first
        h(:div, "Train: #{name} - $#{train.price} x #{trains.size}")
      end

      children << h(PassButton) unless round.must_buy_train?

      children << h(:div, [h(:div, 'Remaining Trains'), *remaining])

      h(:div, {}, children)
    end
  end
end
