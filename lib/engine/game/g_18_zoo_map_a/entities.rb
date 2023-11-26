# frozen_string_literal: true

require_relative '../g_18_zoo/entities'

module Engine
  module Game
    module G18ZOOMapA
      module Entities
        include G18ZOO::Entities
        CORPORATIONS = ALL_CORPORATIONS.select { |corporation| %w[GI PB PE LI TI].include?(corporation[:sym]) }.freeze

        CORPORATION_COORDINATES = { 'GI' => 'K9', 'PB' => 'N10', 'PE' => 'K17', 'LI' => 'E15', 'TI' => 'H14' }.freeze
      end
    end
  end
end
