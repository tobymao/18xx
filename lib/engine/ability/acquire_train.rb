# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class AquireTrain < Base
      attr_reader :train

      def setup()
        @train = train
      end
    end
  end
end
