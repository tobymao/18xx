# frozen_string_literal: true

require './spec/spec_helper'

require 'engine/game/g_18_chesapeake'
require 'json'

module Engine
  describe Game::G18Chesapeake do
    context 'full game' do
      {
        1277 => {
          'Harshit' => 1216,
          'jagdish' => 1045,
          'mfwesq' => 1153,
          'tgg' => 600,
          'wery' => 1028,
        },
        1689 => {
          'Eonthar' => 6357,
          'Jasonbartfast' => 8651,
          'philcampeau' => 7945,
          'ynottony105' => 7041,
        },
        1905 => {
          'Apreche' => 4604,
          'GeekNightsRym' => 4210,
          'agrajag' => 6214,
          'pence' => 4848,
        },
      }.each do |game_id, result|
        it "#{game_id} matches result exactly" do
          data = JSON.parse(File.read("spec/fixtures/18_chesapeake/#{game_id}.json"))
          players = data['players'].map { |p| p['name'] }
          expect(described_class.new(players, id: game_id, actions: data['actions']).result).to eq(result)
          expect(described_class.new(players, id: game_id, actions: data['actions'], strict: true).result).to eq(result)
        end
      end
    end
  end
end
