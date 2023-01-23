# frozen_string_literal: true

require 'view/game/actionable'
require 'lib/settings'

module View
  module Game
    class ParChart < Snabberb::Component
      include Actionable
      include Lib::Settings

      needs :corporation_to_par, default: nil, store: true

      def render
        @step = @game.round.active_step
        @current_entity = @step.current_entity

        children = []
        if @corporation_to_par
          children = [h(:div, [h(:button, { on: { click: -> { store(:corporation_to_par, nil) } } }, 'Cancel (Par)')])]
          children << h(Corporation, corporation: @corporation_to_par)
        end
        children << render_chart

        h(:div, children)
      end

      def render_chart
        @current_operator = @game.respond_to?(:current_operator) ? @game.current_operator : nil

        attrs = {
          style: {
            'display' => 'flex',
            'margin' => '1rem 0rem',
            'width' => 'auto',
          },
        }
        h(:div, attrs, @game.par_chart.map { |sp, slots| render_par_box(sp, slots) })
      end

      def render_par_box(share_price, slots)
        attrs = {
          style: {
            'display' => 'grid',
            'grid-template-columns' => "repeat(#{slots.size}, 3rem",
            'grid-template-rows' => '2rem repeat(1.8, 3.5rem)',
            'gap' => '0 0.5rem',
            'padding' => '0 0.5rem',
            'justify-items' => 'center',
            'align-items' => 'center',
            'color' => 'black',
            'background-color' => '#DCDCDC',
            'border' => '0.1rem solid black',
          },
        }

        children = [render_par_value(share_price, slots)]
        children.concat(slots.map.with_index { |slot, index| render_par_slot(slot, index, share_price) })
        h(:div, attrs, children)
      end

      def render_par_value(share_price, slots)
        attrs = {
          style: {
            'fontSize' => '1.2rem',
            'grid-column' => "1 / span #{slots.size}",
          },
        }

        h(:div, attrs, share_price.price)
      end

      def render_par_slot(slot, index, share_price)
        attrs = {
          style: {
            'grid-row' => '2 / span 2',
          },
        }
        attrs[:style][:border] = '0.3rem solid maroon' if @current_operator && @current_operator == slot

        children = [slot ? render_corp_icon(slot) : render_open_slot(share_price, index)]
        children << render_train_marker(slot) if @game.respond_to?(:train_marker)

        h(:div, attrs, children)
      end

      def render_corp_icon(corp)
        props = {
          style: {
            display: 'flex',
            'justify-content': 'center',
            'align-items': 'center',
            width: '50px',
            height: '50px',
          },
        }

        image_props = {
          attrs: {
            src: logo_for_user(corp),
            title: corp.name,
          },
          style: {
            width: '80%',
          },
        }

        h(:div, props, [h(:img, image_props)])
      end

      def logo_for_user(entity)
        setting_for(:simple_logos, @game) ? entity.simple_logo : entity.logo
      end

      def render_train_marker(corp)
        props = {
          style: {
            display: 'flex',
            'justify-content': 'center',
            'align-items': 'center',
            width: '50px',
            height: '50px',
          },
        }

        image_props = {
          attrs: {
            src: train_marker_for_corp(corp),
          },
          style: {
            width: '80%',
          },
        }

        h(:div, props, [h(:img, image_props)])
      end

      def train_marker_for_corp(corp)
        train_marker = @game.train_marker
        if train_marker && train_marker == corp
          '/icons/1880/train.svg'
        else
          '/icons/1880/train_outline.svg'
        end
      end

      def render_open_slot(share_price, index)
        props = {
          style: {
            display: 'flex',
            'justify-content': 'center',
            'align-items': 'center',
            width: '50px',
            height: '50px',
          },
        }

        circle_props = {
          attrs: {
            r: '20',
            cx: '25',
            cy: '25',
            fill: 'white',
          },
          style: {
            stroke: 'black',
            'stroke-width' => '0.1rem',
          },
        }

        if @corporation_to_par
          par = lambda do
            process_action(Engine::Action::Par.new(
              @current_entity,
              corporation: @corporation_to_par,
              share_price: share_price,
              slot: index,
            ))
            store(:corporation_to_par, nil)
          end

          circle_props[:on] = { click: par }
          circle_props[:style][:cursor] = 'pointer'
        end

        h(:svg, props, [h(:circle, circle_props)])
      end
    end
  end
end
