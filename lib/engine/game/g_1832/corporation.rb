# frozen_string_literal: true

require_relative '../../corporation'

module Engine
  module Game
    module G1832
      class Corporation < Engine::Corporation
        attr_accessor :coal_token, :is_system, :system_shells

        def system?
          is_system
        end
      end
    end
  end
end
