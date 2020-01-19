# frozen_string_literal: true

require 'engine/bank'
require 'engine/company/base'
require 'engine/company/tile_laying'
require 'engine/company/terrain_discount'
require 'engine/corporation/base'
require 'engine/game/base'
require 'engine/hex'
require 'engine/map'
require 'engine/tile'

module Engine
  module Game
    class G1889 < Base
      private

      def init_bank
        Bank.new(7000)
      end

      def init_companies
        [
          Company::Base.new('Takamatsu E-Railroad', value: 20, income: 5),
          # Company::TileLaying.new('Mitsubishi Ferry', value: 30, income: 5),
          # Company::TileLaying.new('Ehime Railway', value: 40, income: 10),
          # Company::TerrainDiscount.new('Sumitomo Mines Railway', value: 50, income: 15),
        ]
      end

      def init_corporations
        [
          Corporation::Base.new('AR', name: 'Awa Railroad', tokens: 2),
          Corporation::Base.new('IR', name: 'Iyo Railway', tokens: 2),
          Corporation::Base.new('SR', name: 'Sanuki Railway', tokens: 2),
          Corporation::Base.new('KO', name: 'Takamatsu & Kotohira Electric Railway', tokens: 2),
          Corporation::Base.new('TR', name: 'Tosa Electric Railway', tokens: 3),
          Corporation::Base.new('KU', name: 'Tosa Kuroshio Railway', tokens: 1),
          Corporation::Base.new('UR', name: 'Uwajima Railway', tokens: 3),
        ]
      end

      def init_map
        coordinates = %w[
          A8 A10 B3 B5 B7 B9 B11 C4 C6 C8 C10
          D3 D5 D7 D9 E2 E4 E6 E8 F1 F3 F5
          F7 F9 G4 G6 G8 G10 G12 G14 H3 H5 H7
          H9 H11 H13 I2 I4 I6 I8 I10 I12 J1 J3
          J5 J7 J9 J11 K4 K6 K8 L7
        ]

        Map.new(coordinates.map do |c|
                  tile = begin
                    Tile.for("1889;#{c}")
                         rescue StandardError
                           nil
                  end
                  Hex.new(c, layout: :flat, tile: tile)
                end)
      end
    end
  end
end
