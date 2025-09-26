# frozen_string_literal: true

module Engine
  module Game
    module G1824Cisleithania
      module Trains
        # Rule X.1
        TRAIN_COUNT_2P_CISLETHANIA = {
          '2' => 6,
          '3' => 5,
          '4' => 4,
          '5' => 2,
          '6' => 2,
          '8' => 1,
          '10' => 20,
          '1g' => 3,
          '2g' => 2,
          '3g' => 2,
          '4g' => 1,
          '5g' => 2,
        }.freeze

        # Rule XI.1
        TRAIN_COUNT_3P_CISLETHANIA = {
          '2' => 8,
          '3' => 6,
          '4' => 4,
          '5' => 3,
          '6' => 3,
          '8' => 2,
          '10' => 20,
          '1g' => 5,
          '2g' => 4,
          '3g' => 3,
          '4g' => 2,
          '5g' => 2,
        }.freeze
      end
    end
  end
end
