# frozen_string_literal: true

require 'view/create_game'

module View
  class Home < Snabberb::Component
    def render
      h('div.pure-u-1', [
        h(CreateGame)
      ])
    end
  end
end
