# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class Assign < Base
      attr_reader :target

      def initialize(entity, target:)
        super(entity)
        @target = target
      end

      def self.h_to_args(h, game)
        { target: game.get(h['target_type'], h['target']) }
      end

      def args_to_h
        {
          'target' => @target.id,
          'target_type' => type_s(@target),
        }
      end
    end
  end
end
