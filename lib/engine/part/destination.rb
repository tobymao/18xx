# frozen_string_literal: true

require_relative 'icon'

module Engine
  module Part
    class Destination < Icon
      attr_reader :minor, :corporation

      def initialize(image:, sticky: true, blocks_lay: nil, preprinted: true, minor: nil, corporation: nil)
        # There is almost certainly a better error than this th
        unless (minor || corporation) || (minor && corporation)
          raise 'One and only one of minor or corporation must be specified'
        end

        @name ||= corporation
        @name ||= minor
        @image = "/#{image}.svg"
        @sticky = !!sticky
        @preprinted = preprinted
        @blocks_lay = !!blocks_lay
      end

      def destination?
        true
      end
    end
  end
end
