# frozen_string_literal: true

require_relative 'base'
require_relative '../bond_bundle'

module Engine
  module Action
    class BuyBonds < Base
      attr_reader :entity, :bundle

      def initialize(entity, bonds:)
        super(entity)
        @bundle = BondBundle.new(Array(bonds))
      end

      def self.h_to_args(h, game)
        {
          bonds: h['bonds'].map do |id|
            game.bond_by_id(id)
          end,
        }
      end

      def args_to_h
        {
          'bonds' => @bundle.bonds.map(&:id),
        }
      end
    end
  end
end
