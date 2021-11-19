# frozen_string_literal: true

require_relative '../../../ability/base'

module Engine
  module Game
    module G18NY
      module Ability
        class ConnectionBonus < Engine::Ability::Base
          attr_accessor :bonus_revenue

          def setup(bonus_revenue:)
            @bonus_revenue = bonus_revenue
          end

          def description
            "Connection Bonus Revenue: $#{bonus_revenue}"
          end
        end
      end
    end
  end
end
