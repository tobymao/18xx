# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/emergency_money'

module View
  module Game
    class BuyTrains < Snabberb::Component
      include Actionable
      include EmergencyMoney
      needs :show_other_players, default: nil, store: true
      needs :selected_corporation, default: nil, store: true

      def render_president_contributions
        player = @corporation.owner

        children = []

        funds_required = @depot.min_depot_price - (@corporation.cash + player.cash)
        if funds_required.positive?
          liquidity = @game.liquidity(player, emergency: true)
          children << h('div',
                        'To buy the cheapest train from the depot the president must raise '\
                        "#{@game.format_currency(funds_required)}, and can sell "\
                        "#{@game.format_currency(liquidity - player.cash)} in shares:")

          children.concat(render_emergency_money_raising(player))
        else
          children << h('div',
                        'To buy the cheapest train from the depot the president must contribute'\
                        " #{@game.format_currency(@depot.min_depot_price - @corporation.cash)}")
        end

        children
      end

      def render
        step = @game.round.active_step
        @corporation = step.current_entity
        @ability = @selected_company&.abilities(:train_discount, 'train') if @selected_company&.owner == @corporation

        @depot = @game.depot

        available = step.buyable_trains(@corporation).group_by(&:owner)
        depot_trains = available.delete(@depot) || []
        other_corp_trains = available.sort_by { |c, _| c.owner == @corporation.owner ? 0 : 1 }
        children = []

        must_buy_train = step.must_buy_train?(@corporation)
        should_buy_train = step.should_buy_train?(@corporation)

        h3_props = {
          style: {
            margin: '0.5rem 0 0 0',
          },
        }
        div_props = {
          style: {
            display: 'grid',
            grid: 'auto / minmax(0.7rem, auto) 1fr auto auto',
            gap: '0.5rem',
            alignItems: 'center',
          },
        }

        if (step.can_buy_train?(@corporation) && step.room?(@corporation)) || must_buy_train
          children << h(:div, "#{@corporation.name} must buy an available train") if must_buy_train
          if should_buy_train == :liquidation
            children << h(:div, "#{@corporation.name} must buy a train or it will be liquidated")
          end
          children << h(:h3, h3_props, 'Available Trains')
          children << h(:div, div_props, [
            *from_depot(depot_trains),
            *other_corp_trains.any? ? other_trains(other_corp_trains) : '',
          ])
        end

        discountable_trains = @depot.discountable_trains_for(@corporation)

        if discountable_trains.any?
          children << h(:h3, h3_props, 'Exchange Trains')

          discountable_trains.each do |train, discount_train, price|
            exchange_train = lambda do
              process_action(
                Engine::Action::BuyTrain.new(
                  @corporation,
                  train: discount_train,
                  price: price,
                  exchange: train,
                )
              )
            end

            children << h(:div, [
              "#{train.name} -> #{discount_train.name} #{@game.format_currency(price)} ",
              h('button.no_margin', { on: { click: exchange_train } }, 'Exchange'),
            ])
          end
        end

        children << h(:h3, h3_props, 'Remaining Trains')
        children << remaining_trains
        children.concat(render_president_contributions) if must_buy_train && @corporation.cash < @depot.min_depot_price

        props = {
          style: {
            display: 'grid',
            rowGap: '0.5rem',
            marginBottom: '1rem',
          },
        }

        h('div#buy_trains', props, children)
      end

      def from_depot(depot_trains)
        depot_trains.flat_map do |train|
          train.variants
            .select { |_, v| @game.round.active_step.buyable_train_variants(train, @corporation).include?(v) }
            .sort_by { |_, v| v[:price] }
            .flat_map do |name, variant|
            price = variant[:price]
            president_assist, _fee = @game.president_assisted_buy(@corporation, train, price)
            price = @ability&.discounted_price(train, price) || price

            buy_train = lambda do
              process_action(Engine::Action::BuyTrain.new(
                @ability ? @selected_company : @corporation,
                train: train,
                price: price,
                variant: name,
              ))
            end

            source = @depot.discarded.include?(train) ? 'The Discard' : 'The Depot'

            [h(:div, name),
             h('div.nowrap', source),
             h('div.right', @game.format_currency(price)),
             h('button.no_margin', { on: { click: buy_train } }, president_assist.positive? ? 'Assisted buy' : 'Buy')]
          end
        end
      end

      def other_trains(other_corp_trains)
        hidden_trains = false
        trains_to_buy = other_corp_trains.flat_map do |other, trains|
          trains.group_by(&:name).flat_map do |name, group|
            input = h(
              'input.no_margin',
              style: {
                height: '1.2rem',
                width: '3rem',
                padding: '0 0 0 0.2rem',
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
              process_action(Engine::Action::BuyTrain.new(
                @corporation,
                train: group[0],
                price: price,
              ))
            end

            count = group.size

            if @show_other_players || other.owner == @corporation.owner
              [h(:div, name),
               h('div.nowrap', "#{other.name} (#{count > 1 ? "#{count}, " : ''}#{other.owner.name})"),
               input,
               h('button.no_margin', { on: { click: buy_train } }, 'Buy')]
            else
              hidden_trains = true
              nil
            end
          end
        end.compact

        button_props = {
          style: {
            display: 'grid',
            gridColumn: '1/4',
            width: 'max-content',
          },
        }

        if hidden_trains
          trains_to_buy << h('button.no_margin',
                             { on: { click: -> { store(:show_other_players, true) } }, **button_props },
                             'Show trains from other players')
        elsif @show_other_players
          trains_to_buy << h('button.no_margin',
                             { on: { click: -> { store(:show_other_players, false) } }, **button_props },
                             'Hide trains from other players')
        end
        trains_to_buy
      end

      def remaining_trains
        div_props = {
          style: {
            display: 'grid',
            grid: 'auto / repeat(3, max-content)',
            gap: '0 1rem',
            justifyItems: 'right',
          },
        }

        rows = @depot.upcoming.group_by(&:name).flat_map do |_, trains|
          names_to_prices = trains.first.names_to_prices
          [h(:div, names_to_prices.keys.join(', ')),
           h(:div, names_to_prices.values.map { |p| @game.format_currency(p) }.join(', ')),
           h(:div, trains.size)]
        end

        h(:div, div_props, [
          h('div.bold', 'Train'),
          h('div.bold', 'Cost'),
          h('div.bold', 'Qty'),
          *rows,
        ])
      end
    end
  end
end
