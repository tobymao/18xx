# frozen_string_literal: true

require 'engine/action/base'

module Engine
  module Action
    class Dividend < Base
      attr_reader :type

      def initialize(entity, type)
        @entity = entity
        @type = type
      end

      def self.h_to_args(h, _game)
        [h['type']]
      end

      def args_to_h
        {
          'train' => @type,
        }
      end
    end
  end
end
