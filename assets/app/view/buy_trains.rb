# frozen_string_literal: true

require 'view/actionable'
require 'view/corporation'
require 'view/sell_shares'
require 'view/undo_and_pass'

module View
  class BuyTrains < Snabberb::Component
    include Actionable
    needs :show_other_players, default: nil, store: true

    def render
      round = @game.round
      @corporation = round.current_entity
      @depot = round.depot

      available = @depot.available(@corporation).group_by(&:owner)
      depot_trains = available.delete(@depot)
      other_corp_trains = available.sort_by { |c, _| c.owner == @corporation.owner ? 0 : 1 }
      children = []

      must_buy_train = round.must_buy_train?

      children << h(:div, [h(UndoAndPass, pass: !must_buy_train)])

      if (round.can_buy_train? && round.corp_has_room?) || round.must_buy_train?
        children << h('div.margined', 'Available Trains')
        children.concat(from_depot(depot_trains))
        children.concat(other_trains(other_corp_trains)) unless @game.actions.last.is_a?(SellShares)
      end

      discountable_trains = @depot.discountable_trains_for(@corporation)

      if discountable_trains.any?
        children << h('div.margined', 'Exchange Trains')

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
            h('button.margined', { on: { click: exchange_train } }, 'Exchange'),
          ])
        end
      end

      if must_buy_train
        player = @corporation.owner

        if @corporation.cash + player.cash < @depot.min_depot_price
          children << render_bankruptcy
          player.shares_by_corporation.each do |corporation, shares|
            next if shares.empty?

            children << h(Corporation, corporation: corporation)
          end
          children << h(SellShares, player: @corporation.owner)
        end
      end

      children << h(:div, [h(:div, 'Remaining Trains'), *remaining_trains])

      h(:div, {}, children)
    end

    def from_depot(depot_trains)
      depot_trains.map do |train|
        buy_train = -> { process_action(Engine::Action::BuyTrain.new(@corporation, train, train.price)) }

        h(:div, [
          "Train #{train.name} - #{@game.format_currency(train.price)} from The Depot",
          h('button', { style: { margin: '1rem' }, on: { click: buy_train } }, 'Buy'),
        ])
      end
    end

    def other_trains(other_corp_trains)
      hidden_trains = false
      trains_to_buy = other_corp_trains.flat_map do |other, trains|
        trains.group_by(&:name).map do |name, group|
          input = h(
            :input,
            style: {
              'margin-left': '1rem',
            },
            attrs: {
              type: 'number',
              min: 1,
              max: @corporation.cash,
              value: 1,
              size: @corporation.cash.to_s.size,
            },
          )

          buy_train = lambda do
            price = input.JS['elm'].JS['value'].to_i
            process_action(Engine::Action::BuyTrain.new(@corporation, group[0], price))
          end

          count = group.size

          if @show_other_players || other.owner == @corporation.owner
            h(:div, [
              "Train #{name} - from #{other.name} (#{other.owner.name})" + (count > 1 ? " (has #{count})" : ''),
              input,
              h('button.margined', { on: { click: buy_train } }, 'Buy'),
            ])
          else
            hidden_trains = true
            nil
          end
        end
      end.compact

      if hidden_trains
        trains_to_buy << h(:div, [
          h('button.margined',
            { on: { click: -> { store(:show_other_players, true) } } },
            'Show trains from other players'),
        ])
      elsif @show_other_players
        trains_to_buy << h(:div, [
          h('button.margined',
            { on: { click: -> { store(:show_other_players, false) } } },
            'Hide trains from other players'),
        ])
      end
      trains_to_buy
    end

    def remaining_trains
      @depot.upcoming.group_by(&:name).map do |name, trains|
        train = trains.first
        h(:div, "Train: #{name} - #{@game.format_currency(train.price)} x #{trains.size}")
      end
    end

    def render_bankruptcy
      resign = lambda do
        process_action(Engine::Action::Bankrupt.new(@corporation))
      end

      props = {
        style: {
          display: 'block',
        },
        on: { click: resign },
      }

      h(:button, props, 'Declare Bankruptcy')
    end
  end
end
