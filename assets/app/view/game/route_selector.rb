# frozen_string_literal: true

require 'lib/settings'
require 'engine/auto_router'
require 'view/game/actionable'

module View
  module Game
    class RouteSelector < Snabberb::Component
      include Actionable
      include Lib::Settings

      needs :last_entity, store: true, default: nil
      needs :last_round, store: true, default: nil
      needs :last_company, store: true, default: nil
      needs :routes, store: true, default: []
      needs :selected_route, store: true, default: nil
      needs :selected_company, default: nil, store: true
      needs :abilities, store: true, default: nil

      # Get routes that have a length greater than zero
      # Due to the way this and the map hook up routes needs to have
      # an entry, but that route is not valid at zero length
      def active_routes
        @routes.select { |r| r.chains.any? }
      end

      def generate_last_routes!
        trains = @game.route_trains(@game.round.current_entity)
        operating = @game.round.current_entity.operating_history
        last_run = operating[operating.keys.max]&.routes
        return [] unless last_run
        return [] if @abilities&.any?

        halts = operating[operating.keys.max]&.halts
        nodes = operating[operating.keys.max]&.nodes
        last_run.map do |train, connection_hexes|
          next unless trains.include?(train)

          # A future enhancement to this could be to find trains and move the routes over
          @routes << Engine::Route.new(
            @game,
            @game.phase,
            train,
            connection_hexes: connection_hexes,
            routes: @routes,
            halts: halts[train],
            nodes: nodes[train],
          )
        end.compact
      end

      def render
        step = @game.active_step
        current_entity = @game.round.current_entity
        if @selected_company&.owner == current_entity
          ability = @game.abilities(@selected_company, :hex_bonus, time: 'route')
          # Clean routes if we select company, but just when we select
          unless @last_company
            cleanup
            store(:last_company, @selected_company, skip: true)
          end
          store(:abilities, ability ? [ability.type] : nil, skip: true)
        else
          cleanup if @last_company
          store(:last_company, nil, skip: true)
          store(:abilities, nil, skip: true)
        end

        # this is needed for the rare case when moving directly between run_routes steps
        if @last_entity != current_entity || @last_round != @game.round
          cleanup
          store(:last_entity, current_entity, skip: true)
          store(:last_round, @game.round, skip: true)
        end

        trains = @game.route_trains(current_entity)

        train_help =
          if (helps = @game.train_help(current_entity, trains, @routes)).any?
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
          route = Engine::Route.new(@game, @game.phase, first_train, abilities: @abilities, routes: @routes)
          @routes << route
          store(:routes, @routes, skip: true)
          store(:selected_route, route, skip: true)
        end

        @routes.each(&:clear_cache!)

        render_halts = false
        trains = trains.flat_map do |train|
          onclick = lambda do
            unless (route = @routes.find { |t| t.train == train })
              route = Engine::Route.new(@game, @game.phase, train, abilities: @abilities, routes: @routes)
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
              [@game.format_revenue_currency(route.revenue), nil]
            rescue Engine::GameError => e
              ['N/A', e.to_s]
            end

            bg_color = route_prop(@routes.index(route), :color)
            style[:backgroundColor] = bg_color
            style[:color] = contrast_on(bg_color)

            td_props = { style: { paddingRight: '0.8rem' } }

            children << h('td.right.middle', td_props, route.distance_str)
            if route.halts
              render_halts = true
              children << h('td.right.middle', td_props,
                            halt_actions(route, revenue, @game.format_currency(route.subsidy)))
            else
              children << h('td.right.middle', td_props, revenue)
            end
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
          train_name = step.respond_to?(:train_name) ? step.train_name(current_entity, train) : train.name
          [
            h(:tr, [h('td.middle', [h(:div, { style: style, on: { click: onclick } }, train_name)]), *children]),
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

        instructions = 'Click revenue centers, again to cycle paths.'
        instructions += ' Click button under Revenue to pick number of halts.' if render_halts

        h(:div, div_props, [
          h(:h3, 'Select Routes'),
          h('div.small_font', description),
          h('div.small_font', instructions),
          train_help,
          h(:table, table_props, [
            h(:thead, [
              h(:tr, [
                h(:th, 'Train'),
                h(:th, 'Used'),
                h(:th, 'Revenue'),
                h(:th, th_route_props, 'Route'),
              ]),
            ]),
            h(:tbody, trains),
          ]),
          actions(render_halts),
          dividend_chart,
        ].compact)
      end

      def halt_actions(route, revenue, subsidy)
        change_halts = lambda do
          route.cycle_halts
          store(:selected_route, route)
        end

        [
          revenue,
          h(:div, [
            h('button.small', { style: { margin: '0px', padding: '0.2rem' }, on: { click: change_halts } }, subsidy),
          ]),
        ]
      end

      def cleanup
        store(:selected_route, nil, skip: true)
        store(:routes, [], skip: true)
      end

      def actions(render_halts)
        current_entity = @game.round.current_entity

        submit = lambda do
          process_action(Engine::Action::RunRoutes.new(@game.current_entity, routes: active_routes))
          cleanup
        end

        clear = lambda do
          @selected_route&.reset!
          store(:selected_route, @selected_route)
        end

        reset_all = lambda do
          @game.reset_adjustable_trains!(current_entity, @routes)
          @selected_route = nil
          store(:selected_route, @selected_route)
          @routes.clear
          store(:routes, @routes)
        end

        clear_all = lambda do
          @routes.each(&:reset!)
          store(:routes, @routes)
        end

        flash = lambda do |message|
          store(:flash_opts, { message: message }, skip: false)
        end

        auto = lambda do
          router = Engine::AutoRouter.new(@game, flash)
          @routes = router.compute(
            @game.current_entity,
            routes: @routes.reject { |r| r.paths.empty? },
            path_timeout: setting_for(:path_timeout).to_i,
            route_timeout: setting_for(:route_timeout).to_i,
          )
          store(:routes, @routes)
        end

        add_train = lambda do
          if (new_train = @game.add_route_train(current_entity, @routes))
            new_route = Engine::Route.new(@game, @game.phase, new_train, abilities: @abilities, routes: @routes)
            @selected_route = new_route
            @routes << new_route
            store(:selected_route, @selected_route, skip: true)
            store(:routes, @routes)
          end
        end

        delete_train = lambda do
          if @game.delete_route_train(current_entity, @selected_route)
            @routes.delete(@selected_route)
            @selected_route = @routes[0]
            store(:selected_route, @selected_route, skip: true)
            store(:routes, @routes)
          end
        end

        increase_train = lambda do
          @game.increase_route_train(current_entity, @selected_route)
          store(:selected_route, @selected_route)
        end

        decrease_train = lambda do
          @game.decrease_route_train(current_entity, @selected_route)
          store(:selected_route, @selected_route)
        end

        submit_style = {
          minWidth: '6.5rem',
          marginTop: '1rem',
          padding: '0.2rem 0.5rem',
        }

        revenue_str = begin
          @game.submit_revenue_str(active_routes, render_halts)
        rescue Engine::GameError
          '(Invalid Route)'
        end

        buttons = [
          h('button.small', { on: { click: clear } }, 'Clear Train'),
          h('button.small', { on: { click: clear_all } }, 'Clear All'),
          h('button.small', { on: { click: reset_all } }, 'Reset'),
        ]
        if @game_data.dig('settings', 'auto_routing') || @game_data['mode'] == :hotseat
          buttons << h('button.small', { on: { click: auto } }, 'Auto')
        end
        if @game.adjustable_train_list?(current_entity)
          buttons << h('button.small', { on: { click: add_train } }, "+#{@game.adjustable_train_label(current_entity)}")
          buttons << h('button.small', { on: { click: delete_train } }, "-#{@game.adjustable_train_label(current_entity)}")
        end
        if @game.adjustable_train_sizes?(current_entity)
          buttons << h('button.small', { on: { click: increase_train } }, '+Size')
          buttons << h('button.small', { on: { click: decrease_train } }, '-Size')
        end
        h(:div, { style: { overflow: 'auto', marginBottom: '1rem' } }, [
          h(:div, buttons),
          h(:button, { style: submit_style, on: { click: submit } }, 'Submit ' + revenue_str),
        ])
      end

      def dividend_chart
        step = @game.active_step
        return nil unless step.respond_to?(:chart)

        header, *chart = step.chart(@game.round.current_entity)

        rows = chart.map do |r|
          h(:tr, [
            h('td.padded_number', r[0]),
            h(:td, r[1]),
          ])
        end

        table_props = {
          style: {
            margin: '0.5rem 0',
          },
        }

        h(:table, table_props, [
          h(:thead, [
            h(:tr, [
              h(:th, header[0]),
              h(:th, header[1]),
            ]),
          ]),
          h(:tbody, rows),
        ])
      end
    end
  end
end
