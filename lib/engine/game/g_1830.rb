# frozen_string_literal: true

require_relative 'base'

module Engine
  module Game
    class G1830 < Base
      # rubocop:disable Lint/EmptyExpression, Layout/SpaceInsideArrayPercentLiteral, Lint/EmptyInterpolation
      MARKET = [
        %w[60y 67  71  76  82  90  100p 112 126 142 160 180 200 225 250 275 300 325 350],
        %w[53y 60y 66  70  76  82  90p  100 112 126 142 160 180 200 220 240 260 280 300],
        %w[46y 55y 60y 65  70  76  82p  90  100 111 125 140 155 170 185 200],
        %w[39o 48y 54y 60y 66  71  76p  82  90   100 110 120 130],
        %w[32o 41o 48y 55y 62  67  71p  76  82   90   100],
        %w[25b 34o 42o 50y 58y 65  67p  71  75   80],
        %w[18b 27b 36o 45o 54y 63  67   69  70],
        %w[10b 20b 30b 40o 50y 60y 67   68],
        %W[#{} 10b 20b 30b 40o 50y 60y],
        %W[#{} #{} 10b 20b 30b 40o 50y],
        %W[#{} #{} #{} 10b 20b 30b 40o],
      ].freeze
      # rubocop:enable Lint/EmptyExpression, Layout/SpaceInsideArrayPercentLiteral, Lint/EmptyInterpolation
    end
  end
end
