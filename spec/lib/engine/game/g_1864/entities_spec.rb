# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1864::Entities do
  let(:game) { Engine::Game::G1864::Game.new(%w[alice bob carol], seed: 1) }

  it 'has 16 minors with western railroad symbols' do
    syms = described_class::CORPORATIONS.select { |c| c[:type] == 'minor' }.map { |c| c[:sym] }
    expect(syms.sort).to eq(%w[BW&GF CO&G CP CS DRG FE&MV KP NM&SP O&C OSL RF&CC RGW SCR SFP&P SLS&E UCR].sort)
  end

  it 'has 8 majors, none with a fixed home' do
    majors = described_class::CORPORATIONS.select { |c| c[:type] == 'major' }
    expect(majors.size).to eq(8)
    expect(majors.map { |c| c[:coordinates] }.compact).to eq([])
  end

  it 'gives the UP ten 10% shares capped at 60% ownership' do
    up = described_class::CORPORATIONS.find { |c| c[:type] == 'national' }

    expect(up[:sym]).to eq('UP')
    expect(up[:shares]).to eq([10, 10, 10, 10, 10, 10, 10, 10, 10, 10])
    expect(up[:max_ownership_percent]).to eq(60)
    expect(up[:hide_shares]).to be_nil
  end

  it 'starts the UP on the market at 80' do
    expect(game.union_pacific.share_price.price).to eq(80)
    expect(game.union_pacific.ipoed).to be(true)
  end

  it 'places a home city for every minor' do
    minors = (game.corporations + game.future_corporations).select { |c| c.type == :minor }

    expect(minors.size).to eq(16)
    minors.each do |minor|
      hex = game.hex_by_id(minor.coordinates)
      expect(hex).not_to be_nil, "#{minor.id} has no hex at #{minor.coordinates}"
      expect(hex.tile.cities).not_to be_empty, "#{minor.id} home #{minor.coordinates} has no city"
    end
  end
end
