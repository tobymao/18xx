# frozen_string_literal: true

require_relative 'base'
require_relative 'program_enable'

module Engine
  module Action
    class ProgramIndependentMines < ProgramEnable
      attr_reader :indefinite, :skip_track, :skip_buy, :skip_close

      def initialize(entity, skip_track:, skip_buy:, skip_close:, indefinite:)
        super(entity)
        @skip_track = skip_track
        @skip_buy = skip_buy
        @skip_close = skip_close
        @indefinite = indefinite
      end

      def self.h_to_args(h, _game)
        {
          skip_track: h['skip_track'],
          skip_buy: h['skip_buy'],
          skip_close: h['skip_close'],
          indefinite: h['indefinite'],
        }
      end

      def args_to_h
        {
          'skip_track' => @skip_track,
          'skip_buy' => @skip_buy,
          'skip_close' => @skip_close,
          'indefinite' => @indefinite,
        }
      end

      def to_s
        steps = []
        steps << 'track' if @skip_track
        steps << 'buy trains' if @skip_buy
        steps << 'close' if @skip_close
        steps << 'nothing?!' if steps.empty?
        condition = @indefinite ? 'turned off' : 'next SR'
        "Pass (#{steps.join(',')}) for independent mines until #{condition}"
      end

      def disable?(game)
        !game.round.operating? && !@indefinite
      end
    end
  end
end
