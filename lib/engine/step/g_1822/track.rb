# frozen_string_literal: true

require_relative '../base'
require_relative 'tracker'

module Engine
  module Step
    module G1822
      class Track < Track
        include Tracker
      end
    end
  end
end
