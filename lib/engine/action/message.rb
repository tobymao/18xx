# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class Message < Base
      attr_reader :message

      def initialize(entity, message)
        @entity = entity
        @message = message
      end

      def self.h_to_args(h, _)
        [h['message']]
      end

      def args_to_h
        { 'message' => @message }
      end

      def free?
        true
      end
    end
  end
end
