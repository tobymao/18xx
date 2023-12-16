# frozen_string_literal: true

require_relative '../../corporation'

module Engine
  module Game
    module G18EU
      class Corporation < Engine::Corporation
        def holding_ok?(share_holder, extra_percent = 0)
          return true unless self.operated?
          super
        end
      end
    end
  end
end
