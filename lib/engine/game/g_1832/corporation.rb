# frozen_string_literal: true

require_relative '../../corporation'

module Engine
  module Game
    module G1832
      class Corporation < Engine::Corporation
        attr_accessor :coal_token, :system_shells
        attr_reader :vice_president_certs

        def initialize(sym:, name:, **opts)
          super
          @system_shells = []
          @vice_president_certs = []
        end
      end
    end
  end
end
