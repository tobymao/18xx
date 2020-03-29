# frozen_string_literal: true

require 'view/actionable'
require 'view/corporation'
require 'view/sell_shares'

require 'engine/action/buy_train'

module View
  class BuyTrains < Snabberb::Component
    include Actionable

    def render
      round = @game.round
      @corporation = round.current_entity
      @depot = round.depot

      available = @depot.available(@corporation).group_by(&:owner)
      depot_trains = available.delete(@depot)
      other_corp_trains = available.sort_by { |c, _| c.owner == @corporation.owner ? 0 : 1 }
      children = []

      children << h(:div, [
        h(:div, 'Available Trains'),
        *from_depot(depot_trains),
        *other_trains(other_corp_trains),
      ])

      if round.must_buy_train?
        player = @corporation.owner

        if @corporation.cash + player.cash < @depot.min_price
          player.shares_by_corporation.each do |corporation, shares|
            next if shares.empty?

            children << h(Corporation, corporation: corporation)
          end
          children << h(SellShares, player: @corporation.owner)
        end
      else
        children << h(PassButton)
      end

      children << h(:div, [h(:div, 'Remaining Trains'), *remaining_trains])

      h(:div, {}, children)
    end

    def from_depot(depot_trains)
      depot_trains.map do |train|
        buy_train = -> { process_action(Engine::Action::BuyTrain.new(@corporation, train, train.price)) }

        h(:div, [
          "Train #{train.name} - $#{train.price}",
          h(:button, { on: { click: buy_train } }, 'Buy'),
        ])
      end
    end

    def other_trains(other_corp_trains)
      other_corp_trains.flat_map do |other, trains|
        input = h(
          :input,
          attrs: {
            type: 'number',
            min: 1,
            max: @corporation.cash,
            value: 1,
          },
        )

        trains.map do |train|
          buy_train = lambda do
            price = input.JS['elm'].JS['value'].to_i
            process_action(Engine::Action::BuyTrain.new(@corporation, train, price))
          end

          h(:div, [
            "Train #{train.name} - from #{other.name}",
            input,
            h(:button, { on: { click: buy_train } }, 'Buy'),
          ])
        end
      end
    end

    def remaining_trains
      @depot.upcoming.group_by(&:name).map do |name, trains|
        train = trains.first
        h(:div, "Train: #{name} - $#{train.price} x #{trains.size}")
      end
    end
  end
end
