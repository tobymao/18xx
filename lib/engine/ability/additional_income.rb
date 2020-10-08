# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class AdditionalIncome < Base
      attr_reader :marker, :amount

      def setup()
        @marker = marker
        @amount = amount
      end
    end
  end
end
