# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class Bonus < Base
      attr_reader :corporation

      # This exists only to test & demonstrate functionality of Derived / Auto Actions
      def initialize(entity)
        super(entity)

        @corporation = entity
        @derived = true
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
