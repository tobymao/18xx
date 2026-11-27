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

  it 'keeps a major token inside its zone until the first merger (errata 13)' do
    major = start_major!(game, 'LNWR', game.players.first)

    expect { check(major, 'Q30') }.to raise_error(Engine::GameError, /outside .* track rights zone/)
    game.minor_merged
    expect { check(major, 'Q30') }.to raise_error(Engine::GameError, /not connected/)
  end

  describe 'station tokens from the charter' do
    let(:major) { start_major!(game, 'DSJ', game.players.first) }
    let(:round) { station_token_round!(game, major) }
    let(:token_step) { round.active_step }
    let(:christiania) { game.hex_by_id('C48').tile.cities.first }
    let(:bergen) { game.hex_by_id('B41').tile.cities.first }

    def place_token(city: christiania, **args)
      Engine::Action::PlaceToken.new(major, city: city, slot: 0, **args)
    end

    it 'lets a converted railroad place its £80 token before its less expensive tokens' do
      fund!(game, major, 70)
      expect(token_step.available_tokens(major).map(&:price)).to eq([20, 40, 60, 80])

      act!(round, place_token(token_index: 5, cost: 120))

      expect(christiania.tokens).to include(major.tokens[5])
      expect(major.tokens[1..4].map { |token| [token.price, token.used] })
        .to eq([[20, false], [40, false], [60, false], [60, false]])
      expect(major.cash).to eq(60)
    end

    it 'lets the railroad use a less expensive token in a later operating round' do
      fund!(game, major, 70)
      act!(round, place_token(token_index: 5, cost: 120))
      next_round = station_token_round!(game, major, round_num: 2)

      act!(next_round, place_token(city: bergen, token_index: 1, cost: 20 + game.cross_water_token_fee(major, bergen)))

      expect(bergen.tokens).to include(major.tokens[1])
    end

    it 'rejects the choice when the railroad cannot afford its price plus the water fee' do
      action = place_token(token_index: 5, cost: 120)
      expect { act!(round, action) }.to raise_error(Engine::GameError, /cannot afford.*£120/)

      expect(major.cash).to eq(110)
      expect(major.tokens[5]).to have_attributes(price: 80, used: false)
      expect(christiania.tokens).to all(be_nil)
    end

    it 'leaves the charter price intact when the token cannot be placed' do
      token_step
      christiania.place_token(corp('GSWR'), corp('GSWR').next_token, free: true)

      expect { token_step.process_place_token(place_token(token_index: 3, cost: 100)) }
        .to raise_error(Engine::GameError, /cannot place token/)

      expect(major.cash).to eq(110)
      expect(major.tokens[3]).to have_attributes(price: 60, used: false)
    end

    it 'rejects a second token in the same operating round' do
      act!(round, place_token)

      expect { act!(round, place_token(city: bergen)) }.to raise_error(Engine::GameError, /No step found/)
      expect(bergen.tokens).to all(be_nil)
    end

    it 'replays the exact token and recorded cost without computing the route across water' do
      round
      game.process_action(place_token(token_index: 3, cost: 100).to_h, validate_auto_actions: true).maybe_raise!
      recorded = game.raw_actions.last
      expect(recorded).to include('token_index' => 3, 'cost' => 100)

      replay = new_game
      operator = start_major!(replay, 'DSJ', replay.players.first)
      replay_step = station_token_round!(replay, operator).active_step
      loaded_action = Engine::Action::PlaceToken.from_h(recorded, replay)
      replay.instance_variable_set(:@loading, true)
      expect(replay).not_to receive(:cross_water_token_fee)

      replay_step.process_place_token(loaded_action)

      expect(loaded_action.city.tokens).to include(operator.tokens[3])
      expect(operator.tokens[1].used).to be(false)
      expect(operator.cash).to eq(10)
    end

    [nil, '100', 100.0].each do |cost|
      it "rejects a token cost of #{cost.inspect} when selecting a token by index" do
        expect { act!(round, place_token(token_index: 3, cost: cost)) }
          .to raise_error(Engine::GameError, /Include the station token cost/)
        expect(major.tokens[3]).to have_attributes(price: 60, used: false)
        expect(major.cash).to eq(110)
      end
    end

    it 'uses the first unused normal token for placements recorded without an index' do
      action = place_token
      expect(action.to_h).not_to have_key('token_index')

      act!(round, action)

      expect(christiania.tokens).to include(major.tokens[1])
      expect(major.cash).to eq(50)
    end

    [-1, 0, 8, 2.5, '2', false, 2**64].each do |index|
      it "rejects token index #{index.inspect} without placing a token" do
        expect { act!(round, place_token(token_index: index)) }.to raise_error(Engine::GameError, /station token/)

        expect(major.cash).to eq(110)
        expect(major.tokens.map(&:price)).to eq([10, 20, 40, 60, 60, 80, 80, 80])
        expect(christiania.tokens).to all(be_nil)
      end
    end

    it 'rejects an index for a non-station token' do
      major.tokens << Engine::Token.new(major, type: :pass_through)

      expect { act!(round, place_token(token_index: 8)) }.to raise_error(Engine::GameError, /station token/)
      expect(major.tokens.last.used).to be(false)
    end
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
