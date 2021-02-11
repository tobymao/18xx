# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class DestinationConnection < Base
      attr_reader :corporations

      def initialize(entity, corporations:)
        super(entity)
        @corporations = corporations
      end

      def self.h_to_args(h, game)
        { corporations: h['corporations'].map { |c| game.corporation_by_id(c) } }
      end

      def args_to_h
        { 'corporations' => @corporations.map(&:id) }
      end
    end
  end
end
