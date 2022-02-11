# frozen_string_literal: true

require 'lib/settings'

module View
  module Game
    class MapControls < Snabberb::Component
      include Lib::Settings
      needs :show_starting_map, default: false, store: true
      needs :historical_routes, default: [], store: true
      needs :historical_laid_hexes, default: nil, store: true
      needs :game, default: nil, store: true

      def render
        children = [
          render_controls('Player Colors', :show_player_colors),
          render_controls('Simple Logos', :simple_logos),
          render_controls('Location Names', :show_location_names),
          render_controls('Hex Coordinates', :show_coords),
          starting_map_controls,
          route_controls,
        ].compact

        h('div#map_controls', children)
      end

      def render_controls(label, option)
        on_click = lambda do
          toggle_setting(option, @game)
          update
        end

        render_button("#{label} #{setting_for(option, @game) ? '✅' : '❌'}", on_click)
      end

      def starting_map_controls
        on_click = lambda do
          store(:show_starting_map, !@show_starting_map)
        end

        render_button("Starting Map #{@show_starting_map ? '✅' : '❌'}", on_click)
      end

      def generate_last_route(entity)
        operating = entity.operating_history
        last_run = operating[operating.keys.max]&.routes
        return [] unless last_run

        halts = operating[operating.keys.max]&.halts
        nodes = operating[operating.keys.max]&.nodes
        routes = []
        last_run.each do |train, connection_hexes|
          routes << Engine::Route.new(@game,
                                      @game.phase,
                                      train,
                                      connection_hexes: connection_hexes,
                                      routes: routes,
                                      num_halts: halts[train],
                                      nodes: nodes[train])
        end

        routes
      end

      def last_laid_hexes(entity)
        operating = entity.operating_history
        operating[operating.keys.max]&.laid_hexes || []
      end

      def route_controls
        return unless @game

        step = @game.round.active_step
        actions = step&.actions(step&.current_entity) || []
        # Route controls are disabled during dividend and run routes step
        if (%w[run_routes dividend] & actions).any?
          store(:historical_routes, []) if @historical_routes.any?
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
            store(:historical_routes, generate_last_route(operator), skip: true)
            store(:historical_laid_hexes, last_laid_hexes(operator))
          else
            store(:historical_routes, [], skip: true)
            store(:historical_laid_hexes, nil)
          end
        end

        @route_input = render_select(id: :route, on: { input: route_change }, children: operators)
        h('label.inline-block', ['Show Last Route and Tile For:', @route_input])
      end

      def render_select(id:, on: {}, children: [])
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
          on: {
            click: action,
          },
        }

        h('button.small', props, text)
      end
    end
  end
end
