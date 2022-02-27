# frozen_string_literal: true

module Engine
  module Game
    module G18MT
      module Market
        MARKET_TEXT = {
          par: 'Par value',
          no_cert_limit: 'Corporation shares do not count towards cert limit',
          multiple_buy: 'Corporation shares can be held above 60%, '\
                        'Can buy more than one share from the market in the corporation per turn',
          endgame: 'End game trigger',
        }.freeze

        MARKET = [
          %w[70
             80
             90
             100
             115
             130
             150
             175
             205
             240
             275
             310
             350
             390e
             435e
             485e],
          %w[60
             65
             75
             85
             100
             115
             135p
             160
             185
             215
             245
             270
             310
             345
             385e
             425e],
          %w[50
             55
             65
             75
             90
             105p
             125p
             145
             170
             195
             220
             245
             275
             305
             335
             370e],
          %w[40
             45
             55
             65
             80p
             90p
             105
             125
             145
             170
             195
             215
             240
             265
             290
             320],
          %w[35
             40
             50
             60p
             70p
             85
             100
             115
             130
             150
             170
             185
             205],
          %w[30 35 45p 55p 65 75 85 100 115 130],
          %w[25 30 40p 50y 60y 70y 80y 90],
          %w[25b 30y 35y 45y 55y 65y 75y],
          %w[20b 25b 30y 40y 50y 60y],
          %w[15b 20b 25b 35y 45y 55y],
          %w[10b 15b 20b 30b 40y],
          %w[10b 10b 15b 25b 35b],
          %w[10b 10b 10b 20b 30b],
        ].freeze
      end
    end
  end
end
