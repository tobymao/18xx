# frozen_string_literal: true

require './spec/spec_helper'

require 'view/part/base'

module View
  module Part
    describe Base do
      subject { described_class.new(nil, region_use: {}) }

      describe '#combined_cost' do
        describe 'with a hash of regions mapped to weights' do
          it 'returns the weighted sum of the selected regions' do
            region_use = { 'center' => 1, 'edge0' => 0.25, 'edge1' => 0.33 }
            regions = { ['center'] => 2, ['edge0'] => 0.5 }

            actual = subject.combined_cost(regions, region_use)
            expected = 2.125 # ((1 * 2) + (0.25 * 0.5))

            expect(actual).to eq(expected)
          end
        end

        describe 'with a list of regions' do
          it 'returns the total use of the selected regions' do
            region_use = { 'center' => 1, 'edge0' => 0.25, 'edge1' => 0.33 }
            regions = %w[center edge0]

            actual = subject.combined_cost(regions, region_use)
            expected = 1.25

            expect(actual).to eq(expected)
          end
        end
      end
    end
  end
end
