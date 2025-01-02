# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1837
      module Round
        class Operating < Engine::Round::Operating
          def setup
            super
            @entities.reject { |e| e.tokens.first&.used }.each { |e| @game.place_home_token(e) }
          end
        end
      end
    end
  end
end
