# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Reservation < Base
      attr_accessor :city, :tile, :icon
      attr_reader :hex, :slot

      def setup(hex:, city: nil, slot: nil, icon: nil)
        @hex = hex
        @city = city || 0
        @slot = slot || 0
        @tile = nil
        @icon = "/icons/#{icon}.svg" if icon
      end

      def teardown
        tile.cities[@city].remove_reservation!(owner) if tile
      end
    end
  end
end
