# frozen_string_literal: true

require 'lib/settings'

module View
  module Game
    class Bank < Snabberb::Component
      include Lib::Settings

      needs :game
      needs :show_loan_table, default: false, store: true

      def render
        title_props = {
          style: {
            padding: '0.4rem',
            backgroundColor: color_for(:bg2),
            color: color_for(:font2),
            fontStyle: 'italic',
          },
        }
        body_props = {
          style: {
            margin: '0.3rem 0.5rem 0.4rem',
            display: 'grid',
            grid: 'auto / 1fr',
            gap: '0.5rem',
            justifyItems: 'center',
          },
        }

        trs = []
        interest_change = (@game.interest_change if @game.respond_to?(:interest_change))
        if @game.game_end_check_values.include?(:bank)
          trs << h(:tr, [
            h(:td, 'Cash'),
            h('td.right', @game.format_currency(@game.bank_cash)),
          ])
        end
        if (rate = @game.interest_rate)
          trs << h(:tr, [
            h(:td, 'Interest per Loan'),
            h('td.right', @game.format_currency(rate)),
          ])
          if @game.respond_to?(:future_interest_rate)
            trs << h(:tr, [
              h(:td, 'Future Interest per Loan'),
              h('td.right', @game.format_currency(@game.future_interest_rate)),
            ])
          end
          trs << h(:tr, [
            h(:td, 'Loans'),
            h('td.right', "#{@game.loans_taken}/#{@game.total_loans}"),
          ])

          if interest_change
            toggle_loan_table = lambda do
              store(:show_loan_table, !@show_loan_table)
            end

            props = {
              attrs: { title: "#{@show_loan_table ? 'Hide' : 'Show'} loan table" },
              style: { width: '4rem', margin: '0' },
              on: { click: toggle_loan_table },
            }
            trs << h(:tr, [
              h('td.middle', 'Loan Table'),
              h('td.right', [h(:button, props, (@show_loan_table ? 'Hide' : 'Show').to_s)]),
            ])

            if @show_loan_table
              total = 0
              interest_change.last.each do |price, available|
                total += available
                trs << h(:tr, [
                  h(:td, @game.format_currency(price)),
                  h('td.right', "#{available} (#{total})"),
                ])
              end
            end

            interest_change.first.each do |text, price_change|
              trs << h(:tr, [
                h(:td, text),
                h('td.right', @game.format_currency(price_change)),
              ])
            end
          end
          trs << h(:tr, [
            h(:td, 'Loan Value'),
            h('td.right', @game.format_currency(@game.loan_value)),
          ])
        end
        active_step = @game.round.active_step
        if active_step.respond_to?(:seed_money) && active_step.seed_money
          trs << h(:tr, [
            h(:td, 'Seed Money'),
            h('td.right', @game.format_currency(active_step.seed_money)),
          ])
        end
        if @game.respond_to?(:unstarted_corporation_summary)
          trs << h(:tr, [
            h(:td, 'Unstarted corporations'),
            h('td.right', @game.unstarted_corporation_summary.first),
          ])
        end

        return if trs.empty?

        h('div#bank.card', [
          h('div.title', title_props, 'The Bank'),
          h(:div, body_props, [
            h(:table, trs),
            h(GameInfo, game: @game, layout: 'discarded_trains'),
          ]),
        ])
      end
    end
  end
end
