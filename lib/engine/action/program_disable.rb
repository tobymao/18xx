# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class ProgramDisable < Base
      attr_reader :reason, :original_type

      def initialize(entity, reason:, original_type: '')
        super(entity)
        @reason = reason
        @original_type = original_type
      end

      def self.h_to_args(h, _game)
        {
          reason: h['reason'],
          original_type: h['original_type'],
        }
      end

      def args_to_h
        {
          'reason' => @reason,
          'original_type' => @original_type,
        }
      end
    end
  end
end
