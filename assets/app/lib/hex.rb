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

    # 3 stripes, the outer stripes *must* overlap the corner of the hex
    # so 3 x STRIPE_WIDTH < X_M_R < 5 x STRIPE_WIDTH < X_R

    # 10 < STRIPE_WIDTH < 16.67
    STRIPE_WIDTH = 16

    POINTS = "#{X_R},#{Y_M} #{X_M_R},#{Y_B} #{X_M_L},#{Y_B} #{X_L},#{Y_M} #{X_M_L},#{Y_T} #{X_M_R},#{Y_T}".freeze

    EDGE_PATHS = [
      "M #{X_M_R},#{Y_B} H #{X_M_L}",
      "M #{X_M_L},#{Y_B} L #{X_L}, #{Y_M}",
      "M #{X_L},#{Y_M} #{X_M_L},#{Y_T}",
      "M #{X_M_L},#{Y_T} H #{X_M_R}",
      "M #{X_M_R},#{Y_T} L #{X_R},#{Y_M}",
      "M #{X_R},#{Y_M} L #{X_M_R}, #{Y_B}",
    ].freeze

    INTERSECT = Y_T + (((5 * STRIPE_WIDTH) - X_M_R).to_f * Y_T.to_f / (X_M_R - X_R).to_f).to_i
    # 3 lists of points
    STRIPE_POINTS = [
      [[-1 * STRIPE_WIDTH, Y_T], [STRIPE_WIDTH, Y_T], [STRIPE_WIDTH, -1 * Y_T], [-1 * STRIPE_WIDTH, -1 * Y_T]],
      [
        [3 * STRIPE_WIDTH, Y_T],
        [X_M_R, Y_T],
        [5 * STRIPE_WIDTH, INTERSECT],
        [5 * STRIPE_WIDTH, -1 * INTERSECT],
        [X_M_R, -1 * Y_T],
        [3 * STRIPE_WIDTH, -1 * Y_T],
      ],
      [
        [-3 * STRIPE_WIDTH, Y_T],
        [-1 * X_M_R, Y_T],
        [-5 * STRIPE_WIDTH, INTERSECT],
        [-5 * STRIPE_WIDTH, -1 * INTERSECT],
        [-1 * X_M_R, -1 * Y_T],
        [-3 * STRIPE_WIDTH, -1 * Y_T],
      ],
    ].freeze

    def self.stripe_points
      STRIPE_POINTS.map { |points| points.map { |point| point.join(',') }.join(' ') }
    end

    COLOR = {
      white: '#EAE0C8',
      yellow: '#fde900',
      green: '#71bf44',
      brown: '#cb7745',
      gray: '#bcbdc0',
      black: '#000000',
      red: '#ec232a',
      blue: '#35A7FF',
      purple: '#A79ECD',
      orange: '#FFA500',
      sepia: '#6b4b35',
      gray60: '#96989d',
      gray50: '#7b7d84',
      gray40: '#626569',
    }.freeze

    def self.points(scale: 1.0)
      "#{(X_R * scale).round(3)},#{(Y_M * scale).round(3)} #{(X_M_R * scale).round(3)},#{(Y_B * scale).round(3)} "\
        "#{(X_M_L * scale).round(3)},#{(Y_B * scale).round(3)} #{(X_L * scale).round(3)},#{(Y_M * scale).round(3)} "\
        "#{(X_M_L * scale).round(3)},#{(Y_T * scale).round(3)} #{(X_M_R * scale).round(3)},#{(Y_T * scale).round(3)}"
    end
  end
end
