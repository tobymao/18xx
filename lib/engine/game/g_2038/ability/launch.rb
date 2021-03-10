# frozen_string_literal: true

require_relative '../../../ability/base'

module Engine
  module Ability
    class Launch < Base
      attr_reader :style, :corporation

      def setup(corporation:, style: :normal)
        @corporation = corporation
        @style = style
      end
    end
  end
end