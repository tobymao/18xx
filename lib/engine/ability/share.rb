# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Share < Base
      attr_accessor :share
      attr_reader :corporations

      def setup(share:, corporations: nil)
        @share = share
        @corporations = corporations
      end
    end
  end
end
