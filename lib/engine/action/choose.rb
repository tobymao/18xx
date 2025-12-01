# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class Choose < Base
      attr_reader :choice

      REQUIRED_ARGS = %i[choice].freeze

      def initialize(entity, choice:)
        super(entity)
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
