# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class HexBonus < Base
      attr_accessor :amount
      attr_reader :hexes

      def setup(hexes:, amount:)
        @hexes = hexes
        @amount = amount
      end
    end
  end
end
