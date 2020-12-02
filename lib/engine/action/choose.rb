# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class Choose < Base
      attr_reader :choice

      def initialize(entity, choice:)
        @entity = entity
        @choice = choice
      end

      def self.h_to_args(h, _game)
        {
          choice: h['choice'],
        }
      end

      def args_to_h
        {
          'choice' => @choice,
        }
      end
    end
  end
end
