# frozen_string_literal: true

require_relative '../../company'
require_relative '../../operator'

module Engine
  module Game
    module G1858
      # Private companies in 1858 are a hybrid with elements of other games'
      # private companies (they pay income at the start of each operating
      # round) and also minor companies (they lay track). This class claims
      # to be both a company and a minor so that it can be handled by parts
      # of the core code that is expecting a normal company or minor to be
      # provided.
      class Company < Engine::Company
        include Operator

        attr_reader :home_hexes, :full_name, :type, :cash

        def initialize(sym:, name:, value:, revenue: 0, desc: '', abilities: [], **opts)
          super
          @home_hexes = opts[:home_hexes] || []

          opts[:tokens] = []
          init_operator(opts)

          @full_name = name
          @type = 'private'
          @floated = false
        end

        def minor?
          # H&G is the exception
          !@coordinates.empty?
        end

        def assignments
          {}
        end

        def floated?
          @floated
        end

        def float!
          @floated = true
        end

        def home_hex?(hex)
          @coordinates.include?(hex.coordinates)
        end
      end
    end
  end
end
