require './spec/spec_helper'
require 'view/game/autoroute'

module View
  module Game
    describe '#calculate' do
      it 'vacuous' do
        expect(Autoroute.calculate(nil, nil)).to eq('calculated')
      end
    end
  end
end
