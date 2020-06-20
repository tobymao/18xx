# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Icon < Base
      attr_accessor :preprinted
      attr_reader :image, :name, :sticky

      def initialize(image, name = nil, sticky = true, preprinted = true)
        @image = "/icons/#{image}.svg"
        @name = name || image
        @sticky = sticky
        @preprinted = preprinted
      end

      def icon?
        true
      end
    end
  end
end
