# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class HexBonus < Base
      attr_reader :hexes, :amount

      def setup(hexes:, amount:)
        @hexes = hexes
        @amount = amount
      end
    end
  end
end
