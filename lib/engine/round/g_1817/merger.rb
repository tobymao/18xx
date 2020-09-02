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
            .select(&:floated?)
            .reject { |c| c.share_price.liquidation? || c.share_price.acquisition? }
            .sort
        end
      end
    end
  end
end
