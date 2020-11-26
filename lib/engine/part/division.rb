# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Division < Base
      attr_reader :a, :asign, :b, :bsign, :type, :restrict, :magnet, :blockers, :inner, :outer

      SIGN = {
        '-' => -1,
        nil => 0,
        '+' => 1,
      }.freeze

      def initialize(a, b, type, restrict, magnet)
        a, b = [a, b].minmax
        @a = a[0].to_i
        @asign = SIGN[a[1]]
        @b = b[0].to_i
        @bsign = SIGN[b[1]]

        @type = type
        @restrict = restrict
        @magnet = magnet&.to_i
        @blockers = []

        @inner = (@a..(@b - 1)).to_a
        @outer = (0..5).to_a - inner
        @inner = [] if restrict == 'outer'
        @outer = [] if restrict == 'inner'
      end

      def add_blocker!(private_company)
        @blockers << private_company
      end

      def division?
        true
      end
    end
  end
end
