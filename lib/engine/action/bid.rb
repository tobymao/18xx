# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class Bid < Base
      attr_reader :company, :corporation, :minor, :price

      def initialize(entity, price:, company: nil, corporation: nil, minor: nil)
        super(entity)
        @company = company
        @corporation = corporation
        @minor = minor
        @price = price
      end

      def self.h_to_args(h, game)
        {
          company: game.company_by_id(h['company']),
          corporation: game.corporation_by_id(h['corporation']),
          minor: game.minor_by_id(h['minor']),
          price: h['price'],
        }
      end

      def args_to_h
        {
          'company' => @company&.id,
          'corporation' => @corporation&.id,
          'minor' => @minor&.id,
          'price' => @price,
        }
      end
    end
  end
end
