# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G1880
      module Step
        class Token < Engine::Step::Token
          def log_skip(entity)
            return if entity.minor?

            super
          end
        end
      end
    end
  end
end
