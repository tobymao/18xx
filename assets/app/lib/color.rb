# frozen_string_literal: true

module Lib
  module Color
    def self.convert_hex_to_rgba(color, alpha)
      m = color.match(/#(..)(..)(..)/)
      "rgba(#{m[1].hex},#{m[2].hex},#{m[3].hex},#{alpha})"
    end
  end
end
