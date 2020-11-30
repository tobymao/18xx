# frozen_string_literal: true

require '../lib/storage'

module View
  module Game
    class MapControls < Snabberb::Component
      needs :show_coords, default: true, store: true
      needs :show_location_names, default: true, store: true
      needs :show_starting_map, default: false, store: true

      def render
        children = [
          location_names_controls,
          hex_coord_controls,
          starting_map_controls,
        ]

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
