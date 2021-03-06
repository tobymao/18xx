require_relative '../../minor'

module Engine
  module Game
    module G2038
      class Minor < Engine::Minor
        attr_accessor :value, :min_bid
        attr_reader :name, :full_name, :type

        def initialize(sym:, name:, value:, abilities: [], **opts)
          @value = value
          super(sym: sym, name: name, abilities: abilities, **opts)
        end

        def min_bid
          @value
        end
      end
    end
  end
end