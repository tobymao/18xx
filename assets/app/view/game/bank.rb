# frozen_string_literal: true

require 'lib/settings'

module View
  module Game
    class Bank < Snabberb::Component
      include Lib::Settings

      needs :game

      def render
        title_props = {
          style: {
            padding: '0.4rem',
            backgroundColor: color_for(:bg2),
            color: color_for(:font2),
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
          if @game.respond_to?(:interest_change)
            @game.interest_change.each do |text, price_change|
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
        if @game.round.active_step.respond_to?(:seed_money)
          trs << h(:tr, [
            h(:td, 'Seed Money'),
            h('td.right', @game.format_currency(@game.round.active_step.seed_money)),
          ])
        end

        return unless trs.any?

        h('div.bank.card', [
          h('div.title.nowrap', title_props, [h(:em, 'The Bank')]),
          h(:div, body_props, [
            h(:table, trs),
            h(GameInfo, game: @game, layout: 'discarded_trains'),
          ]),
        ])
      end
    end
  end
end
