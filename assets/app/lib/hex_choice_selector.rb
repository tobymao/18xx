# frozen_string_literal: true

module Lib
  # Client-side staging object for a popup of labeled choices anchored to a
  # hex -- the third selector alongside Lib::TileSelector and
  # Lib::TokenSelector. A step opts in via `hex_choices(entity, hex)`.
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
