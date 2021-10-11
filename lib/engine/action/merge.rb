# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class Merge < Base
      attr_reader :corporation, :minor

      def initialize(entity, corporation: nil, minor: nil)
        super(entity)
        @corporation = corporation
        @minor = minor
      end

      def self.h_to_args(h, game)
        {
          corporation: game.corporation_by_id(h['corporation']),
          minor: game.minor_by_id(h['minor']),
        }
      end

      def args_to_h
        {
          'corporation' => @corporation&.id,
          'minor' => @minor&.id,
        }
      end
    end
  end
end
