# frozen_string_literal: true

require './spec/spec_helper'

require 'engine/game/g_18_chesapeake'
require 'json'

module Engine
  describe Game::G18Chesapeake do
    context 'full game' do
      RESULTS = {
        1157 => {
          'Anvil' => 7896,
          'Gamergeek65' => 6128,
        },
        1191 => {
          'Djeefther' => 430,
          'Philipe' => 1521,
          'amaro' => 3213,
          'lucasandradefisico' => 3465,
          'thiagoamorim84' => 2275,
        },
        1228 => {
          'Eric_Tama' => 4543,
          'creslin792' => 3718,
          'dromer' => 4072,
          'markcp' => 2469,
        },
      }.freeze

      RESULTS.each do |game_id, result|
        it "#{game_id} matches result exactly" do
          data = JSON.parse(File.read("spec/fixtures/18_chesapeake/#{game_id}.json"))
          players = data['players'].map { |p| p['name'] }
          expect(described_class.new(players, id: game_id, actions: data['actions']).result).to eq(result)
        end
      end
    end
  end
end
