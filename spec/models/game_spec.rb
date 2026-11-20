# frozen_string_literal: true

require 'sequel/core'

DB = Sequel.mock(columns: %i[id round turn acting status finished_at]) unless defined?(DB)

require 'sequel/model'
require_relative '../../models/game'

describe Game do
  describe '#update_state_from_engine' do
    let(:engine) { double('engine', round: double('round', name: 'Stock'), turn: 4, active_players_id: [2, 3, 99]) }
    let(:users) { [1, 2, 3].map { |id| double("user#{id}", id: id) } }
    let(:game) { described_class.new(round: 'Operating', turn: 1, acting: [1], status: 'finished', finished_at: Time.at(0)) }

    it 'sets round, turn and acting from the engine and returns the acting users' do
      expect(game.update_state_from_engine(engine, users)).to eq(users[1..])
      expect([game.round, game.turn, game.acting]).to eq(['Stock', 4, [2, 3]])
    end

    it 'does not touch status or finished_at' do
      game.update_state_from_engine(engine, users)

      expect([game.status, game.finished_at]).to eq(['finished', Time.at(0)])
    end
  end
end
