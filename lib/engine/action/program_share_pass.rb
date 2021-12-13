# frozen_string_literal: true

require_relative 'base'
require_relative 'program_enable'

module Engine
  module Action
    class ProgramSharePass < ProgramEnable
      attr_reader :unconditional

      def initialize(entity, unconditional: false)
        super(entity)
        @unconditional = unconditional
      end

      def self.h_to_args(h, _game)
        { unconditional: h['unconditional'] }
      end

      def args_to_h
        { 'unconditional' => @unconditional }
      end

      def to_s
        unconditionally = @unconditional ? ', unconditionally' : ''
        "Pass in Stock Round#{unconditionally}"
      end

      def disable?(game)
        !game.round.stock?
      end
    end
  end
end
