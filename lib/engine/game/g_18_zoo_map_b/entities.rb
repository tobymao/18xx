# frozen_string_literal: true

require_relative '../g_18_zoo/entities'

module Engine
  module Game
    module G18ZOOMapB
      module Entities
        include G18ZOO::Entities
        CORPORATIONS = ALL_CORPORATIONS.select { |corporation| %w[CR GI PB PE BB].include?(corporation[:sym]) }.freeze

        CORPORATION_COORDINATES = { 'CR' => 'H3', 'GI' => 'K10', 'PB' => 'N11', 'PE' => 'K18', 'BB' => 'I6' }.freeze
      end
    end
  end
end
