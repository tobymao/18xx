# frozen_string_literal: true

require 'view/actionable'

require 'engine/action/run_routes'

module View
  class RouteSelector < Snabberb::Component
    include Actionable

    needs :routes, store: true, default: []
    needs :selected_route, store: true, default: nil

    def render
      round = @game.round

      trains = round.current_entity.trains.map do |train|
        onclick = lambda do
          route = @routes.find { |t| t.train == train }
          unless route
            route = Engine::Route.new(@game.phase, train)
            store(:routes, @routes + [route])
          end
          store(:selected_route, route)
        end

        selected = @selected_route&.train == train

        style = {
          border: "solid #{selected ? '3px' : '1px'} rgba(0,0,0,0.2)",
          display: 'inline-block',
          cursor: selected ? 'none' : 'pointer',
        }

        h(:div, { style: style, on: { click: onclick } }, "Train: #{train.name}")
      end

      props = {}

      h(:div, props, [
        *trains,
        actions,
      ])
    end

    def actions
      submit = lambda do
        process_action(Engine::Action::RunRoutes.new(@game.current_entity, @routes))
        store(:routes, [])
      end

      reset = lambda do
        @selected_route.reset!
        store(:selected_route, @selected_route)
      end

      h(:div, [
        h(:button, { on: { click: submit } }, 'Submit'),
        h(:button, { on: { click: reset } }, 'Reset'),
      ])
    end
  end
end
