# frozen_string_literal: true

require_relative 'base'
require_relative '../operating_info'

module Engine
  module Step
    class PurchaseCompanies < Base
      def actions(_entity)
        []
      end

      def description
        'Purchase Companies'
      end

      def pass_description
        'Pass (Companies)'
      end
    end
  end
end
