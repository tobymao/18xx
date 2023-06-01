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

    def params(inputs = nil)
      (inputs || @inputs).to_h do |key, input|
        input = Native(input)
        elm = input['elm']
        [key, %w[checkbox radio].include?(elm['type']) ? elm['checked'] : elm['value']]
      end
    end

    def render_form(name, inputs, description = nil)
      props = {
        on: { keyup: ->(event) { submit if Native(event)['key'] == 'Enter' } },
      }
      h2_props = { style: { margin: '1rem 0 0.5rem 0' } }

      id = name.gsub(/\s/, '-').downcase
      h(:form, props, [
        h(:legend, [h(:h2, h2_props, name)]),
        description ? h(:p, description) : '',
        h("div##{id}", inputs),
        h(:input, attrs: { type: :text }, style: { display: 'none' }),
      ])
    end

    # rubocop:disable Layout/LineLength
    def render_input(label, id:, placeholder: '', el: 'input', type: 'text', attrs: {}, on: {}, container_style: {}, label_style: {}, input_style: {}, children: [], siblings: [], inputs: nil)
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
      if (small_input_elm = %w[radio checkbox].include?(type))
        label_props[:style][:verticalAlign] = 'middle'
        input_props[:style][:verticalAlign] = 'middle'
      end
      input = h(el, input_props, children)
      inputs ||= @inputs
      inputs[id] = input
      children = small_input_elm ? [input, h(:label, label_props, label)] : [h(:label, label_props, label), input]

      h(
        'div.input-container',
        { style: { **container_style } },
        children + siblings,
      )
    end

    def render_button(text, style: {}, attrs: {}, &block)
      props = {
        attrs: {
          **attrs,
          type: :button,
        },
        style: {
          **style,
        },
        on: { click: block },
      }

      h(:button, props, text)
    end

    def render_checkbox(label, id, form, checked)
      render_input(
        label,
        id: id,
        type: 'checkbox',
        inputs: form,
        attrs: {
          checked: checked,
        }
      )
    end
  end
end
