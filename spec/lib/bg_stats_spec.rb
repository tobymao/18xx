# frozen_string_literal: true

require 'spec_helper'
require 'lib/bg_stats'

describe Lib::BgStats do
  let(:meta) { Engine.meta_by_title('1889') }
  let(:finished_at) { Time.new(2026, 11, 24, 22, 30, 5) }
  let(:gdata) do
    {
      'id' => 123,
      'title' => '1889',
      'description' => 'Mtl trains',
      'finished_at' => finished_at.to_i,
      'players' => [{ 'id' => 1, 'name' => 'Alice' }, { 'id' => 2, 'name' => 'Bob' }, { 'id' => 3, 'name' => 'Cy' }],
      'result' => { '1' => 5000, '2' => 7000, '3' => 5000 },
    }
  end
  let(:play) { described_class.play(gdata, meta) }

  it 'describes the play in local time' do
    expect(play).to include(sourceName: '18xx.games', sourcePlayId: '123', playDate: '2026-11-24 22:30:05',
                            location: '18xx.games', comments: 'Mtl trains (18xx.games #123)')
  end

  it 'comments with just the game ID when the game has no description' do
    gdata['description'] = ''
    expect(play[:comments]).to eq('18xx.games #123')
  end

  it 'identifies the title' do
    expect(play[:game]).to eq(name: meta.display_title, sourceGameId: '1889', noPoints: false, highestWins: true)
  end

  it 'sends the BGG ID when the title has one' do
    stub_const("#{meta}::BGG_ID", 42)
    expect(play[:game][:bggId]).to eq(42)
  end

  it 'ranks players by score with shared ranks for ties' do
    expect(play[:players]).to eq([
      { name: 'Alice', sourcePlayerId: '1', score: 5000, rank: 2, winner: false, startPlayer: true },
      { name: 'Bob', sourcePlayerId: '2', score: 7000, rank: 1, winner: true, startPlayer: false },
      { name: 'Cy', sourcePlayerId: '3', score: 5000, rank: 2, winner: false, startPlayer: false },
    ])
  end

  it 'marks every tied leader as a winner' do
    gdata['result']['1'] = 7000
    expect(play[:players].map { |p| p[:winner] }).to eq([true, true, false])
  end
end
