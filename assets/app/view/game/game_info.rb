# frozen_string_literal: true

require 'lib/settings'
require 'lib/publisher'
require 'lib/text'
require 'view/game/game_meta'

module View
  module Game
    class GameInfo < Snabberb::Component
      include Lib::Settings
      include Lib::Text

      needs :game
      needs :layout, default: nil

      def render
        @depot = @game.depot
        @dimmed_font_style = { style: { color: convert_hex_to_rgba(color_for(:font), 0.7) } }

        return if @layout && @depot.trains.empty?

        case @layout
        when :discarded_trains
          @depot.discarded.empty? ? 'No Trains in Bank Pool' : discarded_trains
        when :upcoming_trains
          @game.train_power? ? power_summary : h(TrainSchedule, game: @game)
        else
          h('div#game_info', render_body)
        end
      end

      def render_body
        if @depot.trains.empty?
          children = []
        else
          children = @game.train_power? ? power : trains
          children.concat(discarded_trains)
        end
        if @game.phase_valid?
          children.concat(phases)
        else
          children.concat(other_game_status)
        end
        children.concat(timeline) if timeline
        children.concat(endgame)
        children << h(GameMeta, game: @game)
      end

      def timeline
        return nil if @game.timeline.empty? && !@game.show_progress_bar?

        children = [h(:h3, 'Timeline')]
        children << progress_bar if @game.show_progress_bar?
        @game.timeline.each { |line| children << h(:p, line) } unless @game.timeline.empty?

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
          row_events = row_events.map(&:first).flat_map { |e| [h('span.nowrap', e), ', '] }[0..-2]

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
          extra << h(:td, row_events) unless phases_events.empty?

          tr_props = @game.phase.available?(phase[:name]) && phase != current_phase ? @dimmed_font_style : {}

          h(:tr, tr_props, [
            h(:td, (current_phase == phase ? '→ ' : '') + phase[:name]),
            h(:td, @game.info_on_trains(phase)),
            h(:td, phase[:operating_rounds]),
            h(:td, train_limit_to_h(phase[:train_limit])),
            h(:td, phase_props, phase_color.capitalize),
            *extra,
          ])
        end

        status_text = phases_events.uniq.map do |short, long|
          h(:tr, [h('td.nowrap', { style: { maxWidth: '30vw' } }, short), h(:td, long)])
        end

        extra = []
        extra << h(:th, 'New Corporation Size') if corporation_sizes

        unless status_text.empty?
          status_text = [h(:table, { style: { marginTop: '0.3rem' } }, [
            h(:thead, [
              h(:tr, [
                h(:th, 'Status'),
                h(:th, 'Description'),
                ]),
            ]),
            h(:tbody, status_text),
          ])]
          extra << h(:th, 'Status')
        end

        [
          h(:h3, 'Game Phases'),
          h(:div, { style: { overflowX: 'auto' } }, [
            h(:table, [
              h(:thead, [
                h(:tr, [
                  h(:th, 'Phase'),
                  h(:th, @game.on_train_header),
                  h(:th, { attrs: { title: "Number of #{@game.operation_round_name} Rounds" } },
                    @game.operation_round_short_name),
                  h(:th, @game.train_limit_header),
                  h(:th, 'Tiles'),
                  *extra,
                ]),
              ]),
              h(:tbody, rows),
            ]),
          ]),
          *status_text,
        ]
      end

      def train_limit_to_h(train_limit)
        return train_limit unless train_limit.is_a?(Hash)

        train_limit.map { |type, limit| h('span.nowrap', "#{type}: #{limit}") }
          .flat_map { |e| [e, ', '] }[0..-2]
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

      def trains
        rust_schedule, obsolete_schedule = rust_obsolete_schedule

        show_obsolete_schedule = !obsolete_schedule.keys.empty?
        show_upgrade = @depot.upcoming.any?(&:discount)
        show_available = @depot.upcoming.any?(&:available_on)
        events = []

        first_train = @depot.upcoming.first

        rows = @depot.trains.reject(&:reserved).group_by(&:sym).map do |sym, trains|
          remaining = @depot.upcoming.select { |t| t.sym == sym }
          train = trains.first
          discounts = train.discount&.group_by { |_k, v| v }&.map do |price, price_discounts|
            h('span.nowrap', "#{price_discounts.map(&:first).join(', ')} → #{@game.format_currency(price)}")
          end
          discounts = discounts.flat_map { |e| [e, ', '] }[0..-2] if discounts
          names_to_prices = train.names_to_prices

          event_text = []
          remaining.each.with_index do |train2, index|
            train2.events.each do |event|
              event_name = event['type']
              if @game.class::EVENTS_TEXT[event_name]
                events << event_name
                event_name = @game.class::EVENTS_TEXT[event_name][0]
              end

              event_text << if index.zero?
                              event_name
                            else
                              "#{event_name}(on #{ordinal(train2.index + 1)} train)"
                            end
            end
          end
          event_text = event_text.flat_map { |e| [h('span.nowrap', e), ', '] }[0..-2]
          name = (@game.info_available_train(first_train, train) ? '→ ' : '') + @game.info_train_name(train)

          train_content = [
            h(:td, name),
            h("td#{price_str_class}", @game.info_train_price(train)),
            h('td.center', "#{remaining.size} / #{trains.size}"),
          ]

          show_rusts_inline = true
          rusts = nil
          names_to_prices.keys.each do |key|
            next if !rust_schedule[key] && rust_schedule.keys.none? { |item| item.is_a?(Array) && item&.include?(key) }

            rusts ||= []

            if (rust = rust_schedule[key])
              rusts << rust.join(', ')
              next
            end

            # needed for 18CZ where a train can be rusted by multiple different trains
            trains_to_rust = rust_schedule.select { |k, _v| k&.include?(key) }.values.flatten.join(', ')
            rusts << "#{key} → #{trains_to_rust}"
            show_rusts_inline = false
          end

          train_content << h(:td, obsolete_schedule[train.name]&.join(', ') || '') if show_obsolete_schedule
          train_content << if show_rusts_inline
                             h(:td, rusts&.join(', ') || '')
                           else
                             h(:td, rusts&.map { |value| h(:div, value) } || '')
                           end

          train_content << h(:td, discounts) if show_upgrade
          train_content << h(:td, train.available_on) if show_available
          train_content << h(:td, event_text) unless event_text.empty?
          tr_props = remaining.empty? ? @dimmed_font_style : {}

          h(:tr, tr_props, train_content)
        end

        event_text = events.uniq.map do |sym|
          desc = @game.class::EVENTS_TEXT[sym]
          h(:tr, [h('td.nowrap', { style: { maxWidth: '30vw' } }, desc[0]), h(:td, desc[1])])
        end

        unless event_text.empty?
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
        upcoming_train_header << h(:th, 'Events') unless event_text.empty?

        [
          h(:h3, 'Trains'),
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

      def power
        props = {
          style: {
            textAlign: 'center',
            width: 'max-content',
          },
        }

        max = @game.class::MAX_PROGRESS

        [
          h(:h3, 'Power Progress'),
          h(:div, { style: { overflowX: 'auto' } }, [
            h(:table, [
              h(:tbody, [
                h(:tr, props, Array.new(max) { |p| h(:td, p + 1) }),
                h(:tr, props, Array.new(max) { |p| h(:td, @game.power_progress == (p + 1) ? '↑' : '') }),
              ]),
            ]),
          ]),
        ]
      end

      def price_str_class
        max_size = @game.depot.upcoming.group_by(&:name).map do |_name, trains|
          trains.first.names_to_prices.keys.size
        end.max
        max_size == 1 ? '.right' : ''
      end

      def discarded_trains
        if @depot.discarded.empty?
          table = h(:p, { style: { padding: '0 0.3rem' } }, 'None')
        else
          rows = @depot.discarded.group_by(&:name).map do |_sym, trains|
            train = trains.first
            h(:tr, [
              h(:td, train.name),
              h(:td, @game.format_currency(train.price)),
              h('td.right', trains.size),
            ])
          end

          table = h(:table, [
            h(:thead, [
              h(:tr, [
                h(:th, 'Type'),
                h(:th, 'Price'),
                h(:th, 'Available'),
              ]),
            ]),
            h(:tbody, rows),
          ])
        end

        if @layout == :discarded_trains
          h(:div, { style: { display: 'grid', justifyItems: 'center' } }, [
            h(:div, 'Trains in Bank Pool'),
            table,
          ])
        else
          [h(:h3, 'Trains in Bank Pool'), table]
        end
      end

      def progress_bar
        train_export = h(:div, [
          h(:img, {
              attrs: {
                src: '/icons/train_export.svg',
                width: '15px',
              },
            }),
        ])

        children = @game.progress_information.flat_map.with_index do |item, index|
          cells = []
          # the space is nut just a space but a &nbsp in unicode;
          cells << h(:div, cell_props(item[:type], @game.round_counter == index, item[:color]),
                     [h('div.center', item[:value] || ' '), h('div.nowrap', "#{item[:type]} #{item[:name]}")])
          if item[:exportAfter]
            cells << h(:div, cell_props(:Export), [
              item[:exportAfterValue] ? h(:div, item[:exportAfterValue]) : nil,
              train_export,
            ].compact)
          end
          cells
        end

        h(:div, { style: { display: 'flex', overflowX: 'auto' } }, children)
      end

      def cell_props(type, current, color = nil)
        bg_color, font_color, justify =
          case type
          when :SR, :PRE
            [color_for(:green), contrast_on(color_for(:green)), 'space-between']
          when :Export
            [color_for(:yellow), contrast_on(color_for(:yellow)), 'center']
          when :End
            [color_for(:blue), contrast_on(color_for(:blue)), 'space-between']
          else
            if color
              [color_for(color), contrast_on(color_for(color)), 'space-between']
            else
              [color_for(:bg2), color_for(:font2), 'space-between']
            end
          end

        props = {
          style: {
            display: 'flex',
            flexDirection: 'column',
            boxSizing: 'border-box',
            height: '55px',
            padding: '4px',
            border: '1px solid rgba(0,0,0,0.2)',
            justifyContent: justify,
            backgroundColor: bg_color,
            color: font_color,
          },
        }
        if current
          props[:style].merge!(
            {
              fontWeight: 'bold',
              border: "4px solid #{color_for(:red)}",
              padding: '1px 4px',
            }
          )
        end

        props
      end

      def endgame
        values = @game.game_end_check_values
        rows = values.map do |reason, timing|
          reason_str = @game.class::GAME_END_REASONS_TEXT[reason]
          if reason == :bankrupt
            reason_str = case @game.class::BANKRUPTCY_ENDS_GAME_AFTER
                         when :one
                           'Any '
                         when :all_but_one
                           'All but one '
                         end + reason_str
          end
          h(:tr, [
            h(:td, reason_str),
            h(:td, @game.class::GAME_END_REASONS_TIMING_TEXT[timing]),
          ])
        end

        table = h(:table, [
          h(:thead, [
            h(:tr, [
              h(:th, 'Reason'),
              h(:th, 'Timing'),
            ]),
          ]),
          h(:tbody, rows),
        ])
        [
         h(:h3, 'Reasons for End of Game'),
         table,
        ]
      end

      def power_summary
        title_props = {
          style: {
            padding: '0.4rem',
            backgroundColor: color_for(:bg2),
            color: color_for(:font2),
            fontStyle: 'italic',
          },
        }

        h('div#upcoming_trains.card', [
          h('div.title', title_props, 'Power'),
          h(:div, "Power Progress: #{@game.power_progress}"),
          h(:div, "Current power cost: #{@game.format_currency(@game.current_power_cost)}"),
          h(:div, "Next power cost: #{@game.format_currency(@game.next_power_cost)}"),
        ])
      end

      # Currently, only for Rolling Stock
      def other_game_status
        status = []

        unless @game.offering.empty?
          status << h(:h3, 'Offering')
          comps = @game.offering.map do |company|
            h(Company, company: company)
          end
          status << h(:div, comps)
        end

        status << h(:h3, 'Remaining Deck')
        if @game.company_deck.empty?
          status << h(:div, '(Empty)')
        else
          deck = @game.company_deck.reverse.map do |company|
            deck_item_style = {
              display: 'inline-block',
              backgroundColor: @game.company_colors(company)[0],
              padding: '4px',
              border: '1px solid black',
              height: '20px',
              margin: '4px',
            }
            h(:div, { style: deck_item_style })
          end
          status << h(:div, deck)
        end

        table_props = {
          style: {
            backgroundColor: 'white',
            color: 'black',
            margin: '0',
            border: '1px solid',
            borderCollapse: 'collapse',
          },
        }
        tr_props = {
          style: {
            border: '1px solid black',
          },
        }
        th_props = {
          style: {
            border: '1px solid black',
          },
        }

        status << h(:h3, 'Current Cost of Ownership')

        cost_card_props = {
          style: {
            display: 'inline-block',
            backgroundColor: @game.class::STAR_COLORS[@game.cost_level]&.[](0) || 'white',
            color: 'black',
            padding: '20px 60px 20px 60px',
            border: '1px solid',
            borderRadius: '10px',
          },
        }

        cost_rows = [h(:tr, tr_props, [h(:th, th_props, 'Level'), h(:th, th_props, 'Cost')])]
        @game.cost_table[@game.cost_level].each_with_index do |cost, idx|
          level_props = {
            style: {
              backgroundColor: @game.class::STAR_COLORS[idx + 1][0],
              border: '1px solid',
            },
          }
          td_props = {
            style: {
              border: '1px solid',
            },
          }
          cost_rows << h(:tr, tr_props, [
            h(:td, level_props, @game.level_symbol(idx + 1)),
            h(:td, td_props, @game.format_currency(cost)),
          ])
        end
        status << h(:div, cost_card_props, [
          h(:table, table_props, [
            h(:tbody, cost_rows),
          ]),
        ])

        # show target book/stars for each share price
        status << h(:h3, @game.share_card_description)
        sorted_prices = @game.prices.keys.sort
        share_cards = sorted_prices.map { |p| share_card(@game.prices[p]) }
        status << h(:div, share_cards)

        status
      end

      def share_card(price)
        share_card_props = {
          style: {
            display: 'inline-block',
            backgroundColor: 'white',
            color: 'black',
            border: '1px solid',
            borderRadius: '5px',
            padding: '5px',
            margin: '0 0 5px 5px',
          },
        }

        price_color = if price.price.zero?
                        'red'
                      elsif price.end_game_trigger?
                        'darkgreen'
                      else
                        'black'
                      end

        price_props = {
          style: {
            display: 'inline-block',
            color: price_color,
            fontSize: '200%',
            width: '50%',
          },
        }

        max_div_props = {
          style: {
            display: 'inline-block',
            backgroundColor: 'lightgray',
            fontSize: '70%',
            width: '30%',
            margin: '0 0 0 0.5rem',
          },
        }

        table_props = {
          style: {
            fontSize: '70%',
          },
        }

        th_props = {
          style: {
            backgroundColor: 'lightgray',
          },
        }

        children = []
        price_info = []
        price_info << h(:div, price_props, price.price)
        price_info << h(:div, max_div_props, "Max Div: #{@game.format_currency((price.price / 3).to_i)}")
        children << h(:div, price_info)

        rows = [h(:tr, [h(:th, th_props, 'Shares'), h(:th, th_props, 'Target')])]
        @game.share_card_array(price).each do |r|
          rows << h(:tr, [
            h(:td, r[0]),
            h(:td, r[1]),
          ])
        end
        children << h(:div, [
          h(:table, table_props, [
            h(:tbody, rows),
          ]),
        ])

        h(:div, share_card_props, children)
      end
    end
  end
end
