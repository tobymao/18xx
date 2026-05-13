# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Partition < Base
      attr_reader :a, :a_sign, :b, :b_sign, :length, :type, :restrict, :blockers, :inner, :outer

      SIGN = {
        '-' => -1,
        nil => 0,
        '+' => 1,
      }.freeze

      def initialize(a, b, type, restrict, length: nil)
        # Vertices 0-5 are hex corners clockwise from bottom-right.
        # Sign suffix (e.g. '0+') shifts draw position only — no routing effect.
        # len (float): a is the anchor at its full vertex; the line travels len fraction
        #   toward vertex b. length:0.5 on opposite vertices (e.g. a:3,b:0) reaches hex centre.
        # Without len, a/b are sorted (minmax) for consistent routing restriction ranges.
        a, b = [a, b].minmax unless length
        @a = a.to_i
        @a_sign = SIGN[a[1]]
        @b = b[0].to_i
        @b_sign = SIGN[b[1]]
        @lengthgth = len&.to_f

        @type = type&.to_sym
        # If restrict==inner, only allow paths between a and b. If outer, only between b and a
        @restrict = restrict
        @blockers = []

        @inner = restrict == 'outer' ? [] : (@a..(@b - 1)).to_a
        @outer = restrict == 'inner' ? [] : (0..5).to_a - (@a..(@b - 1)).to_a
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
