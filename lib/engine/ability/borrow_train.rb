# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class BorrowTrain < Base
      attr_reader :train_types

      def setup(train_types:)
        @train_types = train_types
      end
    end
  end
end
