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
      GAMES = {
        83 => {
          'EisVrouw81' => 9653,
          'RJ_E' => 8172,
          'Vorrt' => 8564,
        },
        90 => {
          'Jon_G' => 3580,
          'Spaul' => 335,
          'bentmeeple' => 3705,
        },
        104 => {
          'Gandhalf' => 6786,
          'hoffmansthal' => 6469,
          'sharunasbresson' => 7246,
        },
        105 => {
          'Batto' => 7294,
          'XB' => 8536,
          'akramer16' => 8359,
        },
      }.freeze

      GAMES.each do |game_id, results|
        it "#{game_id} matches results exactly" do
          data = JSON.parse(File.read("spec/fixtures/1889/#{game_id}.json"))
          expect(subject.class.new(data['players'], actions: data['actions']).results).to eq(results)
        end
      end
    end
  end
end
