# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class TileIncome < Base
      attr_reader :terrain, :income, :owner_only
      def setup(terrain:, income:, owner_only: false)
        @terrain = terrain.to_sym
        @income = income
        @owner_only = owner_only
      end
    end
  end
end
