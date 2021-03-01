# frozen_string_literal: true

require_relative 'base'
require_relative 'program_enable'

module Engine
  module Action
    class ProgramBuyShares < ProgramEnable
      attr_reader :corporation, :until_condition

      def initialize(entity, corporation:, until_condition:)
        super(entity)
        @corporation = corporation
        @until_condition = until_condition
      end

      def self.h_to_args(h, game)
        { corporation: game.corporation_by_id(h['corporation']), until_condition: h['until_condition'] }
      end

      def args_to_h
        { 'corporation' => @corporation.id, 'until_condition' => @until_condition }
      end

      def self.description
        'Buy shares until condition is met'
      end

      def self.print_name
        'Buy Shares'
      end

      def disable?(game)
        !game.round.stock?
      end
    end
  end
end
