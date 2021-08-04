# frozen_string_literal: true

require './spec/spec_helper'

require 'view/game/part/location_name'

module View
  module Game
    module Part
      describe LocationName do
        describe '#name_segments' do
          {
            'Charleroi & Connellsville' => ['Charleroi &', 'Connellsville'],
            'Chicago Connections' => %w[Chicago Connections],
            'Delmarva Peninsula' => %w[Delmarva Peninsula],
            'Dunkirk & Buffalo' => ['Dunkirk &', 'Buffalo'],
            'Harrisburg' => ['Harrisburg'],
            'New Haven & Hartford' => ['New Haven', '& Hartford'],
            'New York & Newark' => ['New York', '& Newark'],
            'New York' => ['New York'],
            'Philadelphia & Trenton' => ['Philadelphia', '& Trenton'],
            'Ritsurin Kouen' => %w[Ritsurin Kouen],
            'West Virginia Coal' => ['West Virginia', 'Coal'],
          }.each do |name, expected|
            it "returns #{expected} for input \"#{name}\"" do
              actual = described_class.name_segments(name)
              expect(actual).to eq(expected)
            end
          end
        end
      end
    end
  end
end
