# frozen_string_literal: true

require_relative '../g_18_zoo/entities'

module Engine
  module Game
    module G18ZOOMapE
      module Entities
        include G18ZOO::Entities
        CORPORATIONS = ALL_CORPORATIONS.select do |corporation|
          %w[CR GI PB PE TI BB EL].include?(corporation[:sym])
        end.freeze

        CORPORATION_COORDINATES = {
          'CR' => 'H3',
          'GI' => 'K10',
          'PB' => 'N11',
          'PE' => 'K18',
          'TI' => 'H15',
          'BB' => 'I6',
          'EL' => 'D5',
        }.freeze
      end
    end
  end
end
