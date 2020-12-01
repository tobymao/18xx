# frozen_string_literal: true

require '../lib/storage'

module View
  module Game
    class MapControls < Snabberb::Component
      needs :show_coords, default: true, store: true
      needs :show_location_names, default: true, store: true
      needs :show_starting_map, default: false, store: true
      needs :historical_routes, default: [], store: true
      needs :game, default: nil, store: true

      def render
        children = [
          location_names_controls,
          hex_coord_controls,
          starting_map_controls,
          *route_controls,
        ].compact

        h(:div, children)
      end

      def location_names_controls
        show_hide = @show_location_names ? 'Hide' : 'Show'
        text = "#{show_hide} Location Names"

        on_click = lambda do
          new_value = !@show_location_names
          Lib::Storage['show_location_names'] = new_value
          store(:show_location_names, new_value)
        end

        render_button(text, on_click)
      end

      def hex_coord_controls
        show_hide = @show_coords ? 'Hide' : 'Show'
        text = "#{show_hide} Hex Coordinates"

        on_click = lambda do
          new_value = !@show_coords
          Lib::Storage['show_coords'] = new_value
          store(:show_coords, new_value)
        end

        render_button(text, on_click)
      end

      def starting_map_controls
        text = @show_starting_map ? 'Show Current Map' : 'Show Starting Map'

        on_click = lambda do
          store(:show_starting_map, !@show_starting_map)
        end

        render_button(text, on_click)
      end

      def generate_last_route(entity)
        trains = entity.trains
        operating = entity.operating_history
        last_run = operating[operating.keys.max]&.routes
        return [] unless last_run

        halts = operating[operating.keys.max]&.halts
        routes = []
        last_run.map do |train, connections|
          next unless trains.include?(train)

          routes << Engine::Route.new(@game, @game.phase, train, connection_hexes: connections,
                                                                 routes: routes, num_halts: halts[train])
        end.compact

        routes
      end

      def route_controls
        return unless @game

        step = @game.round.active_step
        actions = step&.actions(step&.current_entity) || []
        # Route controls are disabled during dividend and run routes step
        if (%w[run_routes dividend] & actions).any?
          store(:historical_routes, [])
          return
        end

        all_operators = @game.operated_operators
        operators = all_operators.map do |operator|
          revenue = operator.operating_history[operator.operating_history.keys.max].revenue
          attrs = { value: operator.name }
          h(:option, { attrs: attrs }, "#{operator.name} #{@game.format_currency(revenue)}")
        end

        attrs = {}
        operators.unshift(h(:option, { attrs: attrs }, 'None'))

        route_change = lambda do
          operator_name = Native(@route_input).elm&.value
          operator = all_operators.find { |o| o.name == operator_name }
          if operator
            store(:historical_routes, generate_last_route(operator))
          else
            store(:historical_routes, [])
          end
        end

        @route_input = render_select('Show Route', id: :route, on: { input: route_change }, children: operators)
        ['Last Route:', @route_input]
      end

      def render_select(_label, id:, on: {}, children: [])
        input_props = {
          attrs: {
            id: id,
          },
          on: { **on },
        }
        h(:select, input_props, children)
      end

      def render_button(text, action)
        props = {
          style: {
            top: '1rem',
            # float: 'right',
            borderRadius: '5px',
            margin: '0 0.3rem',
            padding: '0.2rem 0.5rem',
          },
          on: {
            click: action,
          },
        }

        h(:button, props, text)
      end
    end
  end
end
