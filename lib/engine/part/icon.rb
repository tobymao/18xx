# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Icon < Base
      attr_accessor :preprinted
      attr_reader :image, :name, :sticky

      def initialize(image, name = nil, sticky = true, blocks_lay = nil, preprinted = true)
        @image = "/icons/#{image}.svg"
        @name = name || image
        @sticky = !!sticky
        @preprinted = preprinted
        @blocks_lay = !!blocks_lay
      end

      def blocks_lay?
        @blocks_lay
      end

      def icon?
        true
      end
    end
  end
end
