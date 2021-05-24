# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/emergency_money'
require 'view/game/alternate_corporations'

module View
  module Game
    class BuyTrains < Snabberb::Component
      include Actionable
      include EmergencyMoney
      include AlternateCorporations
      needs :show_other_players, default: nil, store: true
      needs :corporation, default: nil
      needs :active_shell, default: nil, store: true

      def render_president_contributions
        player = @corporation.owner
        step = @game.round.active_step

        children = []

        verb = @must_buy_train ? 'must' : 'may'

        cheapest_train_price = if step.respond_to?(:cheapest_train_price)
                                 step.cheapest_train_price(@corporation)
                               else
                                 @depot.min_depot_price
                               end
        cash = @corporation.cash + player.cash
        share_funds_required = cheapest_train_price - cash
        share_funds_allowed = if @game.class::EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST
                                share_funds_required
                              else
                                @depot.max_depot_price - cash
                              end
        share_funds_possible = @game.liquidity(player, emergency: true) - player.cash

        if cheapest_train_price > @corporation.cash
          children << h(:div, "#{player.name} #{verb} contribute "\
                              "#{@game.format_currency(cheapest_train_price - @corporation.cash)} "\
                              "for #{@corporation.name} to afford a train from the Depot.")
        end

        children << h(:div, "#{player.name} has #{@game.format_currency(player.cash)} in cash.")

        if @game.class::EBUY_CAN_SELL_SHARES
          if share_funds_allowed.positive?
            children << h(:div, "#{player.name} has #{@game.format_currency(share_funds_possible)} "\
                                'in sellable shares.')
          end

          if share_funds_required.positive?
            children << h(:div, "#{player.name} #{verb} sell shares to raise at least "\
                                "#{@game.format_currency(share_funds_required)}.")
          end

          if share_funds_allowed.positive? &&
             (share_funds_allowed != share_funds_required) &&
             (share_funds_possible >= share_funds_allowed)
            children << h(:div, "#{player.name} may continue to sell shares until raising up to "\
                                "#{@game.format_currency(share_funds_allowed)}.")
          end
        end

        must_take_loan = step.must_take_loan?(@corporation) if step.respond_to?(:must_take_loan?)
        if must_take_loan
          text = "#{player.name} does not have enough liquidity to "\
          "contribute towards #{@corporation.name} buying a train "\
          'from the Depot. '

          if @game.class::ALLOW_TRAIN_BUY_FROM_OTHERS
            text += "#{@corporation.name} must buy a "\
            'train from another corporation, or'
          end

          text += "#{player.name} must " \
          "take a loan of at least #{@game.format_currency(share_funds_required)}"
          children << h(:div, text)
        end

        if @must_buy_train &&
           share_funds_possible < share_funds_required &&
           !must_take_loan &&
           @game.can_go_bankrupt?(player, @corporation)
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
        @corporation ||= step.current_entity

        @depot = @game.depot

        available = step.buyable_trains(@corporation).group_by(&:owner)
        depot_trains = available.delete(@depot) || []
        other_corp_trains = available.sort_by { |c, _| c.owner == @corporation.owner ? 0 : 1 }
        children = []

        @must_buy_train = step.must_buy_train?(@corporation)
        @should_buy_train = step.should_buy_train?(@corporation)

        div_props = {
          style: {
            display: 'grid',
            grid: 'auto / minmax(0.7rem, auto) 1fr auto auto',
            gap: '0.5rem',
            alignItems: 'center',
          },
        }

        if @corporation.system?
          store(:active_shell, @corporation.shells.first, skip: true) unless @active_shell
          children << render_shells
        else
          store(:active_shell, nil, skip: true)
        end

        if (step.can_buy_train?(@corporation, @active_shell) && step.room?(@corporation, @active_shell)) ||
           @must_buy_train
          children << h(:div, "#{@corporation.name} must buy an available train") if @must_buy_train
          if @should_buy_train == :liquidation
            children << h(:div, "#{@corporation.name} must buy a train or it will be liquidated")
          end
          children << h(:h3, 'Available Trains')
          children << h(:div, div_props, [
            *from_depot(depot_trains),
            *render_warranty(depot_trains),
            *other_corp_trains.any? ? other_trains(other_corp_trains) : '',
          ])
        end

        @slot_checkboxes = {}
        if step.respond_to?(:slot_view) && (view = step.slot_view(@corporation))
          children << send("render_#{view}")
        end

        discountable_trains = @game.discountable_trains_for(@corporation)

        if discountable_trains.any? && step.discountable_trains_allowed?(@corporation)
          children << h(:h3, 'Exchange Trains')

          discountable_trains.each do |train, discount_train, variant, price|
            exchange_train = lambda do
              process_action(
                Engine::Action::BuyTrain.new(
                  @corporation,
                  train: discount_train,
                  price: price,
                  variant: variant,
                  exchange: train,
                  shell: @active_shell,
                )
              )
            end

            children << h(:div, [
              "#{train.name} -> #{variant} #{@game.format_currency(price)} ",
              h('button.no_margin', { on: { click: exchange_train } }, 'Exchange'),
            ])
          end
        end

        children << h(:h3, 'Remaining Trains')
        children << remaining_trains

        children << h(:div, "#{@corporation.name} has #{@game.format_currency(@corporation.cash)}.")
        if step.issuable_shares(@corporation).any? &&
           (issuable_cash = @game.emergency_issuable_cash(@corporation)).positive?
          children << h(:div, "#{@corporation.name} can issue shares to raise up to "\
                              "#{@game.format_currency(issuable_cash)} (the corporation "\
                              'must issue shares before the president may contribute).')
        end

        if (@must_buy_train && step.ebuy_president_can_contribute?(@corporation)) ||
           step.president_may_contribute?(@corporation, @active_shell)
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
            entity = @corporation

            if @selected_company&.owner == @corporation
              @game.abilities(@selected_company, :train_discount, time: 'buying_train') do |ability|
                if ability.trains.include?(train.name)
                  price = ability.discounted_price(train, price)
                  entity = @selected_company
                end
              end
            end

            price = @game.discard_discount(train, price)

            buy_train = lambda do
              process_action(Engine::Action::BuyTrain.new(
                entity,
                train: train,
                price: price,
                variant: name,
                shell: @active_shell,
                slots: slots,
                warranties: warranties,
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

      def render_warranty(depot_trains)
        @warranty_input = nil
        step = @game.round.active_step
        return if depot_trains.empty? || !step.respond_to?(:warranty_max)

        @warranty_input =
          h(
            'input.no_margin',
            style: {
              height: '1.2rem',
              width: '3rem',
              padding: '0 0 0 0.2rem',
            },
            attrs: {
              type: 'number',
              min: 0,
              max: step.warranty_max,
              value: 0,
              size: 1,
            }
          )

        [h(:div, ''),
         h(:div, step.warranty_text),
         h(:div, step.warranty_cost),
         @warranty_input]
      end

      # return checkbox values for slots (if any)
      def slots
        return if @slot_checkboxes.empty?

        @slot_checkboxes.keys.map do |k|
          k if Native(@slot_checkboxes[k]).elm.checked
        end.compact
      end

      def warranties
        return unless @warranty_input

        @warranty_input.JS['elm'].JS['value'].to_i
      end

      def other_trains(other_corp_trains)
        step = @game.round.active_step
        hidden_trains = false
        trains_to_buy = other_corp_trains.flat_map do |other, trains|
          trains.group_by(&:name).flat_map do |name, group|
            fixed_price = step.respond_to?(:fixed_price) && step.fixed_price(group[0])
            input = if fixed_price
                      h('div.right', @game.format_currency(fixed_price))
                    else
                      h(
                        'input.no_margin',
                        style: {
                          height: '1.2rem',
                          width: '3rem',
                          padding: '0 0 0 0.2rem',
                        },
                        attrs: price_range(group[0]),
                      )
                    end

            extra_due_checkbox = nil
            buy_train_click = lambda do
              price = fixed_price || input.JS['elm'].JS['value'].to_i
              extra_due = extra_due_checkbox && Native(extra_due_checkbox).elm.checked
              buy_train = lambda do
                process_action(Engine::Action::BuyTrain.new(
                  @corporation,
                  train: group[0],
                  price: price,
                  shell: @active_shell,
                  slots: slots,
                  extra_due: extra_due,
                ))
              end

              if other_owner(other) == @corporation.owner
                if !@corporation.loans.empty? && !@game.can_pay_interest?(@corporation, -price)
                  # We don't support nested confirmed, it's unlikely you'll buy from another player.
                  opts = {
                    color: :yellow,
                    click: buy_train,
                    message: "Buying train at #{@game.format_currency(price)} will cause "\
                    "#{@corporation.name} to be liquidated.",
                  }
                  store(:confirm_opts, opts, skip: false)
                else
                  buy_train.call
                end
              else
                check_consent(other_owner(other), buy_train)
              end
            end

            count = group.size

            real_name = other_owner(other) != other.owner ? " [#{other_owner(other).name}]" : ''

            line = if @show_other_players || other_owner(other) == @corporation.owner
                     [h(:div, name),
                      h('div.nowrap',
                        "#{other.name} (#{count > 1 ? "#{count}, " : ''}#{other.owner.name}#{real_name})"),
                      input,
                      h('button.no_margin', { on: { click: buy_train_click } }, 'Buy')]
                   else
                     hidden_trains = true
                     nil
                   end

            if line && step.respond_to?(:extra_due) && step.extra_due(group[0])
              extra_due_checkbox = h(
                'input.no_margin',
                style: {
                  width: '1rem',
                  height: '1rem',
                  padding: '0 0 0 0.2rem',
                },
                attrs: {
                  type: 'checkbox',
                  id: 'extra_due',
                  name: 'extra_due',
                }
              )

              line << h(:div, '')
              line << h(:div, step.extra_due_text(group[0]))
              line << h(:div, step.extra_due_prompt)
              line << h(:div, [extra_due_checkbox])
            end
            line
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

      # need to abstract due to corporations owning minors owning trains
      def other_owner(other)
        step = @game.round.active_step
        step.respond_to?(:real_owner) ? step.real_owner(other) : other.owner
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
          [h(:div, @game.info_train_name(trains.first)),
           h(:div, @game.info_train_price(trains.first)),
           h(:div, trains.size)]
        end

        h(:div, div_props, [
          h('div.bold', 'Train'),
          h('div.bold', 'Cost'),
          h('div.bold', 'Qty'),
          *rows,
        ])
      end

      def render_shells
        @active_shell = @corporation.shells.first if !@active_shell || @active_shell.system != @corporation

        buttons = @corporation.shells.flat_map do |shell|
          button_props = {
            on: {
              click: -> { store(:active_shell, shell) },
            },
          }
          button_props[:class] = { active: true } if @active_shell == shell

          h(:button, button_props, "#{shell.name} shell")
        end

        button_div_props = {
          style: {
            display: 'grid',
            grid: 'auto / repeat(2, max-content)',
            gap: '0.5rem',
          },
        }
        h(:div, button_div_props, buttons)
      end
    end
  end
end
