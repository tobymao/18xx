# frozen_string_literal: true

require_relative '../../../ability/base'

module Engine
  module Game
    module GRollingStock
      module Ability
        class Prussian < Engine::Ability::Base
          def description
            'Extra $1/company'
          end

          def desc_detail
            'Receives +$1 for each company it owns'
          end
        end
      end
    end
  end
end
