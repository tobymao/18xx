# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Close < Base
      attr_reader :corporation

      def setup(corporation: nil)
        @corporation = corporation
      end
    end
  end
end
