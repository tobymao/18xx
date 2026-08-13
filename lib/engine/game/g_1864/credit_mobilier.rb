# frozen_string_literal: true

require_relative '../../entity'
require_relative '../../spender'

module Engine
  module Game
    module G1864
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
