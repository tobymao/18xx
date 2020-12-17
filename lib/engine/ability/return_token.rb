# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class ReturnToken < Base
      attr_reader :reimburse

      def setup(reimburse: false)
        @reimburse = reimburse
      end
    end
  end
end
