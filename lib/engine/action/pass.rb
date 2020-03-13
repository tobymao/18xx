# frozen_string_literal: true

require 'engine/action/base'
require 'engine/corporation'
require 'engine/player'

module Engine
  module Action
    class Pass < Base
      attr_reader :entity

      def initialize(entity)
        @entity = entity
      end

      def pass?
        true
      end

      def copy(game)
        case @entity
        when Corporation
          self.class.new(game.corporation_by_name(@company.name))
        when Player
          self.class.new(game.player_by_name(@company.name))
        else
          raise "Undefined entity type #{@entity}"
        end
      end
    end
  end
end
