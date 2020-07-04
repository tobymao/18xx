require './spec/spec_helper'
require 'view/game/autoroute'
require 'engine'

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
        game.corporation_by_id('IR').trains.push(game.train_by_id('2-1'))
        expect(Autoroute.calculate(game, 'IR')).to eq([])
      end
    end
  end
end
