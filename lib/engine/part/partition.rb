# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Partition < Base
      attr_reader :a, :a_sign, :b, :b_sign, :type, :restrict, :blockers, :inner, :outer

      SIGN = {
        '-' => -1,
        nil => 0,
        '+' => 1,
      }.freeze

      def initialize(a, b, type, restrict)
        # Vertices: 0 = hex centre (city 0 convention); 1-6 = corners clockwise from bottom-right.
        # Sign suffix (e.g. '1+') shifts the draw position only — no routing effect.
        a, b = [a, b].minmax
        # DSL 0 (centre) → internal -1; DSL 1-6 (corners) → internal 0-5
        @a = a == '0' ? -1 : a.to_i - 1
        @a_sign = @a.negative? ? 0 : SIGN[a[1]]
        @b = b.to_i - 1
        @b_sign = SIGN[b[1]]

        @type = type&.to_sym
        # If restrict==inner, only allow paths between a and b. If outer, only between b and a
        @restrict = restrict
        @blockers = []

        @inner = @a.negative? || restrict == 'outer' ? [] : (@a..(@b - 1)).to_a
        @outer = @a.negative? || restrict == 'inner' ? [] : (0..5).to_a - (@a..(@b - 1)).to_a
      end

      def add_blocker!(private_company)
        @blockers << private_company
      end

      def partition?
        true
      end
    end
  end
end
