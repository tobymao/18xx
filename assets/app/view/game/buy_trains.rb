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

        cash = @corporation.cash + player.cash
        share_funds_required = @depot.min_depot_price - cash
        share_funds_allowed = if @game.class::EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST
                                share_funds_required
                              else
                                @depot.max_depot_price - cash
                              end
        share_funds_possible = @game.liquidity(player, emergency: true) - player.cash

        children << h(:div, "#{player.name} must contribute "\
                            "#{@game.format_currency(@depot.min_depot_price - @corporation.cash)} "\
                            "for #{@corporation.name} to afford a train from the Depot.")

        children << h(:div, "#{player.name} has #{@game.format_currency(player.cash)} in cash.")

        if share_funds_allowed.positive?
          children << h(:div, "#{player.name} has #{@game.format_currency(share_funds_possible)} "\
                              'in sellable shares.')
        end

        if share_funds_required.positive?
          children << h(:div, "#{player.name} must sell shares to raise at least "\
                              "#{@game.format_currency(share_funds_required)}.")
        end

        if share_funds_allowed.positive? &&
           (share_funds_allowed != share_funds_required) &&
           (share_funds_possible >= share_funds_allowed)
          children << h(:div, "#{player.name} may continue to sell shares until raising up to "\
                              "#{@game.format_currency(share_funds_allowed)}.")
        end

        if share_funds_possible < share_funds_required
          children << h(:div, "#{player.name} does not have enough liquidity to "\
                              "contribute towards #{@corporation.name} buying a train "\
                              "from the Depot. #{@corporation.name} must buy a "\
                              "train from another corporation, or #{player.name} must "\
                              'declare bankruptcy.')
        end

        children.concat(render_emergency_money_raising(player)) if share_funds_allowed.positive?

        children
      end

      def render
        step = @game.round.active_step
        @corporation = step.current_entity
        if @selected_company&.owner == @corporation
          @ability = @selected_company&.abilities(:train_discount, time: 'train')
        end

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

          discountable_trains.each do |train, discount_train, discount_name, price|
            exchange_train = lambda do
              process_action(
                Engine::Action::BuyTrain.new(
                  @corporation,
                  train: discount_train,
                  price: price,
                  variant: discount_name,
                  exchange: train,
                )
              )
            end

            children << h(:div, [
              "#{train.name} -> #{discount_name} #{@game.format_currency(price)} ",
              h('button.no_margin', { on: { click: exchange_train } }, 'Exchange'),
            ])
          end
        end

        children << h(:h3, h3_props, 'Remaining Trains')
        children << remaining_trains

        children << h(:div, "#{@corporation.name} has #{@game.format_currency(@corporation.cash)}.")
        if (issuable_cash = @game.emergency_issuable_cash(@corporation)).positive?
          children << h(:div, "#{@corporation.name} can issue shares to raise up to "\
                              "#{@game.format_currency(issuable_cash)} (the corporation "\
                              'must issue shares before the president may contribute).')
        end

        if must_buy_train && step.ebuy_president_can_contribute?(@corporation)
          children.concat(render_president_contributions)
        end

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
            price = @game.discard_discount(train, price)

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
              attrs: price_range(group[0]),
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

      def price_range(train)
        step = @game.round.active_step
        if step.must_buy_at_face_value?(train, @corporation)
          {
            type: 'number',
            min: train.price,
            max: train.price,
            value: train.price,
            size: 1,
          }
        else
          min, max = step.spend_minmax(@corporation, train)
          {
            type: 'number',
            min: min,
            max: max,
            value: min,
            size: @corporation.cash.to_s.size,
          }
        end
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
