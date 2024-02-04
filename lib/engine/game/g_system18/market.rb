# frozen_string_literal: true

module Engine
  module Game
    module GSystem18
      module Market
        BANK_CASH = 12_000

        def cash_by_map
          if map?(:NEUS)
            { 2 => 850, 3 => 575 }
          elsif map?(:France)
            { 2 => 480, 3 => 320, 4 => 240 }
          else
            # default to make rake happy
            { 2 => 400, 3 => 300, 4 => 200 }
          end
        end

        def certs_by_map
          if map?(:NEUS)
            { 2 => 20, 3 => 13 }
          elsif map?(:France)
            { 2 => 20, 3 => 13, 4 => 10 }
          else
            # default to make rake happy
            { 2 => 20, 3 => 15, 4 => 10 }
          end
        end

        def capitalization_by_map
          if map?(:France)
            :incremental
          else
            # NEUS
            :full
          end
        end

        MARKET_2D = [
          %w[75
             80
             90
             100p
             110
             110
             125
             140
             160
             180
             200
             220
             250
             275],
          %w[70
             75
             80
             90p
             100
             110
             110
             125
             140
             160
             180
             200
             220
             250],
          %w[65y
             70
             75
             80p
             90
             100
             110
             110
             125
             140
             160
             180
             200
             220],
          %w[60y
             65
             70
             75p
             80
             90
             100
             110
             110
             125
             140],
          %w[55y
             60y
             65
             70p
             75
             80
             90
             100],
          %w[50o
             60y
             65
             65p
             70
             75
             80],
          %w[45o
             55y
             60y
             65
             65
             70],
          %w[40b
             50o
             60y
             65y
             65],
          %w[30b
             40b
             50o
             60y],
          %w[20b
             30b
             40b
             50o],
        ].freeze

        MARKET_1D = [
          %w[40
             45
             50p
             55p
             60p
             65p
             70p
             80p
             90p
             100p
             120p
             135p
             150p
             165
             180
             200
             220
             245
             270
             300
             360
             400
             440
             490
             540
             600],
        ].freeze

        def game_market
          if capitalization_by_map == :full
            MARKET_2D
          else
            MARKET_1D
          end
        end
      end
    end
  end
end
