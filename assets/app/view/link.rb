# frozen_string_literal: true

module View
  class Link < Snabberb::Component
    needs :href
    needs :click
    needs :children, default: []
    needs :style, default: {}
    needs :title, default: ''
    needs :class, default: nil

    def render
      props = {
        attrs: {
          href: @href,
          onclick: 'return false',
          title: @title,
        },
        style: @style,
        on: {
          click: @click,
        },
      }

      h("a#{@class}", props, @children)
    end
  end
end
