# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class AssignHexes < Base
      attr_reader :hexes, :closed_when_used_up, :cost

      def setup(hexes:, closed_when_used_up: nil, cost: 0)
        @hexes = hexes
        @closed_when_used_up = closed_when_used_up
        @cost = cost
      end
    end
  end
end
