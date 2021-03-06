# frozen_string_literal: true

require_relative '../../../step/route'
require_relative 'connection'

module Engine
  module Game
    module G1870
      module Step
        class ConnectionRoute < Engine::Step::Route
          include Connection

          def description
            'Run Connection Route'
          end
        end
      end
    end
  end
end
