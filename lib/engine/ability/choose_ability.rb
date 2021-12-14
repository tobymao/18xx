# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class ChooseAbility < Base
      attr_reader :choices

      def setup(choices: nil)
        @choices = choices
      end
    end
  end
end
