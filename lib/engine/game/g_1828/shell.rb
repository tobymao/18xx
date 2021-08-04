# frozen_string_literal: true

module Engine
  module Game
    module G1828
      class Shell
        attr_reader :trains
        attr_accessor :name, :system

        def initialize(name, system)
          @name = name
          @system = system
          @trains = []
        end
      end
    end
  end
end
