# frozen_string_literal: true

require_relative '../merger'

module Engine
  module Round
    module G1817
      class Merger < Merger
        def name
          'Merger and Acquisition Round'
        end

        def select_entities
          @game
            .corporations
            .select { |c| c.floated? && c.share_price.normal_movement? }
            .sort
        end
      end
    end
  end
end
