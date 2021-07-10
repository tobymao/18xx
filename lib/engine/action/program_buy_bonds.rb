# frozen_string_literal: true

require_relative 'base'
require_relative 'program_enable'

module Engine
  module Action
    class ProgramBuyBonds < ProgramEnable
      attr_reader :issuer, :until_condition, :from_market

      def initialize(entity, issuer:, until_condition:, from_market: true)
        super(entity)
        @issuer = issuer
        # Number of bonds the player should have to exit the condition.
        @until_condition = until_condition
        @from_market = from_market
      end

      def self.h_to_args(h, game)
        {
          issuer: game.issuer_by_id(h['issuer']),
          until_condition: h['until_condition'],
          from_market: h['from_market'],
        }
      end

      def args_to_h
        { 'issuer' => @issuer.id, 'until_condition' => @until_condition, from_market: @from_market }
      end

      def self.description
        'Buy bonds until condition is met'
      end

      def self.print_name
        'Buy Bonds'
      end

      def disable?(game)
        !game.round.stock?
      end
    end
  end
end
