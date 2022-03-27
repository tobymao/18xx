# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Generic < Base
      def setup(subtype:)
        @type = subtype.to_sym
      end
    end
  end
end
