# frozen_string_literal: true

require_relative '../../company'

module Engine
  module Game
    module G2038
      class Company < Engine::Company

        attr_accessor :minor

        def initialize(minor)
          @minor = minor
          desc = 'Buy the Independant company of the same name'
          super(sym: @minor.name, name: @minor.full_name, value: 100, desc: desc, color: 'white')
        end
      end
    end
  end
end
