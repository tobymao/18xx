# frozen_string_literal: true

module View
  class Flash < Snabberb::Component
    # flash_opts can be passed as a string which will default to salmon
    # if calling with a dictionary, you need to specify the skip or else
    # the opal compiler will remove the value
    # store(:flash_opts, value = { message: 'test' }, skip: false)
    needs :flash_opts, default: {}, store: true

    def render
      @flash_opts = { message: @flash_opts } if @flash_opts.is_a?(String)
      return h(:div) unless @flash_opts&.any?

      props = {
        style: {
          padding: '1em',
          position: 'fixed',
          cursor: 'pointer',
          top: '0',
          left: '0',
          width: '100%',
          'z-index': '10000',
          'text-align': 'center',
          'background-color': @flash_opts[:color] || 'salmon',
          color: 'black',
        },
        on: { click: -> { store(:flash_opts, {}) } },
      }

      h(:div, props, @flash_opts[:message])
    end
  end
end
