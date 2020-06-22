# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class IgnoreTerrain < Base
      attr_reader :terrain

      def setup(terrain:)
        @terrain = terrain.to_sym
      end
    end
  end
end
