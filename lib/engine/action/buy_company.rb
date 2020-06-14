# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class BuyCompany < Base
      attr_reader :entity, :company, :price

      def initialize(entity, company:, price:)
        @entity = entity
        @company = company
        @price = price
      end

      def self.h_to_args(h, game)
        {
          company: game.company_by_id(h['company']),
          price: h['price'],
        }
      end

      def args_to_h
        {
          'company' => @company.id,
          'price' => @price,
        }
      end
    end
  end
end
