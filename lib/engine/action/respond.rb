# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class Respond < Base
      attr_reader :entity, :corporation, :company, :accept

      def initialize(entity, corporation:, company:, accept:)
        super(entity)
        @corporation = corporation
        @company = company
        @accept = accept
      end

      def self.h_to_args(h, game)
        {
          corporation: game.corporation_by_id(h['corporation']),
          company: game.company_by_id(h['company']),
          accept: h['accept'] == 'true',
        }
      end

      def args_to_h
        {
          'corporation' => @corporation.id,
          'company' => @company.id,
          'accept' => @accept ? 'true' : 'false',
        }
      end
    end
  end
end
