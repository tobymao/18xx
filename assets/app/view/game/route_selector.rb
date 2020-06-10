# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/undo_and_pass'

module View
  module Game
    class RouteSelector < Snabberb::Component
      include Actionable

      needs :routes, store: true, default: []
      needs :selected_route, store: true, default: nil

      # Get routes that have a length greater than zero
      # Due to the way this and the map hook up routes needs to have
      # an entry, but that route is not valid at zero length
      def active_routes
        @routes.select { |r| r.connections.any? }
      end

      def generate_last_routes!
        trains = @game.round.current_entity.trains
        operating = @game.round.current_entity.operating_history
        last_run = operating[operating.keys.max]&.routes
        return [] unless last_run

        last_run.map do |train, connections|
          next unless trains.include?(train)

          connections = connections&.map do |ids|
            ids.map { |id| @game.hex_by_id(id) }
          end
          # A future enhancement to this could be to find trains and move the routes over
          @routes << Engine::Route.new(@game.phase, train, connection_hexes: connections, routes: @routes)
        end.compact
      end

      def render
        trains = @game.round.current_entity.trains

        description = 'Select routes'
        if @routes.empty? && generate_last_routes!.any?
          description += ': prior routes are autofilled'
          @selected_route = @routes.first
          store(:routes, @routes, skip: true)
          store(:selected_route, @selected_route, skip: true)
        end

        if !@selected_route && (first_train = trains[0])
          route = Engine::Route.new(@game.phase, first_train, routes: @routes)
          @routes << route
          store(:routes, @routes, skip: true)
          store(:selected_route, route, skip: true)
        end

        trains = trains.map do |train|
          onclick = lambda do
            unless (route = @routes.find { |t| t.train == train })
              route = Engine::Route.new(@game.phase, train, routes: @routes)
              @routes << route
              store(:routes, @routes)
            end
            store(:selected_route, route)
          end

          selected = @selected_route&.train == train

          style = {
            border: "solid #{selected ? '4px' : '1px'} currentColor",
            display: 'inline-block',
            cursor: selected ? 'default' : 'pointer',
            margin: '0.5rem 0.5rem 0.5rem 0',
            padding: '0.5rem',
          }

          route = active_routes.find { |t| t.train == train }
          children = []
          if route
            revenue, invalid = begin
                                 [@game.format_currency(route.revenue), nil]
                               rescue Engine::GameError => e
                                 ['N/A', e.to_s]
                               end

            style['background-color'] = Part::Track::ROUTE_COLORS[@routes.index(route)]
            style['color'] = 'white'
            children << h(:td, route.stops.size)
            children << h(:td, revenue)
            children << h(:td, if invalid
                                 "#{route.hexes.map(&:name).join(', ')} (#{invalid})"
                               else
                                 route.hexes.map(&:name).join(', ')
                               end)
          end
          h(:tr, [h(:td, { style: style, on: { click: onclick } }, "Train: #{train.name}"), *children])
        end

        props = {
          key: 'route_selector',
          hook: {
            destroy: -> { cleanup },
          },
        }

        h(:div, props, [
          h(UndoAndPass, pass: false),
          h('div.margined', description),
          h(:table, { style: { 'text-align': 'left' } }, [
            h(:tr, [
              h(:th, 'Train'),
              h(:th, 'Stops'),
              h(:th, 'Revenue'),
              h(:th, 'Route (Click revenue centers. Click again to cycle path)'),
            ]),
            *trains,
          ]),
          actions,
        ])
      end

      def cleanup
        store(:selected_route, nil, skip: true)
        store(:routes, [], skip: true)
      end

      def actions
        submit = lambda do
          process_action(Engine::Action::RunRoutes.new(@game.current_entity, active_routes))
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
          @routes.each { |route| route&.reset! }
          store(:routes, @routes)
        end

        revenue = begin
                    @game.format_currency(active_routes.sum(&:revenue))
                  rescue Engine::GameError
                    '(Invalid Route)'
                  end
        h(:div, [
          h('button.button', { on: { click: submit } }, 'Submit ' + revenue),
          h('button.button', { style: { 'margin-left': '0.5rem' }, on: { click: clear } }, 'Clear Train'),
          h('button.button', { style: { 'margin-left': '0.5rem' }, on: { click: clear_all } }, 'Clear All'),
          h('button.button', { style: { 'margin-left': '0.5rem' }, on: { click: reset_all } }, 'Reset'),
        ])
      end
    end
  end
end
