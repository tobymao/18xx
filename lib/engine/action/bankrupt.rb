# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class Bankrupt < Base
      attr_reader :option

      def initialize(entity, option: nil)
        super(entity)
        @option = option
      end

      def self.h_to_args(h, _game)
        {
          option: h['option'],
        }
      end

      def args_to_h
        {
          'option' => @option,
        }
      end
    end
  end
end
