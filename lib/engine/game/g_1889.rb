# frozen_string_literal: true

require 'engine/bank'
require 'engine/company/base'
require 'engine/company/tile_laying'
require 'engine/company/terrain_discount'
require 'engine/corporation/base'
require 'engine/game/base'

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
    end
  end
end
