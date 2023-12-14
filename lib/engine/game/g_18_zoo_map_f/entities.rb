# frozen_string_literal: true

require_relative '../g_18_zoo/entities'

module Engine
  module Game
    module G18ZOOMapF
      module Entities
        include G18ZOO::Entities
        CORPORATIONS = ALL_CORPORATIONS.select do |corporation|
          %w[CR GI PE LI TI BB EL].include?(corporation[:sym])
        end.freeze

        CORPORATION_COORDINATES = {
          'CR' => 'I3',
          'GI' => 'L10',
          'PE' => 'L18',
          'LI' => 'F16',
          'TI' => 'I15',
          'BB' => 'J6',
          'EL' => 'E5',
        }.freeze
      end
    end
  end
end
