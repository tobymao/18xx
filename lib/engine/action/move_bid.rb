# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class MoveBid < Base
      attr_reader :company, :corporation, :price, :from_company, :from_price

      def initialize(entity, price:, company: nil, corporation: nil, from_company:, from_price:)
        @entity = entity
        @company = company
        @corporation = corporation
        @price = price
        @from_company = from_company
        @from_price = from_price
      end

      def self.h_to_args(h, game)
        {
          company: game.company_by_id(h['company']),
          corporation: game.corporation_by_id(h['corporation']),
          from_company: game.company_by_id(h['from_company']),
          price: h['price'],
          from_price: h['from_price'],
        }
      end

      def args_to_h
        {
          'company' => @company&.id,
          'corporation' => @corporation&.id,
          'price' => @price,
          'from_company' => @from_company&.id,
          'from_price' => @from_price,
        }
      end
    end
  end
end
