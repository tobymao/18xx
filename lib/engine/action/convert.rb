# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class Convert < Base
      attr_reader :corporation

      def initialize(entity, corporation: nil)
        super(entity)
        @corporation = corporation
      end

      def self.h_to_args(h, game)
        {
          corporation: game.corporation_by_id(h['corporation']),
        }
      end

      def args_to_h
        {
          'corporation' => @corporation&.id,
        }
      end
    end
  end
end
