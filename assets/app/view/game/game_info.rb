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
        children.concat(phases)
        children.concat(timeline) if timeline
        children.concat(game_info)
      end

      def timeline
        return nil if @game.class::TIMELINE.empty?

        children = [h(:h3, 'Timeline')]

        @game.class::TIMELINE.each do |line|
          children << h(:p, line)
        end

        children
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
        children << h(:p, "Implemented by #{@game.class::GAME_IMPLEMENTER}") if @game.class::GAME_IMPLEMENTER
        if @game.class::GAME_RULES_URL.is_a?(Hash)
          @game.class::GAME_RULES_URL.each do |desc, url|
            children << h(:p, [h(:a, { attrs: { href: url } }, desc)])
          end
        else
          children << h(:p, [h(:a, { attrs: { href: @game.class::GAME_RULES_URL } }, 'Rules')])
        end
        if @game.optional_rules.any?
          children << h(:h3, 'Optional Rules Used')
          @game.class::OPTIONAL_RULES.each do |o_r|
            next unless @game.optional_rules.include?(o_r[:sym])

            children << h(:p, " * #{o_r[:short_name]}: #{o_r[:desc]}")
          end
        end

        if @game.class::GAME_INFO_URL
          children << h(:p, [h(:a, { attrs: { href: @game.class::GAME_INFO_URL } }, 'More info')])
        end

        children
      end

      def phases
        current_phase = @game.phase.current
        phases_events = []

        corporation_sizes = true if @game.phase.phases.any? { |c| c[:corporation_sizes] }

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

          extra = []
          extra << h(:td, phase[:corporation_sizes].join(', ')) if corporation_sizes

          h(:tr, [
            h(:td, (current_phase == phase ? '→ ' : '') + phase[:name]),
            h(:td, phase[:on]),
            h(:td, phase[:operating_rounds]),
            h(:td, phase[:train_limit]),
            h(:td, phase_props, phase_color.capitalize),
            *extra,
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

        extra = []
        extra << h(:th, 'New Corporation Size') if corporation_sizes

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
                  *extra,
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

        show_obsolete_schedule = obsolete_schedule.keys.any?
        events = []

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
              if @game.class::EVENTS_TEXT[event_name]
                events << event_name
                event_name = "#{@game.class::EVENTS_TEXT[event_name][0]}*"
              end

              event_text << if index.zero?
                              event_name
                            else
                              "#{event_name}(on #{ordinal(index + 1)} train)"
                            end
              event_text << event_name unless event_text.include?(event_name)
            end
          end

          upcoming_train_content = [
            h(:td, names_to_prices.keys.join(', ')),
            h('td.right', names_to_prices.values.map { |p| @game.format_currency(p) }.join(', ')),
            h(:td, trains.size),
          ]
          upcoming_train_content << h(:td, obsolete_schedule[name]&.join(', ') || 'None') if show_obsolete_schedule
          upcoming_train_content.concat([
            h(:td, rust_schedule[name]&.join(', ') || 'None'),
            h(:td, discounts&.join(' ')),
            h(:td, train.available_on),
            h(:td, event_text.join(', ')),
])
          h(:tr, upcoming_train_content)
        end

        event_text = @game.class::EVENTS_TEXT
          .select { |sym, _desc| events.include?(sym) }
          .map do |_sym, desc|
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

        upcoming_train_header = [
          h(:th, 'Type'),
          h(:th, 'Price'),
          h(:th, 'Remaining'),
        ]

        upcoming_train_header << h(:th, 'Phases out') if show_obsolete_schedule
        upcoming_train_header.concat([
          h(:th, 'Rusts'),
          h(:th, 'Upgrade Discount'),
          h(:th, { attrs: { title: 'Available after purchase of first train of type' } }, 'Available'),
          h(:th, 'Events'),
        ])
        [
          h(:h3, 'Upcoming Trains'),
          h(:div, { style: { overflowX: 'auto' } }, [
            h(:table, [
              h(:thead, [
                h(:tr, upcoming_train_header),
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
