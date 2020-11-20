# frozen_string_literal: true

module Lib
  module Hex
    X_R = 100
    X_M_R = 50
    X_M_L = -50
    X_L = -100
    Y_M = 0
    Y_T = -87
    Y_B = 87

    POINTS = "#{X_R},#{Y_M} #{X_M_R},#{Y_B} #{X_M_L},#{Y_B} #{X_L},#{Y_M} #{X_M_L},#{Y_T} #{X_M_R},#{Y_T}"

    COLOR = {
      white: '#EAE0C8',
      yellow: '#fde900',
      green: '#71bf44',
      brown: '#cb7745',
      gray: '#bcbdc0',
      red: '#ec232a',
      blue: '#35A7FF',
    }.freeze

    def self.points(scale: 1.0)
      "#{X_R * scale},#{Y_M * scale} #{X_M_R * scale},#{Y_B * scale} "\
      "#{X_M_L * scale},#{Y_B * scale} #{X_L * scale},#{Y_M * scale} "\
      "#{X_M_L * scale},#{Y_T * scale} #{X_M_R * scale},#{Y_T * scale}"
    end
  end
end
