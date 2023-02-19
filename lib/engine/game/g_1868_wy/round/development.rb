# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1868WY
      module Round
        class Development < Engine::Round::Operating
          def self.short_name
            'DEV'
          end

          def name
            'Development Round'
          end

          def select_entities
            @game.developing_order
          end
        end
      end
    end
  end
end
