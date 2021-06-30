# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G18VA
      module Round
        class Operating < Engine::Round::Operating
          attr_accessor :laid_token

          def setup
            @laid_token = {}
            super
          end
        end
      end
    end
  end
end
