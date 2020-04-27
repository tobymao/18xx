# frozen_string_literal: true

require './spec/spec_helper'

require 'engine/game/g_1889'
require 'engine/part/city'
require 'json'

module Engine
  describe Game::G1889 do
    let(:players) { [Player.new('a'), Player.new('b')] }
    subject { Game::G1889.new(players) }

    context 'on init' do
      it 'starts with correct cash' do
        expect(subject.bank.cash).to eq(6160)
        expect(subject.players.map(&:cash)).to eq([420, 420])
      end

      it 'starts with an auction' do
        expect(subject.round).to be_a(Round::Auction)
      end
    end

    context 'full game' do
      RESULTS = {
        104 => {
          'Gandhalf' => 7174,
          'hoffmansthal' => 6627,
          'sharunasbresson' => 7490,
        },
        233 => {
          'dionhut' => 7844,
          'hhlodesign' => 7655,
          'raj' => 8050,
        },
        239 => {
          'Cheesy Crackers' => 4900,
          'Notsem' => 5027,
        },
      }.freeze

      RESULTS.each do |game_id, result|
        it "#{game_id} matches result exactly" do
          data = JSON.parse(File.read("spec/fixtures/1889/#{game_id}.json"))
          expect(subject.class.new(data['players'], actions: data['actions']).result).to eq(result)
        end
      end
    end
  end
end
