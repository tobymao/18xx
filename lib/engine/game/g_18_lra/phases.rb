# frozen_string_literal: true

module Engine
  module Game
    module G18Lra
      module Phases
        def game_phases
          phases = super.dup
          phases.reject! { |p| p[:name] == '8' }
          phases.each { |p| p[:status] << 'harbour_unreserved' if p[:name] == '5' || p[:name] == '6' }
          phases
        end
      end
    end
  end
end
