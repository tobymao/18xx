# frozen_string_literal: true

require 'spec_helper'

module Engine
  module Game
    module G18Africa
      describe Game do
        def new_game(num_players, id: 1)
          Engine::Game::G18Africa::Game.new((1..num_players).map { |i| "Player #{i}" }, id: id)
        end

        it 'plays with 2 to 5 players' do
          expect(Game::PLAYER_RANGE).to eq([2, 5])
        end

        {
          2 => { corporations: 7, cert_limit: 28, cash: 782 },
          3 => { corporations: 9, cert_limit: 24, cash: 694 },
          4 => { corporations: 9, cert_limit: 18, cash: 606 },
          5 => { corporations: 9, cert_limit: 15, cash: 518 },
        }.each do |num_players, expected|
          it "keeps #{expected[:corporations]} of the 17 Companies with #{num_players} players" do
            game = new_game(num_players)
            expect(game.corporations.size).to eq(expected[:corporations])
            expect(game.cert_limit).to eq(expected[:cert_limit])
            expect(game.players.map(&:cash).uniq).to eq([expected[:cash]])
          end
        end

        it 'does not reserve the starting spaces of removed Companies' do
          game = new_game(3)
          reserved = game.hexes.flat_map { |hex| hex.tile.cities.flat_map(&:reservations) }.compact
          expect(reserved).not_to be_empty
          removed = Game::CORPORATIONS.map { |c| c[:sym] } - game.corporations.map(&:id)
          expect(removed).not_to be_empty
          expect(reserved.map(&:id) & removed).to be_empty
        end

        it 'removes one 2 and one 3 train with two players' do
          counts = ->(game) { game.depot.trains.map(&:name).tally.slice('2', '3') }
          expect(counts.call(new_game(3))).to eq('2' => 6, '3' => 4)
          expect(counts.call(new_game(2))).to eq('2' => 5, '3' => 3)
        end

        it 'marks every Commodity and destination port with a sticky icon' do
          game = new_game(3)
          G18Africa::Map::CONCESSIONS.each do |id, data|
            names = ->(hex_id) { game.hex_by_id(hex_id).tile.icons.select(&:sticky).map(&:name) }
            expect(names.call(data[:commodity])).to include(id.downcase)
            data[:ports].each { |port| expect(names.call(port)).to include("#{id.downcase}-#{data[:bonus]}") }
          end
        end
      end
    end
  end
end
