# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class SelectMultipleCompanies < Base
      attr_reader :entity, :companies

      def initialize(entity, companies:)
        super(entity)
        @companies = companies
      end

      def self.h_to_args(h, game)
        {
          companies: h['companies'].map { |id| game.company_by_id(id) },
        }
      end

      def args_to_h
        {
          'companies' => @companies.map(&:id),
        }
      end
    end
  end
end
