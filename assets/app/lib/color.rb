# frozen_string_literal: true

require 'lib/hex'

module Lib
  module Color
    COLORS = {
      bg: '#ffffff',
      bg2: '#dcdcdc',
      font: '#000000',
      font2: '#000000',
    }.freeze
    COLORS.merge!(Lib::Hex::COLOR)

    def self.included(base)
      base.needs :user, default: nil, store: true
    end

    def color_for(category)
      @user&.dig(:settings, category) || COLORS[category]
    end

    def self.convert_hex_to_rgba(color, alpha)
      m = color.match(/#(..)(..)(..)/)
      "rgba(#{m[1].hex},#{m[2].hex},#{m[3].hex},#{alpha})"
    end

    # helper functions to calc contrasting bg, font and logo colors
    # https://www.w3.org/TR/AERT/#color-contrast
    def self.brightness(hexcolor)
      m = hexcolor.match(/#(..)(..)(..)/)
      red = m[1].to_i(16)
      green = m[2].to_i(16)
      blue = m[3].to_i(16)
      Math.sqrt(
        0.299 * red**2 +
        0.587 * green**2 +
        0.114 * blue**2
      ).to_i
    end

    # https://www.w3.org/TR/2008/REC-WCAG20-20081211/#contrast-ratiodef
    def self.contrast(color1, color2)
      brightest = [brightness(color1), brightness(color2)].max
      darkest = [brightness(color1), brightness(color2)].min
      (brightest + 0.05) / (darkest + 0.05)
    end
  end
end
