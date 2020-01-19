# frozen_string_literal: true

require 'engine/action/base'

module Engine
  module Action
    class LayTile < Base
      attr_reader :entity, :hex, :tile

      def initialize(entity, tile, hex)
        @entity = entity
        @hex = hex
        @tile = tile
      end
    end
  end
end
