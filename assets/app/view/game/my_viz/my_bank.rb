# frozen_string_literal: true

require 'lib/settings'
require 'view/game/actionable'
require 'view/game/my_viz/card'

module View
  module Game
    class MyBank < Snabberb::Component
      include Lib::Settings
      include Actionable

      needs :game, store: true
      needs :train_handler, default: nil
      needs :show_loan_table, default: false, store: true

      FONT_STD = '"Helvetica Neue", Helvetica, Arial, sans-serif'
      FONT_MONEY = '"Courier New", Courier, monospace'
      FONT_CASH = '"Arial Black", Gadget, sans-serif'
      COLOR_CASH = '#4b0082' # Dark Purple (Indigo)

      def active_entity
        @game.round.active_step&.current_entity
      end

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

        h('div#bank.card.column-zone-market', [
           h('div.title', title_props, 'The Bank'),
           h(:div, body_props, [
             render_financial_table,
             render_bank_trains,
             render_discarded_trains,
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
              h('td.right', { style: { fontFamily: FONT_MONEY, fontWeight: 'bold' } },
                @game.format_currency(@game.future_interest_rate)),
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

        # Directly identify the single next upcoming train to bypass the core engine lookup layer entirely
        next_train = @game.depot.upcoming.first
        return nil unless next_train

        step = @game.round.active_step
        train_buyable_step = step&.current_actions&.include?('buy_train')

        card_classes = ['game-card']
        click_handler = nil

        if train_buyable_step && active_entity&.corporation?
          card_classes << 'action-buy'
          card_classes << 'clickable'
          click_handler = lambda {
            process_action(Engine::Action::BuyTrain.new(
              active_entity,
              train: next_train,
              price: next_train.price
            ))
          }
        end

        card_props = { attrs: { class: card_classes.join(' ') } }
        card_props[:on] = { click: click_handler } if click_handler

        train_card = h(:div, { style: { display: 'inline-block', margin: '2px', textAlign: 'center', verticalAlign: 'top' } }, [
          h(:div, card_props, next_train.name),
          h(:div,
            { style: { fontFamily: FONT_CASH, color: COLOR_CASH, fontSize: '0.75rem', fontWeight: 'bold', marginTop: '2px' } }, @game.format_currency(next_train.price)),
        ])

        h(:div, {
            style: {
              marginTop: '0.4rem',
              paddingTop: '0.4rem',
              borderTop: '1px solid #bbbbbb',
              textAlign: 'center',
            },
          }, [
          h(:div, { style: { fontSize: '0.8rem', fontWeight: 'bold', marginBottom: '0.3rem', fontFamily: FONT_STD } },
            'Bank Depot:'),
          h(:div, { style: { display: 'flex', flexWrap: 'wrap', justifyContent: 'center' } }, [train_card]),
        ])
      end

      def render_discarded_trains
        return nil unless @game.respond_to?(:depot) && @game.depot && !@game.depot.discarded.empty?

        rust_schedule = Hash.new { |h, k| h[k] = [] }
        obsolete_schedule = Hash.new { |h, k| h[k] = [] }

        @game.depot.trains.group_by(&:name).each do |_name, trains|
          first = trains.first
          base_variant = first.variants.values.find { |v| !v[:ignore_rust_obsolete_schedule] }
          next unless base_variant

          base_rust = base_variant[:rusts_on]
          base_obsolete = base_variant[:obsolete_on]

          first.variants.each do |name, train_variant|
            next if train_variant[:ignore_rust_obsolete_schedule]

            train_variant[:rusts_on] ||= base_rust
            train_variant[:obsolete_on] ||= base_obsolete

            Array(train_variant[:rusts_on]).each do |rusts_on|
              rust_schedule[rusts_on].append(name) unless rust_schedule[rusts_on].include?(name)
            end
            Array(train_variant[:obsolete_on]).each do |obsolete_on|
              obsolete_schedule[obsolete_on].append(name) unless obsolete_schedule[obsolete_on].include?(name)
            end
          end
        end

        step = @game.round.active_step
        train_buyable_step = step&.current_actions&.include?('buy_train')

        rows = @game.depot.discarded.group_by(&:name).map do |_name, trains|
          train = trains.first
          price = @game.format_currency(train.price)
          count_text = trains.size.to_s

          card_classes = ['game-card']
          click_handler = nil

          if train_buyable_step && active_entity && active_entity.corporation?
            card_classes << 'action-buy'
            card_classes << 'clickable'
            click_handler = lambda {
              process_action(Engine::Action::BuyTrain.new(
                active_entity,
                train: train,
                price: train.price
              ))
            }
          end

          card_props = { attrs: { class: card_classes.join(' ') } }
          card_props[:on] = { click: click_handler } if click_handler

          effects = []
          train.names_to_prices.keys.each do |key|
            if (rust = rust_schedule[key]) && !rust.empty?
              effects << "Rusts: #{rust.join(', ')}"
            end
          end

          if obsolete_schedule[train.name] && !obsolete_schedule[train.name].empty?
            effects << "Phases out: #{obsolete_schedule[train.name].join(', ')}"
          end

          h(:tr, { style: { borderBottom: '1px solid #cccccc' } }, [
h('td.center', { style: { padding: '0.4rem 0.6rem', verticalAlign: 'middle' } }, [
              h(:div, card_props, train.name),
            ]),
h('td.right', { style: { fontFamily: FONT_CASH, color: COLOR_CASH, padding: '0.4rem 0.6rem', fontWeight: 'bold' } },
  price),
h('td.center', { style: { fontFamily: FONT_STD, padding: '0.4rem 0.6rem', verticalAlign: 'middle' } }, count_text),
h('td.left', { style: { fontFamily: FONT_STD, padding: '0.4rem 0.6rem', fontSize: '0.8rem', color: '#444444', verticalAlign: 'middle' } },
  effects.join(' | ')),
          ])
        end

        h(:div, {
            style: {
              marginTop: '0.4rem',
              paddingTop: '0.4rem',
              borderTop: '1px solid #bbbbbb',
            },
          }, [
          h(:div,
            { style: { fontSize: '0.8rem', fontWeight: 'bold', marginBottom: '0.3rem', fontFamily: FONT_STD, textAlign: 'center' } }, 'Bank Pool (Discarded):'),
          h(:div, { style: { overflowX: 'auto' } }, [
            h(:table, { style: { borderCollapse: 'collapse', width: '100%', fontSize: '0.85rem' } }, [
              h(:thead, [
                h(:tr, { style: { borderBottom: '2px solid #333333' } }, [
                  h('th.center', { style: { padding: '0.4rem 0.6rem' } }, 'Type'),
                  h('th.right', { style: { padding: '0.4rem 0.6rem' } }, 'Price'),
                  h('th.center', { style: { padding: '0.4rem 0.6rem' } }, 'Available'),
                  h('th.left', { style: { padding: '0.4rem 0.6rem' } }, 'Effect'),
                ]),
              ]),
              h(:tbody, rows),
            ]),
          ]),
        ])
      end
    end
  end
end
