# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class AcquireCompany < Base
      attr_reader :company

      def setup(company:)
        @company = company
      end
    end
  end
end
