# frozen_string_literal: true

require './spec/spec_helper'

require 'engine/game/g_18_chesapeake'
require 'json'

module Engine
  describe Game::G18Chesapeake do
    context 'full game' do
      {
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
