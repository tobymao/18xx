# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Reservation < Base
      attr_accessor :city, :tile
      attr_reader :hex, :slot

      def setup(hex:, city: 0, slot: 0)
        @hex = hex
        @city = city
        @slot = slot
        @tile = nil
      end

      def teardown
        tile.cities[@city].reservations.delete(owner) if tile
      end
    end
  end
end
