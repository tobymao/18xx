# frozen_string_literal: true

require_relative '../../company'

module Engine
  module Game
    module G2038
      class CompanyWrapper < Engine::Company

        attr_accessor :minor

        def initialize(minor)
          @minor = minor
          super(sym: @minor.name, name: @minor.full_name, value: 100, desc: 'Buy the Independant company of the same name')
        end
      end
    end
  end
end
