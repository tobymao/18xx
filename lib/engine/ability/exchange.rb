# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Exchange < Base
      attr_reader :corporation

      def setup(corporation:)
        @corporation = corporation
      end
    end
  end
end
