# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module G1880
      module Step
        class HomeToken < Engine::Step::HomeToken
          def active_entities
            @round.pending_tokens&.map { |token| token[:entity] }
          end
        end
      end
    end
  end
end
