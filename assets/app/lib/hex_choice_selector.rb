# frozen_string_literal: true

module Lib
  # A step opts in via `hex_choices(entity, hex)`.
  class HexChoiceSelector
    attr_reader :entity, :hex, :choices, :x, :y, :role

    def initialize(hex, choices, coordinates, entity, role)
      @hex = hex
      @choices = choices
      @x, @y = coordinates
      @entity = entity
      @role = role
    end
  end
end
