# frozen_string_literal: true

require_relative '../../corporation'

module Engine
  module Game
    module G1832
      class Corporation < Engine::Corporation
        attr_accessor :coal_token
      end
    end
  end
end
