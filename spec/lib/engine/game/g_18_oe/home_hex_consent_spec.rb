# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE home hex yellow consent (§11.1.9)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:round) { enter_round!(game, game.stock_round) }
  let(:president) { game.players.first }
  let(:other_player) { game.players.last }
  let(:other_railroad) { start_regional!(game, 'PLM', other_player) }

  def consenters(entity, hex)
    Array(game.consenter_for_lay_tile(entity, hex, nil))
  end

  def set_cash!(entity, amount)
    entity.spend(entity.cash, game.bank) if entity.cash.positive?
    game.bank.spend(amount, entity) if amount.positive?
  end

  def float_minor!(id, hex_id)
    minor = game.corporation_by_id(id)
    give_company!(round.current_entity, game.company_by_id(id))
    fund!(game, minor, 120)
    price = round.active_step.get_par_prices(round.current_entity, minor).first
    act!(round, Engine::Action::Par.new(round.current_entity, corporation: minor, share_price: price))
    city = game.hex_by_id(hex_id).tile.cities.first
    act!(round, Engine::Action::PlaceToken.new(minor, city: city, slot: 0))
    minor
  end

  it "asks a floated minor's president before another player's railroad lays yellow on its white home hex" do
    float_minor!('G', 'Q38')

    expect(consenters(other_railroad, game.hex_by_id('Q38'))).to eq([president])
  end

  it "asks a floated regional's president before another player's railroad lays yellow on its white home hex" do
    start_regional!(game, 'GWR', president)

    expect(consenters(other_railroad, game.hex_by_id('L25'))).to eq([president])
  end

  it 'keeps asking the president after the regional converts to a major' do
    gwr = start_major!(game, 'GWR', president)

    expect(gwr.type).to eq(:major)
    expect(consenters(other_railroad, game.hex_by_id('L25'))).to eq([president])
  end

  it "asks nobody when the home hex's president lays on it with another of their railroads" do
    start_regional!(game, 'GWR', president)
    sibling = start_regional!(game, 'GSWR', president)

    expect(consenters(sibling, game.hex_by_id('L25'))).to be_empty
  end

  it 'asks nobody once the home hex already holds yellow track' do
    start_regional!(game, 'GWR', president)
    hex = game.hex_by_id('L25')
    hex.lay(game.tiles.find { |t| t.color == :yellow && t.cities.size == 1 })

    expect(consenters(other_railroad, hex)).to be_empty
  end

  it "gives an un-floated regional's home hex automatic permission" do
    other_railroad

    expect(consenters(other_railroad, game.hex_by_id('L25'))).to be_empty
  end

  it 'asks nobody about an abandoned minor home hex' do
    minor = float_minor!('G', 'Q38')
    game.abandon_minor!(minor)

    expect(consenters(other_railroad, game.hex_by_id('Q38'))).to be_empty
  end

  it 'asks nobody about the home hex of a railroad left without a president by first-round insolvency' do
    gwr = start_regional!(game, 'GWR', president)
    set_cash!(gwr, 80)
    set_cash!(president, 10)
    game.declare_first_round_insolvency!(gwr)

    expect(gwr.owner).to be_nil
    expect(game.hex_by_id('L25').tile.cities.first.tokens).to include(gwr.tokens.first)
    expect(consenters(other_railroad, game.hex_by_id('L25'))).to be_empty
  end

  it 'asks nobody about the old home hex of a minor merged into a major' do
    minor = float_minor!('G', 'Q38')
    major = start_major!(game, 'GWR', president)
    game.add_minor_charter!(minor, major)
    minor.tokens.select(&:used).each(&:remove!)
    game.close_corporation(minor)

    expect(consenters(other_railroad, game.hex_by_id('Q38'))).to be_empty
  end
end
