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

    def render_form(name, inputs)
      enter = lambda do |event|
        code = event.JS['keyCode']
        submit if code && code == 13
      end

      props = {
        on: { keyup: enter },
      }

      id = name.gsub(/\s/, '-').downcase
      h(:form, props, [
        h(:legend, name),
        h("div##{id}", inputs),
        h(:input, attrs: { type: :text }, style: { display: 'none' }),
      ])
    end

    # rubocop:disable Layout/LineLength
    def render_input(label, placeholder: '', id:, el: 'input', type: 'text', attrs: {}, container_style: {}, label_style: {}, input_style: {}, children: [])
      # rubocop:enable Layout/LineLength
      label_props = {
        style: label_style,
        attrs: { for: id },
      }
      input_props = {
        style: input_style,
        attrs: {
          id: id,
          type: type,
          **attrs,
        },
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

    def render_button(text, &block)
      props = {
        attrs: { type: :button },
        on: { click: block },
      }

      h('button.button', props, text)
    end
  end
end
