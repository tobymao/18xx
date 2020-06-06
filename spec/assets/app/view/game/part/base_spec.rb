# frozen_string_literal: true

require './spec/spec_helper'

require 'view/game/part/base'

module View
  module Game
    module Part
      describe Base do
        subject do
          described_class.new(nil,
                              tile: nil,
                              region_use: { 0 => 1,
                                            1 => 0.25,
                                            2 => 0.33 })
        end

        describe '#combined_cost' do
          describe 'with a hash of regions mapped to weights' do
            it 'returns the weighted sum of the selected regions' do
              region_weights = { [0] => 2, [1] => 0.5 }

              actual = subject.combined_cost(region_weights)
              expected = 2.125 # ((1 * 2) + (0.25 * 0.5))

              expect(actual).to eq(expected)
            end

            it 'counts the region every time it appears in the keys for '\
              'region_weights' do
              region_weights = { [0, 1] => 2, [1] => 0.5 }

              actual = subject.combined_cost(region_weights)
              expected = 2.625 # ((1 + 0.25) * 2) + (0.25 * 0.5))

              expect(actual).to eq(expected)
            end
          end
        end
      end
    end
  end
end
