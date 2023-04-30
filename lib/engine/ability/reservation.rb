# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Reservation < Base
      attr_accessor :city, :tile
      attr_reader :hex, :slot

      def setup(hex:, city: nil, slot: nil)
        @hex = hex
        @city = city || 0
        @slot = slot || 0
        @tile = nil
      end

      def teardown
        tile.cities[@city].remove_reservation!(owner) if tile
      end
    end
  end
end
