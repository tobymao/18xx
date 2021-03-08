# frozen_string_literal: true

require_relative '../../company'

module Engine
  module Game
    module G2038
      class Company < Engine::Company
        attr_accessor :minor_id

        # TODO: After looking at this, it seems we may actually want a standard company here
        # TODO: with the abilities listed in the description and simply have some handling
        # TODO: to also open the minor

        def initialize(minor_hash)
          @minor_id = minor_hash[:sym]
          desc = 'May form a Growth Corporation OR join the Asteroid League for 1 share.'
          super(sym: @minor_id, name: minor_hash[:name], value: 100, desc: desc, color: 'white')
        end
      end
    end
  end
end
