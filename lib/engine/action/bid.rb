# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class Bid < Base
      attr_reader :company, :corporation, :price

      def initialize(entity, price:, company: nil, corporation: nil)
        super(entity)
        @company = company
        @corporation = corporation
        @price = price
      end

      def self.h_to_args(h, game)
        {
          company: game.company_by_id(h['company']),
          corporation: game.corporation_by_id(h['corporation']),
          price: h['price'],
        }
      end

      def args_to_h
        {
          'company' => @company&.id,
          'corporation' => @corporation&.id,
          'price' => @price,
        }
      end
    end
  end
end
