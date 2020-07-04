# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class TileIncome < Base
      attr_reader :terrain, :income
      def setup(terrain:, income:)
        @terrain = terrain.to_sym
        @income = income
      end
    end
  end
end
