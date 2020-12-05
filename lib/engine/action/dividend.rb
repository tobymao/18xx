# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class Dividend < Base
      attr_reader :kind

      def initialize(entity, kind:)
        super
        @kind = kind
      end

      def self.h_to_args(h, _game)
        { kind: h['kind'] }
      end

      def args_to_h
        { 'kind' => @kind }
      end
    end
  end
end
