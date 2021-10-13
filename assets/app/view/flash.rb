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

      `setTimeout(function() { self['$store']('flash_opts', Opal.hash()) }, 3000)`

      props = {
        style: {
          boxSizing: 'border-box',
          padding: '1em',
          position: 'fixed',
          cursor: 'pointer',
          top: '0',
          left: '0',
          width: '100%',
          zIndex: '10000',
          textAlign: 'center',
          backgroundColor: @flash_opts[:color] || 'salmon',
          color: 'black',
        },
        on: { click: -> { store(:flash_opts, {}) } },
      }

      h(:div, props, @flash_opts[:message])
    end
  end
end
