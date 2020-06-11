# frozen_string_literal: true

module Lib
  class TokenSelector
    attr_reader :hex, :x, :y, :city, :slot_index, :tokens

    def initialize(hex, coordinates, city, slot_index, tokens)
      @hex = hex
      @x, @y = coordinates
      @city = city
      @slot_index = slot_index
      @tokens = tokens
    end
  end
end
