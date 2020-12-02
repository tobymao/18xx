# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class TrainBuy < Base
      attr_reader :face_value
      def setup(face_value: nil)
        @face_value = !!face_value
      end
    end
  end
end
