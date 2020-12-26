# frozen_string_literal: true

require 'find'

require 'engine'
require 'spec_helper'

FIXTURES_DIR = File.join(File.dirname(__FILE__), 'fixtures')

def game_at_action(game_data, action_id)
  players = game_data['players'].map { |p| [p['id'] || p['name'], p['name']] }.to_h
  Engine::GAMES_BY_TITLE[game_data['title']].new(
    players,
    id: game_data['id'],
    actions: game_data['actions'].take(action_id == :end ? game_data['actions'].size : action_id),
    optional_rules: game_data['optional_rules'],
  )
end

module Engine
  describe 'Fixture Game State' do
    let(:game_data) do
      JSON.parse(File.read(Find.find(FIXTURES_DIR).find { |f| File.basename(f) == "#{described_class}.json" }))
    end

    describe '1846' do
      describe 11_181 do
        it 'is in the Stock Round' do
          game = game_at_action(game_data, 51)

          expect(game.round).to be_a(Round::Stock)
        end

        it 'is in the Operating Round' do
          game = game_at_action(game_data, 52)

          expect(game.round).to be_a(Round::Operating)
        end
      end
    end
  end
end
