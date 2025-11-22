# frozen_string_literal: true

require_relative '../../company'

module Engine
  module Game
    module G1824Cisleithania
      class Company < Engine::Company
        attr_accessor :stack

        def make_construction_company!
          @interval = nil
          @value = 120
        end
      end
    end
  end
end
