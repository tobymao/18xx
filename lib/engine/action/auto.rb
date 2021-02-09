# frozen_string_literal: true

require_relative 'base'

# The Auto action type exists for auto_actions
# This is to be used when the action that is automatically being done
# is a basic check or otherwise not worth creating an Action class
# Details is a string.
module Engine
  module Action
    class Auto < Base
      attr_reader :details

      def initialize(entity, details:)
        super(entity)
        @details = details
      end

      def self.h_to_args(h, _game)
        { details: h['details'] }
      end

      def args_to_h
        { 'details' => @details }
      end
    end
  end
end
