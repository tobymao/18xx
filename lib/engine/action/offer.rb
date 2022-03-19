# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class Offer < Base
      attr_reader :corporation, :company, :price

      def initialize(entity, corporation: nil, company: nil, price: nil)
        super(entity)
        @corporation = corporation
        @company = company
        @price = price
      end

      def self.h_to_args(h, game)
        {
          corporation: game.corporation_by_id(h['corporation']),
          company: game.company_by_id(h['company']),
          price: h['price'],
        }
      end

      def args_to_h
        {
          'corporation' => @corporation&.id,
          'company' => @company&.id,
          'price' => @price,
        }
      end
    end
  end
end
