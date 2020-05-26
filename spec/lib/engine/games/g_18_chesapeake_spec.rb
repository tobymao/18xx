# frozen_string_literal: true

require './spec/spec_helper'

require 'engine/game/g_18_chesapeake'
require 'json'

module Engine
  describe Game::G18Chesapeake do
    context 'full game' do
      {
        1276 => {
          'ferralferrets' => 560,
          'malayet2' => 1756,
          'philcampeau' => 1528,
        },
        1277 => {
          'Harshit' => 1216,
          'jagdish' => 1045,
          'mfwesq' => 1153,
          'tgg' => 600,
          'wery' => 1028,
        },
      }.each do |game_id, result|
        it "#{game_id} matches result exactly" do
          data = JSON.parse(File.read("spec/fixtures/18_chesapeake/#{game_id}.json"))
          players = data['players'].map { |p| p['name'] }
          expect(described_class.new(players, id: game_id, actions: data['actions']).result).to eq(result)
        end
      end
    end
  end
end
