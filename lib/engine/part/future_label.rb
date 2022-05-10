# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    # There are many games where a city gets a plain yellow city, but gets a special green tile, or something similar
    # where the label changes at some point in the tile upgrade path. This "future label" is to represent that
    # sticker - has this future label been put on the tile by someone else, or did it come with this?
    # nil if original; original FutureLabel if it has been modified
    class FutureLabel < Base
      attr_accessor :sticker
      attr_reader :color, :label

      def initialize(label = nil, color = nil)
        @label = label
        @color = color
        @sticker = nil
      end

      def future_label?
        true
      end
    end
  end
end
