# frozen_string_literal: true

require_relative 'base'
# require_relative '../g_1828/system'

module Engine
  module Action
    class BuyTrain < Base
      attr_reader :train, :price, :exchange, :variant, :shell, :slots, :extra_due, :warranties

      def initialize(entity, train:, price:, variant: nil, exchange: nil, shell: nil, slots: nil,
                     extra_due: nil, warranties: nil)
        super(entity)
        @train = train
        @price = price
        @variant = variant
        @exchange = exchange
        @shell = shell
        @slots = slots
        @extra_due = extra_due
        @warranties = warranties
      end

      def self.h_to_args(h, game)
        {
          train: game.train_by_id(h['train']),
          price: h['price'],
          variant: h['variant'],
          exchange: game.train_by_id(h['exchange']),
          shell: shell_by_name(h['shell'], game),
          slots: h['slots']&.map { |m| m.to_i },
          extra_due: h['extra_due'],
          warranties: h['warranties'],
        }
      end

      def args_to_h
        {
          'train' => @train.id,
          'price' => @price,
          'variant' => @variant,
          'exchange' => @exchange&.id,
          'shell' => @shell&.name,
          'slots' => @slots,
          'extra_due' => @extra_due ? true : nil,
          'warranties' => @warranties,
        }
      end

      def self.shell_by_name(name, game)
        return nil unless name

        game.corporations.select(&:system?).each do |system|
          if (shell = system.shells.find { |s| s.name == name })
            return shell
          end
        end

        nil
      end
    end
  end
end
