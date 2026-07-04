# frozen_string_literal: true

require 'lib/settings'
require 'view/game/my_viz/card'

module View
  module Game
    class MyUpcomingTrains < Snabberb::Component
      include Lib::Settings

      needs :game

      FONT_STD = '"Helvetica Neue", Helvetica, Arial, sans-serif'
      FONT_MONEY = '"Courier New", Courier, monospace'
      FONT_CASH = '"Arial Black", Gadget, sans-serif'
      COLOR_CASH = '#4b0082' # Dark Purple (Indigo)

      def render
        return nil unless @game.respond_to?(:depot) && @game.depot

        @depot = @game.depot
        return nil if @depot.trains.empty?

        rust_schedule = Hash.new { |h, k| h[k] = [] }
        obsolete_schedule = Hash.new { |h, k| h[k] = [] }

        @depot.trains.group_by(&:name).each do |_name, trains|
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

        rows = @depot.trains.reject(&:reserved).group_by(&:sym).map do |sym, trains|
          remaining = @depot.upcoming.select { |t| t.sym == sym }
          next nil if remaining.empty?

          train = trains.first

          name = @game.info_train_name(train)
          price = @game.info_train_price(train)
          rem_text = train.unlimited ? '∞' : "#{remaining.size} / #{trains.size}"

          effects = []

          train.names_to_prices.keys.each do |key|
            if (rust = rust_schedule[key]) && !rust.empty?
              effects << "Rusts: #{rust.join(', ')}"
            end
          end

          if obsolete_schedule[train.name] && !obsolete_schedule[train.name].empty?
            effects << "Phases out: #{obsolete_schedule[train.name].join(', ')}"
          end

          train_events = []
          remaining.each do |t2|
            t2.events.each do |e|
              next if e['hidden']

              ev_name = e['type']
              ev_name = @game.class::EVENTS_TEXT[ev_name][0] if @game.class::EVENTS_TEXT[ev_name]
              train_events << ev_name unless train_events.include?(ev_name)
            end
          end
          effects << "Events: #{train_events.join(', ')}" unless train_events.empty?

          h(:tr, { style: { borderBottom: '1px solid #cccccc' } }, [
h('td.center', { style: { padding: '0.4rem 0.6rem', verticalAlign: 'middle' } }, [
              h(:div, { attrs: { class: 'game-card' } }, name),
            ]),
h('td.right', { style: { fontFamily: FONT_CASH, color: COLOR_CASH, padding: '0.4rem 0.6rem', fontWeight: 'bold' } },
  price),
h('td.center', { style: { fontFamily: FONT_STD, padding: '0.4rem 0.6rem', verticalAlign: 'middle' } }, rem_text),
h('td.left', { style: { fontFamily: FONT_STD, padding: '0.4rem 0.6rem', fontSize: '0.8rem', color: '#444444', verticalAlign: 'middle' } },
  effects.join(' | ')),
          ])
        end.compact

        title_props = {
          style: {
            padding: '0.4rem',
            backgroundColor: color_for(:bg2),
            color: color_for(:font2),
            fontStyle: 'italic',
            fontWeight: 'bold',
          },
        }

        h('div#upcoming_trains.card', [
          h('div.title', title_props, 'Upcoming Trains'),
          h(:div, { style: { margin: '0.3rem 0.5rem 0.4rem', overflowX: 'auto' } }, [
            h(:table, { style: { borderCollapse: 'collapse', width: '100%', fontSize: '0.85rem' } }, [
              h(:thead, [
                h(:tr, { style: { borderBottom: '2px solid #333333' } }, [
                  h('th.center', { style: { padding: '0.4rem 0.6rem' } }, 'Type'),
                  h('th.right', { style: { padding: '0.4rem 0.6rem' } }, 'Price'),
                  h('th.center', { style: { padding: '0.4rem 0.6rem' } }, 'Remaining'),
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
