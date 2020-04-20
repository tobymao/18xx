# frozen_string_literal: true

require 'view/actionable'
require 'view/corporation'
require 'view/discard_trains'
require 'view/sell_shares'
require 'view/undo_and_pass'

require 'engine/action/buy_train'
require 'engine/action/sell_shares'

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

      must_buy_train = round.must_buy_train?
      crowded_corps = round.crowded_corps

      children << h(:div, [
        h(UndoAndPass, pass: !must_buy_train && crowded_corps.none?),
      ])

      if (round.can_buy_train? && round.corp_has_room?) || round.must_buy_train?
        children << h(:div, 'Available Trains')
        children.concat(from_depot(depot_trains))
        children.concat(other_trains(other_corp_trains)) unless @game.actions.last.is_a?(SellShares)
      end

      discountable_trains = @depot.discountable_trains_for(@corporation)

      if discountable_trains.any?
        children << h(:div, 'Exchange Trains')

        discountable_trains.each do |train, discount_train, price|
          exchange_train = lambda do
            process_action(
              Engine::Action::BuyTrain.new(
                @corporation,
                discount_train,
                price,
                train,
              )
            )
          end

          children << h(:div, [
            "#{train.name} -> #{discount_train.name} #{@game.format_currency(price)}",
            h(:button, { on: { click: exchange_train } }, 'Exchange'),
          ])
        end
      end

      if must_buy_train
        player = @corporation.owner

        if @corporation.cash + player.cash < @depot.min_depot_price
          player.shares_by_corporation.each do |corporation, shares|
            next if shares.empty?

            children << h(Corporation, corporation: corporation)
          end
          children << h(SellShares, player: @corporation.owner)
        end
      end

      children << h(DiscardTrains, corporations: crowded_corps) if crowded_corps.any?

      children << h(:div, [h(:div, 'Remaining Trains'), *remaining_trains])

      h(:div, {}, children)
    end

    def from_depot(depot_trains)
      depot_trains.map do |train|
        buy_train = -> { process_action(Engine::Action::BuyTrain.new(@corporation, train, train.price)) }

        h(:div, [
          "Train #{train.name} - #{@game.format_currency(train.price)}",
          h(:button, { on: { click: buy_train } }, 'Buy'),
        ])
      end
    end

    def other_trains(other_corp_trains)
      other_corp_trains.flat_map do |other, trains|
        trains.map do |train|
          input = h(
            :input,
            attrs: {
              type: 'number',
              min: 1,
              max: @corporation.cash,
              value: 1,
            },
          )

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
        h(:div, "Train: #{name} - #{@game.format_currency(train.price)} x #{trains.size}")
      end
    end
  end
end
