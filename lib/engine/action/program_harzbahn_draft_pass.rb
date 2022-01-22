# frozen_string_literal: true

require_relative 'base'
require_relative 'program_enable'

module Engine
  module Action
    class ProgramHarzbahnDraftPass < ProgramEnable
      attr_reader :until_premium, :unconditional

      def initialize(entity, until_premium:, unconditional:)
        super(entity)
        @until_premium = until_premium
        @unconditional = unconditional
      end

      def self.h_to_args(h, _game)
        {
          until_premium: h['until_premium'],
          unconditional: h['unconditional'],
        }
      end

      def args_to_h
        {
          'until_premium' => @until_premium,
          'unconditional' => @unconditional,
        }
      end

      def to_s
        until_premium = @until_premium ? ", until premium #{@until_premium}" : ''
        unconditionally = @unconditional ? ', unconditionally' : ''
        "Pass in Draft#{until_premium}#{unconditionally}"
      end

      def disable?(game)
        !game.round.auction?
      end
    end
  end
end
