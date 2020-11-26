# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class BlocksDivision < Base
      attr_reader :division_type

      def setup(division_type:)
        @division_type = division_type
      end

      def blocks?(division_type)
        @division_type == division_type
      end
    end
  end
end
