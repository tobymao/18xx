# frozen_string_literal: true

require_relative 'base'
require_relative '../bond_bundle'

module Engine
  module Action
    class SellBonds < Base
      attr_reader :entity, :bundle

      def initialize(entity, bonds:)
        super(entity)
        @bundle = BondBundle.new(bonds)
      end

      def self.h_to_args(h, game)
        {
          bonds: h['bonds'].map { |id| game.bond_by_id(id) },
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
