# frozen_string_literal: true

require 'engine/action/base'

module Engine
  module Action
    class Dividend < Base
      attr_reader :entity, :type

      def initialize(entity, type)
        @entity = entity
        @type = type
      end

      def copy(game)
        self.class.new(game.corporation_by_name(@entity.name), @type)
      end
    end
  end
end
