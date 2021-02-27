# frozen_string_literal: true

require 'lib/color'
require 'lib/settings'
require 'lib/publisher'
require 'lib/text'
require 'view/game/game_meta'

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
        elsif @layout == :upcoming_trains
          upcoming_trains_card
        else
          h('div#game_info', render_body)
        end
      end

      def render_body
        children = upcoming_trains
        children.concat(discarded_trains) if @depot.discarded.any?
        children.concat(phases)
        children.concat(timeline) if timeline
        children << h(GameMeta, game: @game)
      end

      def timeline
        return nil if @game.timeline.empty?

        children = [h(:h3, 'Timeline')]

        @game.timeline.each do |line|
          children << h(:p, line)
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

          train_limit = phase[:train_limit]
          train_limit = @game.phase.train_limit_to_s(train_limit)

          h(:tr, [
            h(:td, (current_phase == phase ? '→ ' : '') + phase[:name]),
            h(:td, @game.info_on_trains(phase)),
            h(:td, phase[:operating_rounds]),
            h(:td, train_limit),
            h(:td, phase_props, phase_color.capitalize),
            *extra,
            h(:td, row_events.map(&:first).join(', ')),
          ])
        end

        status_text = phases_events.uniq.map do |short, long|
          h(:tr, [h(:td, short), h(:td, long)])
        end

        if status_text.any?
          status_text = [h(:table, { style: { marginTop: '0.3rem' } }, [
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

      def rust_obsolete_schedule
        rust_schedule = {}
        obsolete_schedule = {}
        @depot.trains.group_by(&:name).each do |_name, trains|
          first = trains.first
          first.variants.each do |name, train_variant|
            unless Array(rust_schedule[train_variant[:rusts_on]]).include?(name)
              rust_schedule[train_variant[:rusts_on]] =
                Array(rust_schedule[train_variant[:rusts_on]]).append(name)
            end
            unless Array(obsolete_schedule[train_variant[:obsolete_on]]).include?(name)
              obsolete_schedule[train_variant[:obsolete_on]] =
                Array(obsolete_schedule[train_variant[:obsolete_on]]).append(name)
            end
          end
        end
        [rust_schedule, obsolete_schedule]
      end

      def upcoming_trains_card
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
            margin: '0.3rem 0 0.4rem',
            display: 'grid',
            justifyItems: 'center',
          },
        }

        rust_schedule, obsolete_schedule = rust_obsolete_schedule
        trs = @game.depot.upcoming.group_by(&:name).map do |name, trains|
          names_to_prices = trains.first.names_to_prices
          events = []
          events << h('div.left', "rusts #{rust_schedule[name].join(', ')}") if rust_schedule[name]
          events << h('div.left', "obsoletes #{obsolete_schedule[name].join(', ')}") if obsolete_schedule[name]
          tds = [h(:td, names_to_prices.keys.join(', ')),
                 h("td#{price_str_class}", names_to_prices.values.map { |p| @game.format_currency(p) }.join(', ')),
                 h('td.right', "×#{trains.size}")]
          tds << h('td.right', events) if events.size.positive?

          h(:tr, tds)
        end
        trs ||= 'None'

        h('div#upcoming_trains.card', [
          h('div.title', title_props, 'Upcoming Trains'),
          h(:div, body_props, [
            h(:table, [h(:tbody, trs)]),
          ]),
        ])
      end

      def upcoming_trains
        rust_schedule, obsolete_schedule = rust_obsolete_schedule

        show_obsolete_schedule = obsolete_schedule.keys.any?
        show_upgrade = @depot.upcoming.any?(&:discount)
        show_available = @depot.upcoming.any?(&:available_on)
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
            h("td#{price_str_class}", names_to_prices.values.map { |p| @game.format_currency(p) }.join(', ')),
            h('td.center', trains.size),
          ]

          show_rusts_inline = true
          rusts = nil
          names_to_prices.keys.each do |key|
            next if !rust_schedule[key] && rust_schedule.keys.none? { |item| item&.is_a?(Array) && item&.include?(key) }

            rusts ||= []

            if (rust = rust_schedule[key])
              rusts << rust.join(', ')
              next
            end

            # needed for 18CZ where a train can be rusted by multiple different trains
            trains_to_rust = rust_schedule.select { |k, _v| k&.include?(key) }.values.flatten.join(', ')
            rusts << "#{key} => #{trains_to_rust}"
            show_rusts_inline = false
          end

          upcoming_train_content << h(:td, obsolete_schedule[name]&.join(', ') || '') if show_obsolete_schedule
          upcoming_train_content << if show_rusts_inline
                                      h(:td, rusts&.join(', ') || '')
                                    else
                                      h(:td,
                                        rusts&.map do |value|
                                          h(:div, { style: { paddingBottom: '0.1rem' } }, value)
                                        end || '')
                                    end

          upcoming_train_content << h(:td, discounts&.join(' ')) if show_upgrade
          upcoming_train_content << h(:td, train.available_on) if show_available
          upcoming_train_content << h(:td, event_text.join(', '))
          h(:tr, upcoming_train_content)
        end

        event_text = @game.class::EVENTS_TEXT
          .select { |sym, _desc| events.include?(sym) }
          .map do |_sym, desc|
            h(:tr, [h(:td, desc[0]), h(:td, desc[1])])
          end

        if event_text.any?
          event_text = [h(:table, { style: { marginTop: '0.3rem' } }, [
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
        upcoming_train_header << h(:th, 'Rusts')
        upcoming_train_header << h(:th, 'Upgrade Discount') if show_upgrade
        if show_available
          upcoming_train_header << h(:th,
                                     { attrs: { title: 'Available after purchase of first train of type' } },
                                     'Available')
        end
        upcoming_train_header << h(:th, 'Events')

        [
          h(:h3, 'Upcoming Trains'),
          h(:div, { style: { overflowX: 'auto' } }, [
            h(:table, [
              h(:thead, [
                h(:tr, upcoming_train_header),
              ]),
              h(:tbody, rows),
            ]),
          ]),
          *event_text,
        ]
      end

      def price_str_class
        max_size = @game.depot.upcoming.group_by(&:name).map do |_name, trains|
          trains.first.names_to_prices.keys.size
        end.max
        max_size == 1 ? '.right' : ''
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
