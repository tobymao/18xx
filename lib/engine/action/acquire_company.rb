# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class AcquireCompany < Base
      attr_reader :entity, :company

      def initialize(entity, company:)
        super(entity)
        @company = company
      end

      def self.h_to_args(h, game)
        {
          company: game.company_by_id(h['company']),
        }
      end

      def args_to_h
        {
          'company' => @company.id,
        }
      end
    end
  end
end
