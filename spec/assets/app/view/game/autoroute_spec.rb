require './spec/spec_helper'
require 'view/game/autoroute'
require 'engine'
require 'engine/route'

module View
  module Game
    describe '#calculate' do
      let(:game) { Engine::GAMES_BY_TITLE['1889'].new(%w[player1 player2]) }
      before :each do
        game.corporations.each do |corp|
          corp.trains.clear
        end
      end

      it 'No tiles and no trains' do
        expect(Autoroute.calculate(game, 'IR')).to eq([])
      end

      it '1 train and no tiles' do
        game.corporation_by_id('IR').trains << game.train_by_id('2-1')
        expect(Autoroute.calculate(game, 'IR')).to eq([])
      end
      
      it '1 train and tile 46 at E2' do
        train = game.train_by_id('2-1');
        game.corporation_by_id('IR').trains << train
        game.hex_by_id('E2').lay(game.tile_by_id('5-0').rotate!(4))

        expected = Engine::Route.new(
          game, game.phase, game.train_by_id(train), connection_hexes: [game.hex_by_id('E2').connections[0]]
        )

        expect(Autoroute.calculate(game, 'IR')).to eq([expected])
      end
    end
  end
end
