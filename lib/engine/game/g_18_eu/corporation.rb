# frozen_string_literal: true

require_relative '../../corporation'

module Engine
  module Game
    module G18EU
      class Corporation < Engine::Corporation
        def holding_ok?(share_holder, extra_percent = 0)
          # Per the rules, it's OK to temporarily hold over the per-corp limit
          # if the company hasn't operated yet.
          return true unless self.operated?
          super
        end
      end
    end
  end
end
