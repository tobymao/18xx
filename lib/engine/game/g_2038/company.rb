# frozen_string_literal: true

require_relative '../../company'

module Engine
  module Game
    module G2038
      class Company < Engine::Company

        attr_accessor :minor_id

        def initialize(minor_hash)
          @minor_id = minor_hash[:sym]
          desc = 'Buy the Independant company of the same name'
          super(sym: @minor_id, name: minor_hash[:name], value: 100, desc: desc, color: 'white')
        end
      end
    end
  end
end
