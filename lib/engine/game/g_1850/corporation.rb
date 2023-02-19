# frozen_string_literal: true

require_relative '../../corporation'

module Engine
  module Game
    module G1850
      class Corporation < Engine::Corporation
        attr_accessor :mesabi_token
      end
    end
  end
end
