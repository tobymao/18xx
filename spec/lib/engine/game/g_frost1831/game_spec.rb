# frozen_string_literal: true

require 'spec_helper'

module Engine
  module Game
    module GFrost1831
      describe Game do
        def new_game(num_players, id: 1)
          Engine::Game::GFrost1831::Game.new((1..num_players).map { |i| "Player #{i}" }, id: id)
        end

        it 'has the expected title and aliases' do
          expect(Meta::GAME_TITLE).to eq('Frost 1831')
          expect(Meta::GAME_ALIASES).to eq(['1831'])
        end

        it 'plays with 2 to 5 players' do
          expect(Meta::PLAYER_RANGE).to eq([2, 5])
        end

        {
          2 => { cert_limit: 31, cash: 1200 },
          3 => { cert_limit: 25, cash: 800 },
          4 => { cert_limit: 22, cash: 600 },
          5 => { cert_limit: 19, cash: 480 },
        }.each do |num_players, expected|
          it "initializes with #{num_players} players without error" do
            game = new_game(num_players)
            expect(game.cert_limit).to eq(expected[:cert_limit])
            expect(game.players.map(&:cash).uniq).to eq([expected[:cash]])
          end
        end

        it 'loads the eight corporations' do
          game = new_game(3)
          expect(game.corporations.map(&:id).sort).to eq(%w[CM DL EC GJ HF OE SP TV])
        end
      end
    end
  end
end
