# frozen_string_literal: true

require 'lib/color'

module View
  module Game
    class GameInfo < Snabberb::Component
      needs :game
      needs :layout, default: nil

      def render
        @depot = @game.depot

        if @layout == :discarded_trains
          @depot.discarded.empty? ? '' : discarded_trains
        else
          h(:div, { style: { overflow: 'auto' } }, [render_body])
        end
      end

      def render_body
        children = [h(:div, [upcoming_trains])]

        unless @depot.discarded.empty?
          props = {
            style: {
              'margin-top': '1rem',
            },
          }

          children << h(:div, props, [
            discarded_trains,
          ])
        end

        children << phases
        children << game_info

        h(:div, children)
      end

      def game_info
        props = {
          style: {
            'margin-top': '1rem',
          },
        }
        children = []

        if (publisher = @game.class::GAME_PUBLISHER)
          children << h(:div, props, [
              'Published by ',
              h(:a, { attrs: { href: publisher[:url] } }, publisher[:name]),
            ])
        end
        children << h(:div, props, "Designed by #{@game.class::GAME_DESIGNER}") if @game.class::GAME_DESIGNER
        if @game.class::GAME_RULES_URL
          children << h(:div, props, [h(:a, { attrs: { href: @game.class::GAME_RULES_URL } }, 'Rules')])
        end

        h(:div, children)
      end

      def phases
        td_props = {
          style: {
            padding: '0 1rem',
          },
        }

        current_phase = @game.phase.current
        rows = @game.phase.phases.map do |phase|
          phase_color = Array(phase[:tiles]).last
          phase_props = {
            style: {
              padding: '0 1rem',
            },
          }
          if Part::MultiRevenue::COLOR.include?(phase_color)
            phase_props[:style]['background-color'] =
              Lib::Color.convert_hex_to_rgba(Part::MultiRevenue::COLOR[phase_color], 0.4)
          end

          event_text = []
          event_text << 'Can Buy Companies' if phase[:buy_companies]
          phase[:events]&.each do |name, _value|
            event_text << (@game.class::EVENTS_TEXT[name] ? "#{@game.class::EVENTS_TEXT[name][0]}*" : name)
          end

          h(:tr, [
            h(:td, td_props, phase[:name] + (current_phase == phase ? ' (Current) ' : '')),
            h(:td, td_props, phase[:operating_rounds]),
            h(:td, td_props, phase[:train_limit]),
            h(:td, phase_props, phase_color.capitalize),
            h(:td, td_props, event_text.join(',')),
          ])
        end

        phase_text = @game.class::EVENTS_TEXT.map do |_sym, desc|
          h(:tr, [h(:td, td_props, desc[0]), h(:td, td_props, desc[1])])
        end

        if phase_text.any?
          phase_text = [h(:table, [
            h(:tr, [
              h(:th, td_props, 'Event'),
              h(:th, td_props, 'Description'),
              ]),
            *phase_text,
          ])]
        end

        props = {
          style: { 'margin-top': '1rem' },
        }
        h(:div, props, [
          h(:div, 'Game Phases'),
          h(:table, [
            h(:tr, [
              h(:th, td_props, 'Phase'),
              h(:th, td_props.merge(attrs: { title: 'Number of Operating Rounds' }), '# OR'),
              h(:th, td_props, 'Train Limit'),
              h(:th, td_props, 'Tiles'),
              h(:th, td_props, 'Events'),
            ]),
            *rows,
          ]),
          *phase_text,
        ])
      end

      def upcoming_trains
        td_props = {
          style: {
            padding: '0 1rem',
          },
        }

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
            price_discounts.map(&:first).join(',') + ' => ' + @game.format_currency(price)
          end
          names_to_prices = train.names_to_prices

          h(:tr, [
            h(:td, td_props, names_to_prices.keys.join(',')),
            h(:td, td_props, names_to_prices.values.map { |p| @game.format_currency(p) }.join(',')),
            h(:td, td_props, trains.size),
            h(:td, td_props, obsolete_schedule[name]&.join(',') || 'None'),
            h(:td, td_props, rust_schedule[name]&.join(',') || 'None'),
            h(:td, td_props, discounts&.join(' ')),
            h(:td, td_props, train.available_on),
          ])
        end

        h(:div, [
          h(:div, 'Upcoming Trains'),
          h(:table, [
            h(:tr, [
              h(:th, td_props, 'Type'),
              h(:th, td_props, 'Price'),
              h(:th, td_props, 'Remaining'),
              h(:th, td_props, 'Phases out'),
              h(:th, td_props, 'Rusts'),
              h(:th, td_props, 'Upgrade Discount'),
              h(:th, td_props.merge(attrs: { title: 'Available after purchase of first train of type' }), 'Available'),
            ]),
            *rows,
          ]),
        ])
      end

      def discarded_trains
        td_props = {
          style: {
            padding: '0 1rem',
          },
        }

        rows = @depot.discarded.map do |train|
          h(:tr, [
            h(:td, td_props, train.name),
            h(:td, td_props, @game.format_currency(train.price)),
          ])
        end

        h(:div, [
          h(:div, 'Trains in Bank Pool'),
          h(:table, [
            h(:tr, [
              h(:th, td_props, 'Type'),
              h(:th, td_props, 'Price'),
            ]),
            *rows,
          ]),
        ])
      end
    end
  end
end
