# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    # This is an example for how derived actions may be used
    class Bonus < Base
      attr_reader :corporation

      # This exists only to test & demonstrate functionality of Derived / Auto Actions
      def initialize(entity)
        super(entity)

        @corporation = entity
        # Derived is set automatically. round_override is not.
        @round_override = true
      end

      def self.h_to_args(h, game)
        {
          corporation: game.corporation_by_id(h['corporation']),
        }
      end

      def args_to_h
        {
          'corporation' => @corporation&.id,
        }
      end
    end
  end
end
