# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G1866
      module Step
        class Token < Engine::Step::Token
          def log_skip(entity)
            return if @game.national_corporation?(entity)

            @log << "#{entity.name} skips place a token"
          end
        end
      end
    end
  end
end
