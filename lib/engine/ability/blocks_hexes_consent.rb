# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class BlocksHexesConsent < Base
      attr_reader :hexes

      def setup(hexes:, hidden: false)
        @hexes = hexes
        @hidden = hidden
      end

      def hidden?
        @hidden
      end
    end
  end
end
