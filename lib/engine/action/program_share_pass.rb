# frozen_string_literal: true

require_relative 'base'
require_relative 'program_enable'

module Engine
  module Action
    class ProgramSharePass < ProgramEnable
      attr_reader :unconditional, :indefinite

      def initialize(entity, unconditional: false, indefinite: false)
        super(entity)
        @unconditional = unconditional
        @indefinite = indefinite
      end

      def self.h_to_args(h, _game)
        { unconditional: h['unconditional'], indefinite: h['indefinite'] }
      end

      def args_to_h
        { 'unconditional' => @unconditional, 'indefinite' => @indefinite }
      end

      def to_s
        unconditionally = @unconditional ? ', unconditionally' : ''
        indefinitely = @indefinite ? ', indefinitely' : ''
        "Pass in Stock Round#{unconditionally}#{indefinitely}"
      end

      def disable?(game)
        !game.round.stock? && !@indefinite
      end
    end
  end
end
