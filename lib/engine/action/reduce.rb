# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class Reduce < Base
      attr_reader :company

      def initialize(entity, company: nil)
        @entity = entity
        @company = company
        raise GameError, 'Company cannot be nil' unless @company
      end

      def self.h_to_args(h, game)
        {
          company: game.company_by_id(h['company']),
        }
      end

      def args_to_h
        {
          'company' => @company&.id,
        }
      end
    end
  end
end
