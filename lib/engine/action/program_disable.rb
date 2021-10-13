# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class ProgramDisable < Base
      attr_reader :reason

      def initialize(entity, reason:)
        super(entity)
        @reason = reason
      end

      def self.h_to_args(h, _game)
        { reason: h['reason'] }
      end

      def args_to_h
        { 'reason' => @reason }
      end
    end
  end
end
