# frozen_string_literal: true

require_relative 'base'
require_relative '../item'

module Engine
  module Step
    class BuySpecial < Base
      ACTIONS = %w[buy_special pass].freeze
      ACTIONS_NO_PASS = %w[buy_special].freeze

      attr_accessor :items

      def actions(entity)
        return blocks? ? ACTIONS : ACTIONS_NO_PASS if can_buy_special?(entity)

        []
      end

      def can_buy_special?(_entity)
        false
      end

      def blocks?
        @blocks
      end

      def description
        'Buy Special'
      end

      def short_description; end

      def pass_description
        @acted ? "Done (#{short_description})" : "Skip (#{short_description})"
      end

      def process_buy_special(action); end

      def setup
        @items = []
        @blocks = @opts[:blocks] || false
      end
    end
  end
end
