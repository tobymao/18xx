# frozen_string_literal: true

module Lib
  class HexChoiceSelector
    attr_reader :hex, :x, :y, :choices

    def initialize(hex, coordinates, choices)
      @hex = hex
      @x, @y = coordinates
      @choices = choices
    end

    def role
      :hex_choice
    end
  end
end
