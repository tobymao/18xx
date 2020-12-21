# frozen_string_literal: true

require_relative '../operating'
require_relative '../../token'

module Engine
  module Round
    module G1870
      class Operating < Operating
        attr_accessor :river_special_tile_lay

        def start_operating
          super

          @river_special_tile_lay = nil
        end
      end
    end
  end
end
