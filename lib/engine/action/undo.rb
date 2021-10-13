# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class Undo < Base
      attr_reader :action_id

      def initialize(entity, action_id: nil)
        super(entity)
        @action_id = action_id
      end

      def self.h_to_args(h, _)
        { action_id: h['action_id'] }
      end

      def args_to_h
        { 'action_id' => @action_id }
      end

      def free?
        true
      end
    end
  end
end
