# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Partition < Base
      attr_reader :a, :a_sign, :b, :b_sign, :type, :restrict, :magnet, :blockers, :inner, :outer

      SIGN = {
        '-' => -1,
        nil => 0,
        '+' => 1,
      }.freeze

      def initialize(a, b, type, restrict, magnet)
        # a and b are vertices of the hex. 0 represents the bottom one and then you go clockwise
        # The sign tells if the partition should be drawn a little bit before or after the vertex,
        # but doesn't have any impact on the game
        a, b = [a, b].minmax
        @a = a[0].to_i
        @a_sign = SIGN[a[1]]
        @b = b[0].to_i
        @b_sign = SIGN[b[1]]

        @type = type
        # If restrict==inner, only allow paths between a and b. If outer, only between b and a
        @restrict = restrict
        # Pulls the river to this vertex. Also only cosmetic
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

      def partition?
        true
      end
    end
  end
end
