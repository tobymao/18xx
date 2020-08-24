# frozen_string_literal: true

require_relative '../operating'

module Engine
  module Round
    module G1817
      class Operating < Operating
        attr_accessor :last_player

        def after_process(action)
          # Keep track of last_player for Cash Crisis
          @last_player = action.entity.player
          super
        end
      end
    end
  end
end
