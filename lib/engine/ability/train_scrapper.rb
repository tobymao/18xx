# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class TrainScrapper < Base
      def setup(scrap_values: {})
        @scrap_values = scrap_values
      end

      def scrap_value(train)
        @scrap_values[train.name] || 0
      end
    end
  end
end
