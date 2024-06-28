# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class DoubleHeadTrains < Snabberb::Component
      include Actionable
      include Lib::Settings

      needs :selected_trains, store: true, default: {}

      def render
        @step = @game.active_step
        current_entity = @game.round.current_entity
        trains = @game.double_head_candidates(current_entity)

        rendered_trains = trains.flat_map do |train|
          onclick = lambda do
            @selected_trains[train] = !@selected_trains[train]
            store(:selected_trains, @selected_trains, skip: false)
          end

          style = {
            border: "solid 1px #{color_for(:font)}",
            display: 'inline-block',
            cursor: 'pointer',
            margin: '0.1rem 0rem',
            padding: '3px 6px',
            minWidth: '1.5rem',
            textAlign: 'center',
            whiteSpace: 'nowrap',
          }

          bg_color = route_prop(0, :color)
          if @selected_trains[train]
            style[:backgroundColor] = bg_color
            style[:color] = contrast_on(bg_color)
          else
            style[:backgroundColor] = color_for(:bg)
          end

          [
            h(:tr,
              [h('td.middle', [
                   h(:div, { style: style, on: { click: onclick } }, train.name),
                 ])]),
          ]
        end

        div_props = {
          key: 'double_head_trains',
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

        description = 'Each turn, trains may be added together to run as a single longer train for that turn.'

        h(:div, div_props, [
            h(:h3, 'Double-Head Trains'),
            h('div.small_font', description),
            h(:table, table_props, [
                h(:thead, [
                    h(:tr, [
                        h(:th, 'Train'),
                      ]),
                  ]),
                h(:tbody, rendered_trains),
              ]),
            actions,
          ].compact)
      end

      def cleanup(skip: true)
        store(:selected_trains, {}, skip: skip)
      end

      def actions
        selected_count = 0
        cities = 0
        towns = 0

        trains = @selected_trains.map do |train, selected|
          next unless selected

          selected_count += 1

          c, t = @game.distance(train)
          cities += c
          towns += t

          train
        end.compact

        disabled = trains.size < 2
        submit_txt = disabled ? 'Select 2 or more trains' : "Form #{@step.an(cities)} #{cities}+#{towns} train"

        submit = lambda do
          process_action(Engine::Action::DoubleHeadTrains.new(@game.current_entity, trains: trains))
          cleanup
        end

        reset = lambda do
          cleanup(skip: false)
        end

        submit_style = {
          minWidth: '6.5rem',
          marginTop: '1rem',
          padding: '0.2rem 0.5rem',
        }

        h(:div, { style: { overflow: 'auto', marginBottom: '1rem' } }, [
          h(:button, { attrs: { disabled: disabled }, style: submit_style, on: { click: submit } }, submit_txt),
          h(:button, { style: submit_style, on: { click: reset } }, 'Reset'),
        ])
      end
    end
  end
end
