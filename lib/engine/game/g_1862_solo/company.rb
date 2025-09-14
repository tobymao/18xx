# frozen_string_literal: true

require_relative '../../company'

module Engine
  module Game
    module G1862Solo
      class Company < Engine::Company
        attr_accessor :ipo_row_index
      end
    end
  end
end
