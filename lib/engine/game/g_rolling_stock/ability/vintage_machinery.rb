# frozen_string_literal: true

require_relative '../../../ability/base'

module Engine
  module Game
    module GRollingStock
      module Ability
        class VintageMachinery < Engine::Ability::Base
          def description
            'Reduced Cost of Ownership'
          end

          def desc_detail
            'Cost of ownership is reduced by up to $10 (but not below $0)'
          end
        end
      end
    end
  end
end
