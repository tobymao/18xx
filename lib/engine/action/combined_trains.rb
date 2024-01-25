# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class CombinedTrains < Base
      attr_reader :base, :additional_train, :additional_train_variant

      def initialize(entity, base:, additional_train:, additional_train_variant:)
        super(entity)
        @base = base
        @additional_train = additional_train
        @additional_train_variant = additional_train_variant
      end

      def self.h_to_args(h, game)
        {
          base: game.train_by_id(h['base']),
          additional_train_variant: h['additional_train_variant'],
          additional_train: game.train_by_id(h['additional_train']),
        }
      end

      def args_to_h
        {
          'base' => base&.id,
          'additional_train' => additional_train&.id,
          'additional_train_variant' => additional_train_variant,
        }
      end
    end
  end
end
