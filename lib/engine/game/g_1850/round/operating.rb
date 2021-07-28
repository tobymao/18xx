# frozen_string_literal: true

require_relative '../../../round/operating'
require_relative '../../../token'

module Engine
  module Game
    module G1850
      module Round
        class Operating < Engine::Round::Operating
          def active_entities
            return @connection_runs.keys unless @connection_runs.empty?

            super
          end
        end
      end
    end
  end
end
