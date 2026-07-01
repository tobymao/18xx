# frozen_string_literal: true

module View
  module Game
    class Card < Snabberb::Component
      # The core payload (e.g., '20%', '2+2', 'OB')
      needs :text

      # Visual State Parameters
      needs :bg_color, default: '#f4efdf' # Slightly beige/cardboard
      needs :text_color, default: '#000000'
      needs :border_color, default: '#999999' # Neutral default
      needs :border_width, default: '2px'

      # Sizing & Typography constraints to guarantee uniformity
      needs :width, default: '42px'
      needs :height, default: '22px'
      needs :font_size, default: '0.75rem'
      needs :font_family, default: '"Helvetica Neue", Helvetica, Arial, sans-serif'

      # Interaction & Lifecycle hooks
      needs :click_action, default: nil
      needs :id, default: nil # Crucial for Phase 5 DOM coordinate tracking

      def render
        props = {
          style: {
            display: 'inline-flex',
            justifyContent: 'center',
            alignItems: 'center',
            backgroundColor: @bg_color,
            color: @text_color,
            border: "#{@border_width} solid #{@border_color}",
            borderRadius: '3px',
            width: @width,
            height: @height,
            fontSize: @font_size,
            fontFamily: @font_family,
            fontWeight: 'bold',
            boxShadow: '1px 1px 2px rgba(0,0,0,0.25)',
            margin: '2px',
            boxSizing: 'border-box',
            cursor: @click_action ? 'pointer' : 'default',
            userSelect: 'none',
            # Set up the CSS transition for hover and future animation hooks
            transition: 'transform 0.1s ease-in-out, border-color 0.2s ease',
          },
        }

        # Inject unique DOM ID if provided (needed for animation matrix calculations)
        props[:attrs] = { id: @id } if @id

        # Attach interaction logic
        if @click_action
          props[:on] = { click: @click_action }
          props[:style]['&:hover'] = { transform: 'scale(1.08)' }
        end

        h(:div, props, @text.to_s)
      end
    end
  end
end
