# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class TakeLoan < Base
      attr_reader :loan

      def initialize(entity, loan:)
        super(entity)
        @loan = loan
      end

      def self.h_to_args(h, game)
        { loan: game.loan_by_id(h['loan']) }
      end

      def args_to_h
        { 'loan' => @loan&.id }
      end
    end
  end
end
