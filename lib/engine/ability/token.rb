# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Token < Base
      attr_reader :hexes, :free

      def setup(hexes:, free: nil)
        @hexes = hexes
        @free = free || false
      end
    end
  end
end
