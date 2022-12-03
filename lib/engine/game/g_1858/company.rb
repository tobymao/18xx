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

        attr_reader :home_hexes, :full_name, :type, :cash, :reservation_color

        def initialize(sym:, name:, value:, revenue: 0, desc: '', abilities: [], **opts)
          super
          @home_hexes = opts[:home_hexes] || []

          opts[:tokens] = []
          init_operator(opts)

          @full_name = name
          @type = 'private'
          @floated = false
        end

        def company?
          # This should inherit from Engine::Company but for unknown reasons
          # this isn't happening when the game is run in hotseat mode (it does
          # work as expected in server mode). So we explicitly set this property
          # to get rid of any differences in behaviour.
          true
        end

        def minor?
          true
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

        # Returns the par price for a public company started using this private
        # railway. Throws an error if called on a private that cannot be used
        # to start a public company.
        def par_price(stock_market)
          unless abilities.any? { |ability| ability.type == :reservation }
            raise GameError, "#{@sym} cannot start a public company as it does not have a home city"
          end

          stock_market.par_prices.max_by { |share_price| share_price.price <= @value ? share_price.price : 0 }
        end

        # Closes the company's stubs abilities.
        def release_stubs
          abilities.each { |ability| remove_ability(ability) if ability.type == :stubs }
        end
      end
    end
  end
end
