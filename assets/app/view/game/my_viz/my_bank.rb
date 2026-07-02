# frozen_string_literal: true

require 'lib/settings'
require 'view/game/my_viz/card'

module View
  module Game
    class MyBank < Snabberb::Component
      include Lib::Settings

      needs :game
      needs :show_loan_table, default: false, store: true

      FONT_STD = '"Helvetica Neue", Helvetica, Arial, sans-serif'
      FONT_MONEY = '"Courier New", Courier, monospace'
      FONT_CASH = '"Arial Black", Gadget, sans-serif'
      COLOR_CASH = '#4b0082' # Dark Purple (Indigo)

      def render
        title_props = {
          style: {
            padding: '0.4rem',
            backgroundColor: color_for(:bg2),
            color: color_for(:font2),
            fontStyle: 'italic',
            fontWeight: 'bold',
          },
        }
        body_props = {
          style: {
            margin: '0.3rem 0.5rem 0.4rem',
            display: 'flex',
            flexDirection: 'column',
            gap: '0.75rem',
          },
        }

        h('div#bank.card', [
          h('div.title', title_props, 'The Bank'),
          h(:div, body_props, [
            render_financial_table,
            render_bank_trains,
            h(GameInfo, game: @game, layout: 'discarded_trains'),
          ].compact),
        ])
      end

      def render_financial_table
        trs = []
        interest_change = (@game.interest_change if @game.respond_to?(:interest_change))

        if @game.game_end_check_values.include?(:bank)
          clean_bank_cash = @game.format_currency(@game.bank_cash).gsub(/[^0-9]/, '')
          trs << h(:tr, [
            h('td.left', { style: { fontFamily: FONT_STD } }, 'Cash'),
            h('td.right', { style: { fontFamily: FONT_CASH, color: COLOR_CASH } }, clean_bank_cash),
          ])
        end

        if (rate = @game.interest_rate)
          trs << h(:tr, [
            h('td.left', { style: { fontFamily: FONT_STD } }, 'Interest per Loan'),
            h('td.right', { style: { fontFamily: FONT_MONEY, fontWeight: 'bold' } }, @game.format_currency(rate)),
          ])
          if @game.respond_to?(:future_interest_rate)
            trs << h(:tr, [
              h('td.left', { style: { fontFamily: FONT_STD } }, 'Future Interest'),
              h('td.right', { style: { fontFamily: FONT_MONEY, fontWeight: 'bold' } }, @game.format_currency(@game.future_interest_rate)),
            ])
          end
          trs << h(:tr, [
            h('td.left', { style: { fontFamily: FONT_STD } }, 'Loans Taken'),
            h('td.right', { style: { fontFamily: FONT_MONEY, fontWeight: 'bold' } }, "#{@game.loans_taken}/#{@game.total_loans}"),
          ])

          if interest_change
            toggle_loan_table = lambda do
              store(:show_loan_table, !@show_loan_table)
            end

            props = {
              attrs: { title: "#{@show_loan_table ? 'Hide' : 'Show'} loan table" },
              style: { width: '4rem', margin: '0', cursor: 'pointer' },
              on: { click: toggle_loan_table },
            }
            trs << h(:tr, [
              h('td.middle', { style: { fontFamily: FONT_STD } }, 'Loan Table'),
              h('td.right', [h(:button, props, (@show_loan_table ? 'Hide' : 'Show').to_s)]),
            ])

            if @show_loan_table
              total = 0
              interest_change.last.each do |price, available|
                total += available
                trs << h(:tr, [
                  h('td.left', { style: { fontFamily: FONT_MONEY } }, @game.format_currency(price)),
                  h('td.right', { style: { fontFamily: FONT_MONEY } }, "#{available} (#{total})"),
                ])
              end
            end

            interest_change.first.each do |text, price_change|
              trs << h(:tr, [
                h('td.left', { style: { fontFamily: FONT_STD } }, text),
                h('td.right', { style: { fontFamily: FONT_MONEY } }, @game.format_currency(price_change)),
              ])
            end
          end

          trs << h(:tr, [
            h('td.left', { style: { fontFamily: FONT_STD } }, 'Loan Value'),
            h('td.right', { style: { fontFamily: FONT_MONEY, fontWeight: 'bold' } }, @game.format_currency(@game.loan_value)),
          ])
        end

        active_step = @game.round.active_step
        if active_step.respond_to?(:seed_money) && active_step.seed_money
          clean_seed = @game.format_currency(active_step.seed_money).gsub(/[^0-9]/, '')
          trs << h(:tr, [
            h('td.left', { style: { fontFamily: FONT_STD } }, 'Seed Money'),
            h('td.right', { style: { fontFamily: FONT_CASH, color: COLOR_CASH } }, clean_seed),
          ])
        end

        if @game.respond_to?(:unstarted_corporation_summary) && (summary = @game.unstarted_corporation_summary) && !summary.empty?
          trs << h(:tr, [
            h('td.left', { style: { fontFamily: FONT_STD } }, 'Unstarted Corps'),
            h('td.right', { style: { fontFamily: FONT_STD } }, summary.first.to_s),
          ])
        end

        if @game.respond_to?(:other_bank_info) && @game.other_bank_info
          trs << h(:tr, [
            h('td.left', { style: { fontFamily: FONT_STD } }, @game.other_bank_info.first.to_s),
            h('td.right', { style: { fontFamily: FONT_MONEY } }, @game.other_bank_info.last.to_s),
          ])
        end

        return nil if trs.empty?

        h(:table, { style: { borderCollapse: 'collapse', width: '100%' } }, trs)
      end

      
def render_bank_trains
        return nil unless @game.respond_to?(:depot) && @game.depot

        trains_to_show = []
        if @game.depot.respond_to?(:available)
          trains_to_show = @game.depot.available || []
        elsif @game.depot.respond_to?(:upcoming)
          trains_to_show = @game.depot.upcoming || []
        end

        return nil if !trains_to_show || trains_to_show.empty?

        seen = {}
        unique_trains = []

        trains_to_show.each do |t|
          next if `t === undefined || t === null`
          next unless t.respond_to?(:name)
          next if !t.name

          unless seen[t.name]
            seen[t.name] = true
            unique_trains << t
          end
        end

        return nil if unique_trains.empty?

        train_cards = unique_trains.map do |t|
          border_color = '#999999'
          click_handler = nil

          h(:div, { style: { display: 'inline-block', margin: '2px' } }, [
            h(View::Game::Card, text: t.name, border_color: border_color, click_action: click_handler)
          ])
        end

        h(:div, {
          style: {
            marginTop: '0.4rem',
            paddingTop: '0.4rem',
            borderTop: '1px solid #bbbbbb',
            textAlign: 'center',
          }
        }, [
          h(:div, { style: { fontSize: '0.8rem', fontWeight: 'bold', marginBottom: '0.3rem', fontFamily: FONT_STD } }, 'Bank Depot:'),
          h(:div, { style: { display: 'flex', flexWrap: 'wrap', justifyContent: 'center' } }, train_cards)
        ])
      end


    end
  end
end