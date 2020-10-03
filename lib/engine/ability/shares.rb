# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Shares < Base
      attr_accessor :shares
      attr_reader :corporations

      def setup(shares:, corporations: nil)
        @shares = Array(shares)
        @corporations = corporations
      end
    end
  end
end
