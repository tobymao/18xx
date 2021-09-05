# frozen_string_literal: true

require_relative 'base'
require_relative 'program_enable'

module Engine
  module Action
    class ProgramIndependentMines < ProgramEnable
      attr_reader :indefinite

      def initialize(entity, indefinite:)
        super(entity)
        @indefinite = indefinite
      end

      def self.h_to_args(h, _game)
        { indefinite: h['indefinite'] }
      end

      def args_to_h
        { 'indefinite' => @indefinite }
      end

      def self.description
        "Pass on independent mines until #{@indefinite ? 'turned off' : 'next SR'}"
      end

      def self.print_name
        'Pass on independent mines'
      end

      def disable?(game)
        !game.round.operating? && !@indefinite
      end
    end
  end
end
