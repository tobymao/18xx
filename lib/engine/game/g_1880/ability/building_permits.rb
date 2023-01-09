# frozen_string_literal: true

require_relative '../../../ability/base'

module Engine
  module Game
    module G1880
      module Ability
        class BuildingPermits < Engine::Ability::Base
          attr_reader :permits

          def setup(permits:)
            @permits = permits
          end

          def description
            "Building Permits: #{permits}"
          end

          def add_permit(permit)
            @permits << permit
          end
        end
      end
    end
  end
end
