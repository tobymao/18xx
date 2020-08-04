# frozen_string_literal: true

require 'lib/color'
require 'lib/settings'
require 'lib/text'

module View
  module Game
    class GameInfo < Snabberb::Component
      include Lib::Color
      include Lib::Settings
      include Lib::Text

      needs :game
      needs :layout, default: nil

      def render
        @depot = @game.depot

        if @layout == :discarded_trains
          @depot.discarded.empty? ? '' : discarded_trains
        else
          h('div#game_info', render_body)
        end
      end

      def render_body
        children = upcoming_trains
        children.concat(discarded_trains) if @depot.discarded.any?
        children.concat(phases, game_info)
      end

      def game_info
        children = [h(:h3, 'Game Info')]

        if (publisher = @game.class::GAME_PUBLISHER)
          children << h(:p, [
              'Published by ',
              h(:a, { attrs: { href: publisher[:url] } }, publisher[:name]),
            ])
        end
        children << h(:p, "Designed by #{@game.class::GAME_DESIGNER}") if @game.class::GAME_DESIGNER
        if @game.class::GAME_RULES_URL
          children << h(:p, [h(:a, { attrs: { href: @game.class::GAME_RULES_URL } }, 'Rules')])
        end

        if @game.class::GAME_INFO_URL
          children << h(:p, [h(:a, { attrs: { href: @game.class::GAME_INFO_URL } }, 'More info')])
        end

        children
      end

      def phases
        current_phase = @game.phase.current
        phases_events = []
        rows = @game.phase.phases.map do |phase|
          row_events = []

          phase[:status]&.each do |status|
            row_events << @game.class::STATUS_TEXT[status] if @game.class::STATUS_TEXT[status]
          end
          phases_events.concat(row_events)

          phase_color = Array(phase[:tiles]).last
          bg_color = color_for(phase_color)
          phase_props = {
            style: {
              backgroundColor: bg_color,
              color: contrast_on(bg_color),
            },
          }

          h(:tr, [
            h(:td, (current_phase == phase ? '→ ' : '') + phase[:name]),
            h(:td, phase[:on]),
            h(:td, phase[:operating_rounds]),
            h(:td, phase[:train_limit]),
            h(:td, phase_props, phase_color.capitalize),
            h(:td, row_events.map(&:first).join(', ')),
          ])
        end

        status_text = phases_events.uniq.map do |short, long|
          h(:tr, [h(:td, short), h(:td, long)])
        end

        if status_text.any?
          status_text = [h(:table, [
            h(:thead, [
              h(:tr, [
                h(:th, 'Status'),
                h(:th, 'Description'),
                ]),
            ]),
            h(:tbody, status_text),
          ])]
        end

        [
          h(:h3, 'Game Phases'),
          h(:div, { style: { overflowX: 'auto' } }, [
            h(:table, [
              h(:thead, [
                h(:tr, [
                  h(:th, 'Phase'),
                  h(:th, 'On Train'),
                  h(:th, { attrs: { title: 'Number of Operating Rounds' } }, 'ORs'),
                  h(:th, 'Train Limit'),
                  h(:th, 'Tiles'),
                  h(:th, 'Status'),
                ]),
              ]),
              h('tbody.zebra', rows),
            ]),
          ]),
          *status_text,
        ]
      end

      def upcoming_trains
        rust_schedule = {}
        obsolete_schedule = {}
        @depot.trains.group_by(&:name).each do |name, trains|
          first = trains.first
          rust_schedule[first.rusts_on] = Array(rust_schedule[first.rusts_on]).append(name)
          obsolete_schedule[first.obsolete_on] = Array(obsolete_schedule[first.obsolete_on]).append(name)
        end

        rows = @depot.upcoming.group_by(&:name).map do |name, trains|
          train = trains.first
          discounts = train.discount&.group_by { |_k, v| v }&.map do |price, price_discounts|
            price_discounts.map(&:first).join(', ') + ' → ' + @game.format_currency(price)
          end
          names_to_prices = train.names_to_prices

          event_text = []
          trains.each.with_index do |train2, index|
            train2.events.each do |event|
              event_name = event['type']
              event_name = "#{@game.class::EVENTS_TEXT[event_name][0]}*" if @game.class::EVENTS_TEXT[event_name]

              event_text << if index.zero?
                              event_name
                            else
                              "#{event_name}(on #{ordinal(index + 1)} train)"
                            end
              event_text << event_name unless event_text.include?(event_name)
            end
          end

          h(:tr, [
            h(:td, names_to_prices.keys.join(', ')),
            h('td.right', names_to_prices.values.map { |p| @game.format_currency(p) }.join(', ')),
            h(:td, trains.size),
            h(:td, obsolete_schedule[name]&.join(', ') || 'None'),
            h(:td, rust_schedule[name]&.join(', ') || 'None'),
            h(:td, discounts&.join(' ')),
            h(:td, train.available_on),
            h(:td, event_text.join(', ')),
          ])
        end

        event_text = @game.class::EVENTS_TEXT.map do |_sym, desc|
          h(:tr, [h(:td, desc[0]), h(:td, desc[1])])
        end

        if event_text.any?
          event_text = [h(:table, [
            h(:thead, [
              h(:tr, [
                h(:th, 'Event'),
                h(:th, 'Description'),
                ]),
            ]),
            h(:tbody, event_text),
          ])]
        end

        [
          h(:h3, 'Upcoming Trains'),
          h(:div, { style: { overflowX: 'auto' } }, [
            h(:table, [
              h(:thead, [
                h(:tr, [
                  h(:th, 'Type'),
                  h(:th, 'Price'),
                  h(:th, 'Remaining'),
                  h(:th, 'Phases out'),
                  h(:th, 'Rusts'),
                  h(:th, 'Upgrade Discount'),
                  h(:th, { attrs: { title: 'Available after purchase of first train of type' } }, 'Available'),
                  h(:th, 'Events'),
                ]),
              ]),
              h('tbody.zebra', rows),
            ]),
          ]),
          *event_text,
        ]
      end

      def discarded_trains
        rows = @depot.discarded.map do |train|
          h(:tr, [
            h(:td, train.name),
            h(:td, @game.format_currency(train.price)),
          ])
        end

        table = h(:table, [
          h(:thead, [
            h(:tr, [
              h(:th, 'Type'),
              h(:th, 'Price'),
            ]),
          ]),
          h(:tbody, rows),
        ])

        if @layout == :discarded_trains
          h(:div, { style: { display: 'grid', justifyItems: 'center' } }, [
            h(:div, 'Trains in Bank Pool'),
            table,
          ])
        else
          [h(:h3, 'Trains in Bank Pool'), table]
        end
      end
    end
  end
end
