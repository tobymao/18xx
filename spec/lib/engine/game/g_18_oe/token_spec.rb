# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE place token (§11.2)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:step) { Engine::Game::G18OE::Step::Token.new(game, []) }

  def check(corporation, hex_id)
    hex = game.hex_by_id(hex_id)
    step.check_connected(corporation, hex.tile.cities.first, hex)
  end

  def corp(id)
    game.corporation_by_id(id)
  end

  it 'keeps a regional token inside its zone' do
    expect { check(corp('LNWR'), 'Q30') }.to raise_error(Engine::GameError, /outside .* track rights zone/)
    expect(step.available_hex(corp('LNWR'), game.hex_by_id('Q30'))).to be_nil
  end

  it 'lets only French rights token in Nancy (§11.2 example)' do
    expect { check(corp('KSS'), 'Q38') }.to raise_error(Engine::GameError, /outside .* track rights zone/)
    expect { check(corp('PLM'), 'Q38') }.to raise_error(Engine::GameError, /not connected/)
  end

  it 'counts Dresden as Prussian (§2.1)' do
    expect { check(corp('SB'), 'O52') }.to raise_error(Engine::GameError, /outside .* track rights zone/)
  end

  it 'lets a major token outside its home zone' do
    major = start_major!(game, 'LNWR', game.players.first)

    expect { check(major, 'Q30') }.to raise_error(Engine::GameError, /not connected/)
  end

  describe 'unfloated metropolis home (§11.1.9)' do
    let(:player) { game.players.first }
    let(:hex) { game.hex_by_id('R55') }
    let(:lnwr) { corp('LNWR') }

    def lay_metropolis!
      hex.lay(game.tiles.find { |t| t.name == 'OE4' })
    end

    def tokenable_cities
      hex.tile.cities.each_index.select { |i| hex.tile.cities[i].tokenable?(lnwr, free: true) }
    end

    it 'blocks every other railroad from tokening any city until the home railroad floats' do
      lay_metropolis!

      expect(hex.tile.cities.size).to eq(3)
      expect(tokenable_cities).to eq([])
    end

    it 'prompts the president to choose the home station when the railroad floats' do
      lay_metropolis!
      round = stock_round!(game)
      sb = start_regional!(game, 'SB', player)

      expect(round.active_step).to be_a(Engine::Step::HomeToken)
      expect(round.active_step.current_entity).to eq(sb)
      expect(tokenable_cities).to eq([])
    end

    it 'opens the remaining cities once the home station is chosen' do
      lay_metropolis!
      round = stock_round!(game)
      sb = start_regional!(game, 'SB', player)
      act!(round, Engine::Action::PlaceToken.new(sb, city: hex.tile.cities[1], slot: 0))

      expect(hex.tile.cities[1].tokened_by?(sb)).to be(true)
      expect(hex.tile.reservations).to be_empty
      expect(tokenable_cities).to eq([0, 2])
    end

    it 'unblocks the metropolis when the unfloated railroad closes' do
      lay_metropolis!
      game.close_corporation(corp('SB'))

      expect(hex.tile.reservations).to be_empty
      expect(tokenable_cities).to eq([0, 1, 2])
    end

    it 'still gives a railroad floated before the tile the preprinted home token' do
      sb = start_regional!(game, 'SB', player)

      expect(hex.tile.cities.first.tokened_by?(sb)).to be(true)
      expect(hex.tile.reservations).to be_empty
    end
  end
end
