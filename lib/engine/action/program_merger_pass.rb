# frozen_string_literal: true

require_relative 'base'
require_relative 'program_enable'

module Engine
  module Action
    class ProgramMergerPass < ProgramEnable
      attr_reader :corporations, :rounds

      def initialize(entity, corporations:, rounds:)
        super(entity)
        @corporations = corporations
        @rounds = rounds
      end

      def self.h_to_args(h, game)
        { corporations: h['corporations']&.map { |c| game.corporation_by_id(c) }, rounds: h['rounds'] }
      end

      def args_to_h
        { 'corporations' => @corporations.map(&:id), 'rounds' => @rounds }
      end

      def self.description
        'Automatically Pass conversion/mergers/offering corporations in merger/acquisition rounds'
      end

      def self.print_name
        'Pass in Mergers'
      end

      def disable?(game)
        !game.round.merger?
      end
    end
  end
end
