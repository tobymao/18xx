# frozen_string_literal: true

require 'component'

module View
  class Player < Component
    def initialize(player:)
      @player = player
    end

    def render
      h(:div, [
        h(:div, "name: #{@player.name}"),
        h(:div, "cash: #{@player.cash}"),
        h(:div, "companies: #{@player.companies.map(&:name)}"),
      ])
    end
  end
end
