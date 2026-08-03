# frozen_string_literal: true

require_relative '../../entity'
require_relative '../../spender'

module Engine
  module Game
    module G1864
      # A cash pot that collects tile and terrain costs and pays them out to
      # the players before each Merger Round. Closes at the start of phase 4.
      class CreditMobilier
        include Entity
        include Spender

        attr_reader :closed

        def initialize
          @cash = 0
          @closed = false
        end

        def name
          'Crédit Mobilier'
        end

        def id
          'CM'
        end

        def closed?
          @closed
        end

        def close!
          @closed = true
        end
      end
    end
  end
end
