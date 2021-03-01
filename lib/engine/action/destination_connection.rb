# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class DestinationConnection < Base
      attr_reader :corporations, :minors

      def initialize(entity, corporations: nil, minors: nil)
        super(entity)
        @corporations = corporations
        @minors = minors
      end

      def self.h_to_args(h, game)
        {
          corporations: h['corporations']&.map { |c| game.corporation_by_id(c) },
          minors: h['minors']&.map { |m| game.minor_by_id(m) },
        }
      end

      def args_to_h
        {
          'corporations' => @corporations&.map(&:id),
          'minors' => @minors&.map(&:id),
        }
      end
    end
  end
end
