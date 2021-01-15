# frozen_string_literal: true

module View
  class Form < Snabberb::Component
    needs :app_route, default: nil, store: true

    def render
      @inputs = {}

      render_content
    end

    def render_content
      raise NotImplementedError
    end

    def submit
      raise NotImplementedError
    end

    def params
      @inputs.map do |key, input|
        input = Native(input)
        elm = input['elm']
        [key, elm['type'] == 'checkbox' ? elm['checked'] : elm['value']]
      end.to_h
    end

    def render_form(name, inputs, description = nil)
      enter = lambda do |event|
        code = event.JS['keyCode']
        submit if code && code == 13
      end

      props = {
        on: { keyup: enter },
      }
      h2_props = { style: { margin: '0 0 0.5rem 0' } }

      id = name.gsub(/\s/, '-').downcase
      h(:form, props, [
        h(:legend, [h(:h2, h2_props, name)]),
        description ? h(:p, description) : '',
        h("div##{id}", inputs),
        h(:input, attrs: { type: :text }, style: { display: 'none' }),
      ])
    end

    # rubocop:disable Layout/LineLength
    def render_input(label, id:, placeholder: '', el: 'input', type: 'text', attrs: {}, on: {}, container_style: {}, label_style: {}, input_style: {}, children: [])
      # rubocop:enable Layout/LineLength
      label_props = {
        style: {
          cursor: 'pointer',
          **label_style,
        },
        attrs: { for: id },
      }
      input_props = {
        style: input_style,
        attrs: {
          id: id,
          type: type,
          **attrs,
        },
        on: { **on },
      }
      input_props[:attrs][:placeholder] = placeholder if placeholder != ''
      input = h(el, input_props, children)
      @inputs[id] = input
      h(
        'div.input-container',
        { style: { **container_style } },
        [h(:label, label_props, label), input]
      )
    end

    def render_button(text, style: {}, &block)
      props = {
        attrs: {
          type: :button,
        },
        style: {
          **style,
        },
        on: { click: block },
      }

      h(:button, props, text)
    end
  end
end
