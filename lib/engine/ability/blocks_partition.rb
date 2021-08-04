# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class BlocksPartition < Base
      attr_reader :partition_type

      def setup(partition_type:)
        @partition_type = partition_type
      end

      def blocks?(partition_type)
        @partition_type == partition_type
      end
    end
  end
end
