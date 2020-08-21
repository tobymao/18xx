# frozen_string_literal: true

module Lib
  module Color
    def convert_hex_to_rgba(color, alpha)
      m = color.match(/#(..)(..)(..)/)
      "rgba(#{m[1].hex},#{m[2].hex},#{m[3].hex},#{alpha})"
    end

    # helper functions to calc contrasting bg, font and logo colors
    # https://www.w3.org/TR/AERT/#color-contrast
    def brightness(hexcolor)
      m = hexcolor.match(/#(..)(..)(..)/)
      red = m[1].to_i(16)
      green = m[2].to_i(16)
      blue = m[3].to_i(16)
      Math.sqrt((0.299 * red)**2 + (0.587 * green)**2 + (0.114 * blue)**2) / 1000
    end

    # https://www.w3.org/TR/2008/REC-WCAG20-20081211/#contrast-ratiodef
    def contrast(color1, color2)
      brightest = [brightness(color1), brightness(color2)].max
      darkest = [brightness(color1), brightness(color2)].min
      (brightest + 0.05) / (darkest + 0.05)
    end

    def contrast_on(color)
      # *1.8 to skew towards white on color => black only on really light colors
      contrast('#ffffff', color) * 1.8 > contrast('#000000', color) ? '#ffffff' : '#000000'
    end
  end
end
