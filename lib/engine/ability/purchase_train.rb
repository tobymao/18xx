# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class PurchaseTrain < Base
      attr_reader :free

      def setup(free: false)
        @free = free
      end
    end
  end
end
