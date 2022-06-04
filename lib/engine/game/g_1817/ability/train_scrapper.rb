# frozen_string_literal: true

require_relative '../../../ability/base'

module Engine
  module Game
    module G18NY
      module Ability
        class TrainScrapper < Engine::Ability::Base
          def setup(scrap_values: {})
            @scrap_values = scrap_values
          end

          def scrap_value(train)
            @scrap_values[train.name] || 0
          end
        end
      end
    end
  end
end
