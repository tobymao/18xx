# frozen_string_literal: true

require_relative 'base'
require_relative 'program_enable'

module Engine
  module Action
    class ProgramBuyShares < ProgramEnable
      attr_reader :corporation, :until_condition, :from_market, :auto_pass_after

      def initialize(entity, corporation:, until_condition:, from_market: false, auto_pass_after: false)
        super(entity)
        @corporation = corporation
        # Either float, or number of shares the player should have to exit the condition.
        @until_condition = until_condition
        @from_market = from_market
        @auto_pass_after = auto_pass_after
      end

      def self.h_to_args(h, game)
        {
          corporation: game.corporation_by_id(h['corporation']),
          until_condition: h['until_condition'],
          from_market: h['from_market'],
          auto_pass_after: h['auto_pass_after'],
        }
      end

      def args_to_h
        {
          'corporation' => @corporation.id,
          'until_condition' => @until_condition,
          'from_market' => @from_market,
          'auto_pass_after' => @auto_pass_after,
        }
      end

      def to_s
        source = @from_market ? 'market' : 'IPO'
        condition = @until_condition == 'float' ? 'floated' : "#{@until_condition} shares"
        suffix = @auto_pass_after ? ', then auto pass' : ''
        "Buy #{corporation.name} from #{source} until #{condition}#{suffix}"
      end

      def disable?(game)
        !game.round.stock?
      end
    end
  end
end
