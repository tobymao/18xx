# frozen_string_literal: true

require_relative 'base'
require_relative '../ownable'

module Engine
  module Part
    class Icon < Base
      include Ownable

      attr_accessor :preprinted, :image, :large, :loc
      attr_reader :name, :sticky

      def initialize(image, name = nil, sticky = true, blocks_lay = nil, preprinted = true, large: false, owner: nil, loc: nil)
        @image = "/icons/#{image}.svg"
        @name = name || image.split('/')[-1]
        @sticky = !!sticky
        @preprinted = preprinted
        @blocks_lay = !!blocks_lay
        @large = !!large
        @owner = owner
        @loc = loc
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
