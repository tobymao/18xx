# frozen_string_literal: true

require_relative '../../corporation'

module Engine
  module Game
    module G1893
      class Corporation < Engine::Corporation
        def floated?
          @name == 'AdSK' || super
        end
      end
    end
  end
end
