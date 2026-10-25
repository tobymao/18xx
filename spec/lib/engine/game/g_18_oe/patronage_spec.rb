# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE patronage tiles (§2.9, §3.1, §9.1, §11.1.8)' do
  include G18OESpecHelpers

  let(:game) { new_game }

  def patronage(game, hex_id)
    game.hex_by_id(hex_id).tile.patronage
  end

  def drawn(game)
    game.hexes.select { |hex| hex.tile.patronage }.to_h { |hex| [hex.id, Engine::Game::G18OE::Map::PATRONAGE_TILES[hex.id]] }
  end

  it 'draws 3 pink, 3 yellow, 3 white and 8 green tiles onto their cities (§3.1)' do
    tiles = drawn(game)

    expect(tiles.values.map { |t| t[:group] }.tally).to eq(pink: 3, yellow: 3, white: 3, green: 8)
    expect(tiles.all? { |hex_id, data| patronage(game, hex_id) == data[:payouts] }).to be(true)

    hex_id, data = tiles.first
    entry = "#{game.hex_by_id(hex_id).location_name} (#{hex_id}) #{data[:payouts].values.join('/')}"
    expect(game.log.map(&:message).find { |m| m.start_with?('Patronage tiles:') }).to include(entry)
  end

  it 'draws different tiles for different seeds' do
    draws = (1..5).map { |seed| drawn(Engine::Game::G18OE::Game.new(%w[a b c], seed: seed)).keys.sort }

    expect(draws.uniq.size).to be > 1
  end

  it 'draws 2 French yellow and 2 UK pink tiles in the UK-France scenario (PB 6.1.5)' do
    uk_fr = new_game(%w[a b], klass: Engine::Game::G18OEUKFR::Game)
    tiles = drawn(uk_fr)

    expect(tiles.values.map { |t| [t[:group], t[:zone]] }.tally).to eq([:yellow, 'F'] => 2, [:pink, 'U'] => 2)
  end

  it 'assigns the payouts to the tile on its city' do
    game.place_patronage_tile!('V27')

    expect(patronage(game, 'V27')).to eq(yellow: 20, green: 30, brown: 40, gray: 50)
    expect(patronage(game, 'U34')).to be_nil
  end

  def lay_setup(game, phase: '2')
    minor = start_minor!(game, 'A', game.players.first, 'FR')
    fund!(game, minor)
    game.hex_by_id('V27').tile.cities.first.place_token(minor, minor.next_token, free: true)
    game.place_patronage_tile!('V27')
    game.phase.next! until game.phase.name == phase
    game.minor_regional_order.delete(minor)
    game.minor_regional_order.unshift(minor)
    round = enter_round!(game, game.operating_round(1))
    [minor, round]
  end

  context 'when a RR lays track in a patronage hex (§11.1.8)' do
    it 'pays the yellow amount for a lay in phase 2 and removes the tile' do
      minor, round = lay_setup(game)

      expect { lay_first_legal!(game, round, 'V27') }.to change { minor.cash }.by(20).and change { game.bank.cash }.by(-20)

      expect(patronage(game, 'V27')).to be_nil
      expect(game.hex_by_id('V27').original_tile.patronage).to be_nil
      message = "A fulfills the Toulouse patronage tile and receives #{game.format_currency(20)}"
      expect(game.log.map(&:message)).to include(message)
    end

    { '3' => 30, '5' => 40, '7' => 50 }.each do |phase, amount|
      it "pays #{amount} for the highest track colour of phase #{phase}" do
        fresh = new_game
        minor, round = lay_setup(fresh, phase: phase)

        expect { lay_first_legal!(fresh, round, 'V27') }.to change { minor.cash }.by(amount)
      end
    end

    it 'pays only once per tile' do
      minor, round = lay_setup(game)
      lay_first_legal!(game, round, 'V27')

      expect { game.fulfill_patronage!(minor, game.hex_by_id('V27')) }.not_to(change { minor.cash })
    end

    it 'pays nothing for a hex without a patronage tile' do
      minor, = lay_setup(game)

      expect { game.fulfill_patronage!(minor, game.hex_by_id('U34')) }.not_to(change { minor.cash })
    end
  end

  context 'when a minor places its home token on a patronage city (designer ruling over §9.1)' do
    it 'removes the tile without paying anyone' do
      round = enter_round!(game, game.stock_round)
      player = round.current_entity
      minor = game.corporation_by_id('A')
      give_company!(player, game.company_by_id('A'))
      fund!(game, minor, 120)
      game.place_patronage_tile!('V27')
      price = round.active_step.get_par_prices(player, minor).first
      act!(round, Engine::Action::Par.new(player, corporation: minor, share_price: price))
      city = game.hex_by_id('V27').tile.cities.first

      expect { act!(round, Engine::Action::PlaceToken.new(minor, city: city, slot: 0)) }.to change { minor.cash }.by(-20)

      expect(patronage(game, 'V27')).to be_nil
      expect(game.log.map(&:message)).to include('The Toulouse patronage tile is removed')
      expect { game.fulfill_patronage!(minor, game.hex_by_id('V27')) }.not_to(change { minor.cash })
    end
  end
end
