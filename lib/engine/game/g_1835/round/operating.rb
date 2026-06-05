# frozen_string_literal: true

require_relative '../../../round/operating'
module Engine
  module Game
    module G1835
      module Round
        class Operating < Engine::Round::Operating
          def setup
            @game.conversion_choice_during_or = false
            super
          end

          def pending_tokens
            @pending_tokens ||= []
          end
        end
      end
    end
  end
end
