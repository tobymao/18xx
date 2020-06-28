# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Exchange < Base
      attr_reader :corporation, :from

      def setup(corporation:, from:)
        @corporation = corporation
        @from = Array(from).map(&:to_sym)
      end
    end
  end
end
