# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class CombinedTrains < Snabberb::Component
      include Actionable
      include Lib::Settings

      needs :selected_trains, store: true, default: {}

      def render
        @step = @game.active_step
        current_entity = @game.round.current_entity
        base_trains = @game.combined_base_trains_candidates(current_entity)
        obsolete_trains = @game.combined_obsolete_trains_candidates(current_entity)

        rendered_base_trains = base_trains.flat_map do |train|
          onclick = lambda do
            @selected_trains[train] = !@selected_trains[train]
            store(:selected_trains, @selected_trains, skip: false)
          end

          style = {
            border: 'solid 1px',
            display: 'inline-block',
            cursor: 'pointer',
            margin: '0.1rem 0rem',
            padding: '3px 6px',
            minWidth: '1.5rem',
            textAlign: 'center',
            whiteSpace: 'nowrap',
          }

          bg_color = route_prop(1, :color)
          style[:backgroundColor] = @selected_trains[train] ? bg_color : color_for(:bg)
          style[:color] = contrast_on(bg_color)

          [
            h(:tr,
              [h('td.middle', [
                   h(:div, { style: style, on: { click: onclick } }, train.name),
                 ])]),
          ]
        end
        rendered_obsolete_trains = obsolete_trains.flat_map do |train|
          train.variants.flat_map do |_name, variant|
            onclick = lambda do
              train.variant = variant[:name]
              @selected_trains[train] = !@selected_trains[train]
              store(:selected_trains, @selected_trains, skip: false)
            end

            children = []

            style = {
              border: 'solid 1px',
              display: 'inline-block',
              cursor: 'pointer',
              margin: '0.1rem 0rem',
              padding: '3px 6px',
              minWidth: '1.5rem',
              textAlign: 'center',
              whiteSpace: 'nowrap',
            }

            bg_color = route_prop(1, :color)
            style[:backgroundColor] = @selected_trains[train] && train.name == variant[:name] ? bg_color : color_for(:bg)
            style[:color] = contrast_on(bg_color)

            td_props = { style: { paddingRight: '0.8rem' } }
            children << h('td.right.middle', td_props, @game.format_currency(variant[:price] * 2))
            [
              h(:tr,
                [h('td.middle', [
                     h(:div, { style: style, on: { click: onclick } }, variant[:name]),
                   ]), *children]),
            ]
          end
        end

        div_props = {
          key: 'combined_trains',
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
            h(:h3, 'Combined Trains'),
            h('div.small_font', description),
            h(:table, table_props, [
                h(:thead, [
                    h(:tr, [
                        h(:th, 'Base Train'),
                      ]),
                  ]),
                h(:tbody, rendered_base_trains),
                h(:thead, [
                  h(:tr, [
                      h(:th, 'Obsoslete Train'),
                      h(:th, 'Cost'),
                    ]),
                ]),
                h(:tbody, rendered_obsolete_trains),
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
          next if train.is_a?(String)

          selected_count += 1

          c, t = @game.distance(train)
          cities += c
          towns += t

          train
        end.compact

        disabled = trains.size < 2 || trains.first.track_type == trains.last.track_type
        submit_txt = disabled ? 'Select trains' : "Form  #{cities}+#{towns} train"
        base, variant = trains.partition { |t| t.owner == @game.current_entity }
        variant = variant.first
        base = base.first

        submit = lambda do
          process_action(Engine::Action::CombinedTrains.new(@game.current_entity, base: base, additional_train: variant,
                                                                                  additional_train_variant: variant.name))
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
