# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Destination < Base
      attr_reader :hex

      def setup(hex:)
        @hex = hex
      end
    end
  end
end
