# frozen_string_literal: true

require './spec/spec_helper'

require 'engine/game/g_1846'
require 'json'

module Engine
  describe Game::G1846 do
    context 'full game' do
      {
        2428 => {
        },
      }.each do |game_id, _result|
        it "#{game_id} matches result exactly" do
          data = JSON.parse(File.read("spec/fixtures/1846/#{game_id}.json"))
          players = data['players'].map { |p| p['name'] }
          expect(described_class.new(players, id: game_id, actions: data['actions']).active_player_names).to eq(['KLT'])
        end
      end
    end
  end
end
