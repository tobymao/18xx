# frozen_string_literal: true

require 'lib/color'
require 'lib/settings'
require 'view/game/actionable'
require 'view/game/undo_and_pass'

module View
  module Game
    class RouteSelector < Snabberb::Component
      include Actionable
      include Lib::Color
      include Lib::Settings

      needs :routes, store: true, default: []
      needs :selected_route, store: true, default: nil

      # Get routes that have a length greater than zero
      # Due to the way this and the map hook up routes needs to have
      # an entry, but that route is not valid at zero length
      def active_routes
        @routes.select { |r| r.connections.any? }
      end

      def generate_last_routes!
        trains = @game.round.current_entity.runnable_trains
        operating = @game.round.current_entity.operating_history
        last_run = operating[operating.keys.max]&.routes
        return [] unless last_run

        last_run.map do |train, connections|
          next unless trains.include?(train)

          connections = connections&.map do |ids|
            ids.map { |id| @game.hex_by_id(id) }
          end
          # A future enhancement to this could be to find trains and move the routes over
          @routes << Engine::Route.new(@game, @game.phase, train, connection_hexes: connections, routes: @routes)
        end.compact
      end

      def render
        trains = @game.round.current_entity.runnable_trains

        train_help =
          if (helps = @game.train_help(trains)).any?
            h('ul',
              { style: { 'padding-left': '20px' } },
              helps.map { |help| h('li', [h('p.small_font', help)]) })
          end

        if @routes.empty? && generate_last_routes!.any?
          description = 'Prior routes are autofilled.'
          @selected_route = @routes.first
          store(:routes, @routes, skip: true)
          store(:selected_route, @selected_route, skip: true)
        end

        if !@selected_route && (first_train = trains[0])
          route = Engine::Route.new(@game, @game.phase, first_train, routes: @routes)
          @routes << route
          store(:routes, @routes, skip: true)
          store(:selected_route, route, skip: true)
        end

        trains = trains.flat_map do |train|
          onclick = lambda do
            unless (route = @routes.find { |t| t.train == train })
              route = Engine::Route.new(@game, @game.phase, train, routes: @routes)
              @routes << route
              store(:routes, @routes)
            end
            store(:selected_route, route)
          end

          selected = @selected_route&.train == train

          style = {
            border: "solid 3px #{selected ? color_for(:font) : color_for(:bg)}",
            display: 'inline-block',
            cursor: selected ? 'default' : 'pointer',
            margin: '0.1rem 0rem',
            padding: '3px 6px',
            minWidth: '1.5rem',
            textAlign: 'center',
            whiteSpace: 'nowrap',
          }

          route = active_routes.find { |t| t.train == train }
          children = []
          if route
            revenue, invalid = begin
                                 [@game.format_currency(route.revenue), nil]
                               rescue Engine::GameError => e
                                 ['N/A', e.to_s]
                               end

            bg_color = route_prop(@routes.index(route), :color)
            style[:backgroundColor] = bg_color
            style[:color] = contrast_on(bg_color)

            td_props = { style: { paddingRight: '0.8rem' } }

            children << h('td.right', td_props, route.distance)
            children << h('td.right', td_props, revenue)
            children << h(:td, route.hexes.map(&:name).join(' '))
          elsif !selected
            style[:border] = '1px solid'
            style[:padding] = '5px 8px'
          end

          invalid_props = {
            attrs: {
              colspan: '4',
            },
            style: {
              padding: '0 0 0.4rem 0.4rem',
            },
          }
          [
            h(:tr, [h(:td, [h(:div, { style: style, on: { click: onclick } }, train.name)]), *children]),
            invalid ? h(:tr, [h(:td, invalid_props, invalid)]) : '',
          ]
        end

        div_props = {
          key: 'route_selector',
          hook: {
            destroy: -> { cleanup },
          },
        }
        table_props = {
          style: {
            marginTop: '0.5rem',
            textAlign: 'left',
          },
        }
        th_route_props = {
          style: {
            width: '100%',
          },
        }

        h(:div, div_props, [
          h(:h3, { style: { margin: '0.5rem 0 0.2rem' } }, 'Select Routes'),
          h('div.small_font', description),
          h('div.small_font', 'Click revenue centers, again to cycle paths.'),
          train_help,
          h(:table, table_props, [
            h(:thead, [
              h(:tr, [
                h(:th, 'Train'),
                h(:th, 'Stops'),
                h(:th, 'Revenue'),
                h(:th, th_route_props, 'Route'),
              ]),
            ]),
            h(:tbody, trains),
          ]),
          actions,
        ].compact)
      end

      def cleanup
        store(:selected_route, nil, skip: true)
        store(:routes, [], skip: true)
      end

      def actions
        submit = lambda do
          process_action(Engine::Action::RunRoutes.new(@game.current_entity, routes: active_routes))
          cleanup
        end

        clear = lambda do
          @selected_route&.reset!
          store(:selected_route, @selected_route)
        end

        reset_all = lambda do
          @selected_route = nil
          store(:selected_route, @selected_route)
          @routes.clear
          store(:routes, @routes)
        end

        clear_all = lambda do
          @routes.each(&:reset!)
          store(:routes, @routes)
        end

        submit_style = {
          minWidth: '6.5rem',
          marginTop: '1rem',
          padding: '0.2rem 0.5rem',
        }

        revenue = begin
                    @game.format_currency(@game.routes_revenue(active_routes))
                  rescue Engine::GameError
                    '(Invalid Route)'
                  end
        h(:div, { style: { overflow: 'auto', marginBottom: '1rem' } }, [
          h(:div, [
            h('button.small', { on: { click: clear } }, 'Clear Train'),
            h('button.small', { on: { click: clear_all } }, 'Clear All'),
            h('button.small', { on: { click: reset_all } }, 'Reset'),
          ]),
          h(:button, { style: submit_style, on: { click: submit } }, 'Submit ' + revenue),
        ])
      end
    end
  end
end
