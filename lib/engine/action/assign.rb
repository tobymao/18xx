# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class Assign < Base
      attr_reader :target, :city

      REQUIRED_ARGS = %i[target].freeze

      def initialize(entity, target:, city: nil)
        super(entity)
        @target = target
        @city = city
      end

      def self.h_to_args(h, game)
        { target: game.get(h['target_type'], h['target']), city: h['city'] }
      end

      def args_to_h
        hash = {
          'target' => @target.id,
          'target_type' => type_s(@target),
        }
        hash['city'] = @city unless @city.nil?
        hash
      end
    end
  end
end
