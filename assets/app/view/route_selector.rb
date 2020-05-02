# frozen_string_literal: true

require 'view/actionable'
require 'view/undo_and_pass'

module View
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

    def render
      trains = @game.round.current_entity.trains

      if !@selected_route && (train = trains[0])
        route = Engine::Route.new(@game.phase, train)
        store(:routes, @routes + [route], skip: true)
        store(:selected_route, route)
      end

      trains = trains.map do |train|
        onclick = lambda do
          unless (route = @routes.find { |t| t.train == train })
            route = Engine::Route.new(@game.phase, train)
            store(:routes, @routes + [route])
          end
          store(:selected_route, route)
        end

        selected = @selected_route&.train == train

        style = {
          border: "solid #{selected ? '4px' : '1px'} rgba(0,0,0,0.2)",
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

      h(:div, [
        h(UndoAndPass, pass: false),
        h(:table, { style: { 'text-align': 'left' } }, [
          h(:tr, [
           h(:th, 'Train'),
           h(:th, 'Stops'),
           h(:th, 'Revenue'),
           h(:th, 'Route')
          ]),
          *trains
        ]),
        actions,
      ])
    end

    def actions
      submit = lambda do
        process_action(Engine::Action::RunRoutes.new(@game.current_entity, active_routes))
        store(:routes, [], skip: true)
        store(:selected_route, nil, skip: true)
      end

      reset = lambda do
        @selected_route&.reset!
        store(:selected_route, @selected_route)
      end

      reset_all = lambda do
        @selected_route = nil
        store(:selected_route, @selected_route)
        store(:routes, [])
      end

      revenue = begin
                  @game.format_currency(active_routes.sum(&:revenue))
                rescue Engine::GameError
                  '(Invalid Route)'
                end
      h(:div, [
        h(:button, { on: { click: submit } }, 'Submit ' + revenue),
        h(:button, { style: { 'margin-left': '1rem' }, on: { click: reset } }, 'Reset Train'),
        h(:button, { style: { 'margin-left': '1rem' }, on: { click: reset_all } }, 'Reset All'),
      ])
    end
  end
end
