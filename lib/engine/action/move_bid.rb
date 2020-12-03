# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class MoveBid < Base
      attr_reader :company, :corporation, :price, :old_company, :old_price

      def initialize(entity, price:, company: nil, corporation: nil, old_company:, old_price:)
        @entity = entity
        @company = company
        @corporation = corporation
        @price = price
        @old_company = old_company
        @old_price = old_price
      end

      def self.h_to_args(h, game)
        {
          company: game.company_by_id(h['company']),
          corporation: game.corporation_by_id(h['corporation']),
          old_company: game.company_by_id(h['old_company']),
          price: h['price'],
          old_price: h['old_price'],
        }
      end

      def args_to_h
        {
          'company' => @company&.id,
          'corporation' => @corporation&.id,
          'price' => @price,
          'old_company' => @old_company&.id,
          'old_price' => @old_price,
        }
      end
    end
  end
end
