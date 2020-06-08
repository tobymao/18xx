# frozen_string_literal: true

require 'lib/color'

module View
  module Game
    class GameInfo < Snabberb::Component
      needs :game

      def render
        @depot = @game.depot

        h(:div,  { style: {
          overflow: 'auto',
          margin: '0 -1rem',
        } }, [
          render_body,
          ])
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

        h(:div, {}, children)
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
              "#{@game.class.title} is used with kind permission from ",
              h(:a, { attrs: { href: publisher::URL } }, publisher::NAME),
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

          buy_text = if phase[:buy_companies]
                       'Can Buy'
                     elsif phase[:events]&.include?(:close_companies)
                       'Close'
                     else
                       ''
                     end

          h(:tr, [
            h(:td, td_props, phase[:name] + (current_phase == phase ? ' (Current) ' : '')),
            h(:td, td_props, phase[:operating_rounds]),
            h(:td, td_props, phase[:train_limit]),
            h(:td, phase_props, phase_color.capitalize),
            h(:td, td_props, buy_text),
          ])
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
              h(:th, td_props, 'Companies'),
            ]),
            *rows,
          ]),
        ])
      end

      def upcoming_trains
        td_props = {
          style: {
            padding: '0 1rem',
          },
        }

        rust_schedule = {}
        @depot.trains.group_by(&:name).each do |name, trains|
          rust_schedule[trains.first.rusts_on] = Array(rust_schedule[trains.first.rusts_on]).append(name)
        end

        rows = @depot.upcoming.group_by(&:name).map do |name, trains|
          train = trains.first
          discounts = train.discount&.group_by { |_k, v| v }&.map do |price, price_discounts|
            price_discounts.map(&:first).join(',') + ' => ' + @game.format_currency(price)
          end
          h(:tr, [
            h(:td, td_props, name),
            h(:td, td_props, @game.format_currency(train.price)),
            h(:td, td_props, trains.size),
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
          h(:div, 'In bank pool:'),
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
