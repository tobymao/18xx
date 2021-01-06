# frozen_string_literal: true

require_relative 'base'
require_relative '../item'

module Engine
  module Step
    class SpecialBuy < Base
      ACTIONS = %w[special_buy pass].freeze
      ACTIONS_NO_PASS = %w[special_buy].freeze

      def actions(entity)
        return blocks? ? ACTIONS : ACTIONS_NO_PASS unless buyable_items(entity).empty?

        []
      end

      def blocks?
        @blocks
      end

      # Which items are buyable for this entity?
      def buyable_items(_entity)
        []
      end

      def description
        'Special Buy'
      end

      def short_description; end

      def pass_description
        @acted ? "Done (#{short_description})" : "Skip (#{short_description})"
      end

      def process_special_buy(action); end

      def setup
        @blocks = @opts[:blocks] || false
      end
    end
  end
end
