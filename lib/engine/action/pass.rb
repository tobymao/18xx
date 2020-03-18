# frozen_string_literal: true

require 'engine/action/base'
require 'engine/corporation'
require 'engine/player'

module Engine
  module Action
    class Pass < Base
      def pass?
        true
      end
    end
  end
end
