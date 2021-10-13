# frozen_string_literal: true

require_relative 'base'
require_relative '../ownable'

module Engine
  module Part
    class Icon < Base
      include Ownable

      attr_accessor :preprinted
      attr_reader :image, :name, :sticky, :large

      def initialize(image, name = nil, sticky = true, blocks_lay = nil, preprinted = true, large: false, owner: nil)
        @image = "/icons/#{image}.svg"
        @name = name || image.split('/')[-1]
        @sticky = !!sticky
        @preprinted = preprinted
        @blocks_lay = !!blocks_lay
        @large = !!large
        @owner = owner
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
