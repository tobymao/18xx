# frozen_string_literal: true

require_relative '../../../ability/base'

module Engine
  module Game
    module GRollingStock
      module Ability
        class Overseas < Engine::Ability::Base
          def description
            'Foreign Investor Trading'
          end

          def desc_detail
            'First priority and only pays face value when trading with Foreign Investor'
          end
        end
      end
    end
  end
end
