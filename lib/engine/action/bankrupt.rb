# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class Bankrupt < Base
      def initialize(entity)
        @entity = entity
      end
    end
  end
end
