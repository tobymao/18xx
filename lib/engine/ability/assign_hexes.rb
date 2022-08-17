# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class AssignHexes < Base
      attr_reader :hexes, :closed_when_used_up

      def setup(hexes:, closed_when_used_up: nil)
        @hexes = hexes
        @closed_when_used_up = closed_when_used_up || false
      end
    end
  end
end
