# frozen_string_literal: true

require_relative '../../../ability/base'

module Engine
  module Game
    module GRollingStock
      module Ability
        class Doppler < Engine::Ability::Base
          def description
            'Double best company'
          end

          def desc_detail
            'Doubles printed income of its best company'
          end
        end
      end
    end
  end
end
