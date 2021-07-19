# frozen_string_literal: true

require 'lib/settings'
require 'view/game/actionable'

module View
  module Game
    class TrackConversion < Snabberb::Component
      include Actionable
      include Lib::Settings

      needs :routes, store: true, default: []
      needs :selected_route, store: true, default: nil

      # Get routes that have a length greater than zero
      # Due to the way this and the map hook up routes needs to have
      # an entry, but that route is not valid at zero length
      def active_routes
        @routes.reject { |r| r.chains.empty? }
      end

      def render
        @step = @game.active_step
        current_entity = @game.round.current_entity

        trains = @game.conversion_trains(current_entity)

        train_help =
          if (helps = @game.train_help(current_entity, trains, @routes)).any?
            h('ul',
              { style: { 'padding-left': '20px' } },
              helps.map { |help| h('li', [h('p.small_font', help)]) })
          end

        if !@selected_route && (first_train = trains[0])
          route = Engine::Route.new(@game, @game.phase, first_train, abilities: @abilities,
                                                                     routes: @routes, any_track: true)
          @routes << route
          store(:routes, @routes, skip: true)
          store(:selected_route, route, skip: true)
        end

        @routes.each(&:clear_cache!)

        trains = trains.flat_map do |train|
          onclick = lambda do
            unless (route = @routes.find { |t| t.train == train })
              route = Engine::Route.new(@game, @game.phase, train, abilities: @abilities,
                                                                   routes: @routes, any_track: true)
              @routes << route
              store(:routes, @routes, skip: true)
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
            _revenue, invalid = begin
              # need this call to force errors
              [route.revenue.to_s, nil]
            rescue Engine::GameError => e
              ['N/A', e.to_s]
            end

            bg_color = route_prop(@routes.index(route), :color)
            style[:backgroundColor] = bg_color
            style[:color] = contrast_on(bg_color)

            td_props = { style: { paddingRight: '0.8rem' } }

            children << h('td.right.middle', td_props, "#{route.distance_str} Stops")
            children << h(:td, route.revenue_str)
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
            h(:tr, [h('td.middle', [h(:div, { style: style, on: { click: onclick } }, 'Segment:')]), *children]),
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

        instructions = 'Click revenue centers, again to cycle paths. '\
                       'Must be from city/offboard to city/offboard'
        h3_text = 'Select Segment for Conversion'

        h(:div, div_props, [
          h(:h3, h3_text),
          h('div.small_font', instructions),
          train_help,
          h(:table, table_props, [
            h(:tbody, trains),
          ]),
          actions,
        ])
      end

      def cleanup
        store(:selected_route, nil, skip: true)
        store(:routes, [], skip: true)
      end

      def actions(_render_halts)
        submit = lambda do
          process_action(Engine::Action::RunRoutes.new(@game.current_entity, routes: active_routes))
          cleanup
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

        submit_text = begin
          # need this call to force errors
          @step.total_str(active_routes)
        rescue Engine::GameError
          @step.revenue_fail
        end

        buttons = [h('button.small', { on: { click: clear_all } }, 'Clear')]
        h(:div, { style: { overflow: 'auto', marginBottom: '1rem' } }, [
          h(:div, buttons),
          h(:button, { style: submit_style, on: { click: submit } }, submit_text),
        ])
      end
    end
  end
end
