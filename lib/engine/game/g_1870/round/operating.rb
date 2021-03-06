# frozen_string_literal: true

require_relative '../../../round/operating'
require_relative '../../../token'

module Engine
  module Game
    module G1870
      module Round
        class Operating < Engine::Round::Operating
          attr_accessor :river_special_tile_lay

          def start_operating
            super

            @river_special_tile_lay = nil
          end

          def active_entities
            return @connection_runs.keys unless @connection_runs.empty?

            super
          end
        end
      end
    end
  end
end
