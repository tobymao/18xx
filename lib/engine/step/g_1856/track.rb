# frozen_string_literal: true

require_relative '../base'
require_relative '../track'
require_relative 'tracker'

module Engine
  module Step
    module G1856
      class Track < Track
        include Tracker
      end
    end
  end
end
