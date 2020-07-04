require './spec/spec_helper'
require 'view/game/autoroute'
require 'engine'

module View
  module Game
    describe '#calculate' do
      let(:game) { Engine::GAMES_BY_TITLE['1889'].new(%w[player1 player2]) }

      it 'No tiles and no trains' do
        expect(Autoroute.calculate(game, 'IR')).to eq([])
      end
    end
  end
end
