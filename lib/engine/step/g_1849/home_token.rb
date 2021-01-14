# frozen_string_literal: true

require_relative '../home_token'

module Engine
  module Step
    module G1849
      class HomeToken < HomeToken
        def active_entities
          [current_entity]
        end
      end
    end
  end
end
