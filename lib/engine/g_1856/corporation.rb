# frozen_string_literal: true

require_relative '../corporation'

module Engine
  module G1856
    class Corporation < Corporation
      def initialize(game, sym:, name:, **opts)
        @game = game
        @started = false
        super(sym: sym, name: name, **opts)
      end

      # ~Ab~RE-using floated? to represent whether or not a corporation has operated
      def floated?
        @started
      end

      def floatable?
        percent_of(self) <= 100 - percent_to_float
      end

      def float!
        @started = true
      end

      def par!
        @capitalization = capitalization_type
      end

      def capitalization_type
        # TODO: escrow
        return :incremental if @game.phase.status.include? :escrow
        return :incremental if @game.phase.status.include? :incremental
        return :full if @game.phase.status.include? :fullcap

        # This shouldn't happen
        raise NotImplementedError
      end

      def percent_to_float
        return 20 if @game.phase.status.include? :facing_2
        return 30 if @game.phase.status.include? :facing_3
        return 40 if @game.phase.status.include? :facing_4
        return 50 if @game.phase.status.include? :facing_5
        return 60 if @game.phase.status.include? :facing_6

        # This shouldn't happen
        raise NotImplementedError
      end
    end
  end
end
