# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class Undo < Base
      attr_reader :steps

      def initialize(entity, steps)
        @entity = entity
        @steps = steps
      end

      def self.keep_on_undo?
        true
      end

      def self.h_to_args(h, _)
        [h['steps']]
      end

      def args_to_h
        { 'steps' => @steps }
      end
    end
  end
end
