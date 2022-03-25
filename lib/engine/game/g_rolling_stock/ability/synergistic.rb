# frozen_string_literal: true

require_relative '../../../ability/base'

module Engine
  module Game
    module GRollingStock
      module Ability
        class Synergistic < Engine::Ability::Base
          def description
            'Extra $1/pair of synergy markers'
          end

          def desc_detail
            'Receives +$1 for every two synergy markers it owns (rounded down)'
          end
        end
      end
    end
  end
end
