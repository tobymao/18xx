# frozen_string_literal: true

module Engine
  module G1828
    class Shell
      attr_accessor :name, :trains, :system

      def initialize(name, system)
        @name = name
        @system = system
        @trains = []
      end
    end
  end
end
