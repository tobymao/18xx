# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Destination < Base
      # Functionally is an extension of Icon
      attr_accessor :preprinted
      attr_reader :image, :name, :sticky, :minor, :corporation

      def initialize(image:, name: nil, sticky: true, blocks_lay: nil, preprinted: true, minor: nil, corporation: nil)
        # There is almost certainly a better error than this th
        raise 'One and only one of minor or corporation must be specified' unless (minor || corporation) || (minor && corporation)
        @name |= corporation
        @name |= minor
        @image = "/#{image}.svg"
        @sticky = !!sticky
        @preprinted = preprinted
        @blocks_lay = !!blocks_lay
      end

      def blocks_lay?
        @blocks_lay
      end

      def destination?
        true
      end

      def icon?
        true
      end
    end
  end
end
