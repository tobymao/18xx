# frozen_string_literal: true

require './spec/spec_helper'
require 'engine/game/g_1849'

module Engine
  describe Game::G1849 do
    describe 'corporation closure' do
      it 'should reset' do
        data = JSON.parse(File.read('spec/fixtures/1849/closure.json'))
        players = data['players'].map { |p| [p['id'] || p['name'], p['name']] }.to_h
        game = Game::G1849.new(players, id: 'hs_vvjzmfsd_16011119677', actions: data['actions'])
        expect(game.corporations.length).to eq(5)
        expect(game.corporations.last.id).to eq('IFT')
      end
    end
  end
end
