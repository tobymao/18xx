# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/emergency_money'
require 'view/game/alternate_corporations'

module View
  module Game
    class BuyPower < Snabberb::Component
      include Actionable
      include EmergencyMoney
      include Lib::Settings
      needs :corporation, default: nil

      def render_president_contributions
        player = @corporation.owner

        children = []

        verb = @must_buy_power ? 'must' : 'may'

        cash_needed = @step.ebuy_cash_needed(@corporation)
        cash = @corporation.cash + player.cash
        share_funds_required = cash_needed - cash
        share_funds_allowed = share_funds_required
        share_funds_possible = @game.emr_liquidity(player, @corporation) - player.cash

        if cash_needed > @corporation.cash
          children << h(:div, "#{player.name} #{verb} contribute "\
                              "#{@game.format_currency(cash_needed - @corporation.cash)} "\
                              "for #{@corporation.name} to afford minimum train power.")
        end

        children << h(:div, "#{player.name} has #{@game.format_currency(player.cash)} in cash.")

        if @step.can_ebuy_sell_shares?(@corporation)
          if share_funds_allowed.positive?
            children << h(:div, "#{player.name} has #{@game.format_currency(share_funds_possible)} "\
                                'in sellable shares/companies.')
          end

          if share_funds_required.positive?
            children << h(:div, "#{player.name} #{verb} sell shares/companies to raise at least "\
                                "#{@game.format_currency(share_funds_required)}.")
          end
        end

        if @must_buy_power &&
           share_funds_possible < share_funds_required &&
           @game.can_go_bankrupt?(player, @corporation)
          children << h(:div, "#{player.name} does not have enough liquidity to "\
                              "contribute towards #{@corporation.name} buying the minimum train "\
                              "power. #{player.name} must declare bankruptcy.")
        end

        children.concat(render_emergency_money_raising(player)) if share_funds_allowed.positive?

        children
      end

      def render
        @step = @game.round.active_step
        @corporation ||= @step.current_entity

        @depot = @game.depot

        children = []

        @must_buy_power = @step.must_buy_power?(@corporation)

        if @step.can_buy_power?(@corporation) || @must_buy_power
          if @must_buy_power
            children << h(:div, "#{@corporation.name} must buy "\
                                "#{@step.ebuy_power_needed(@corporation)} train power ")
          end
          children << h(:h3, 'Select Amount of Train Power to Buy')
          children << h(:div, render_buy(@corporation))
        end

        children << render_chart
        children << h(:div, "#{@corporation.name} has #{@game.format_currency(@corporation.cash)}.")
        children << h(:div, "Power Progress: #{@game.power_progress}")
        children << h(:div, "Current/Next power cost: #{@game.format_currency(@game.current_power_cost)} / "\
                            "#{@game.format_currency(@game.next_power_cost)}")

        if (@must_buy_power && @step.ebuy_president_can_contribute?(@corporation)) ||
           @step.president_may_contribute?(@corporation)
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

      def render_buy(corporation)
        min, max = @step.power_minmax(corporation)
        input = h(
          'input.no_margin',
          style: {
            height: '1.2rem',
            width: '3rem',
            padding: '0 0 0 0.2rem',
          },
          attrs: {
            type: 'number',
            min: min,
            max: max,
            value: min,
            size: max.to_s.size + 2,
          }
        )

        buy_power = lambda do
          amount = input.JS['elm'].JS['value'].to_i
          process_action(Engine::Action::BuyPower.new(
            corporation,
            power: amount,
          ))
        end

        [input,
         h('button.no_margin', { on: { click: buy_power } }, 'Buy Power')]
      end

      def render_chart
        header, *chart = @step.chart(@corporation)

        rows = chart.map do |r|
          h(:tr, [
            h(:td, r[0]),
            h(:td, r[1]),
          ])
        end

        table_props = {
          style: {
            margin: '0.5rem 0',
            textAlign: 'left',
          },
        }

        h(:table, table_props, [
          h(:thead, [
            h(:tr, [
              h(:th, header[0]),
              h(:th, header[1]),
            ]),
          ]),
          h(:tbody, rows),
        ])
      end
    end
  end
end
