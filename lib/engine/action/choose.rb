# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class Choose < Base
      attr_reader :choice, :target

      REQUIRED_ARGS = %i[choice].freeze

      def initialize(entity, choice:, target: nil)
        super(entity)
        @choice = choice
        @target = target
      end

      def self.h_to_args(h, game)
        {
          choice: h['choice'],
          target: h['target'] ? game.get(h['target_type'], h['target']) : nil,
        }
      end

      def args_to_h
        {
          'choice' => @choice,
          'target' => @target&.id,
          'target_type' => (type_s(@target) if @target),
        }
      end
    end
  end
end
