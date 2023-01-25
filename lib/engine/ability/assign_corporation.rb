# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class AssignCorporation < Base
      attr_reader :closed_when_used_up

      def setup(closed_when_used_up: nil)
        @closed_when_used_up = closed_when_used_up
      end
    end
  end
end
