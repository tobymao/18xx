# frozen_string_literal: true

require_relative '../../company'

module Engine
  module Game
    module G22Mars
      class Company < Engine::Company
        attr_accessor :is_revolt, :used_revenue

        def initialize(sym:, name:, value:, desc:, abilities: [], **opts)
          super
          @is_revolt = opts[:is_revolt]
          @used_revenue = opts[:used_revenue]
        end

        def revolt?
          @is_revolt
        end
      end
    end
  end
end
