# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class UseGraph < Base
      attr_reader :graph_id

      def initialize(entity, graph_id:)
        super(entity)
        @graph_id = graph_id
      end

      def self.h_to_args(h, _game)
        {
          graph_id: h['graph_id'],
        }
      end

      def args_to_h
        {
          'graph_id' => @graph_id,
        }
      end
    end
  end
end
