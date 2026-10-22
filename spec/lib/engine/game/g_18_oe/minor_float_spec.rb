# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE floating minors (§9.1)' do
  include G18OESpecHelpers

  let(:game) { finish_auction!(new_game) }

  def next_minor
    company = game.current_entity.companies.find { |c| game.company_becomes_minor?(c) }
    game.corporation_by_id(company.sym)
  end

  def float_next!(zone)
    float_minor!(game, next_minor.id, zone: zone)
  end

  def par_next!
    minor = next_minor
    price = game.round.active_step.get_par_prices(game.current_entity, minor).first
    act!(game, Engine::Action::Par.new(game.current_entity, corporation: minor, share_price: price))
    minor
  end

  def float_next_at!(hex_id)
    minor = par_next!
    act!(game, Engine::Action::PlaceToken.new(minor, city: game.hex_by_id(hex_id).tile.cities.first, slot: 0))
    minor
  end

  def candidates(minor = next_minor)
    game.home_token_locations(minor).map(&:id)
  end

  it 'does not let a player with an unfloated minor pass (§8.2)' do
    expect(game.round.active_step.actions(game.current_entity)).to eq(['par'])
  end

  it 'closes the minor company and gives its owner the whole charter' do
    player = game.current_entity
    minor = par_next!

    expect(game.company_by_id(minor.id)).to be_closed
    expect(player.percent_of(minor)).to eq(100)
    expect(minor).to be_floated
  end

  it 'has the minor place its home token next' do
    minor = par_next!

    expect(game.round.active_step).to be_a(Engine::Game::G18OE::Step::HomeToken)
    expect(game.current_entity).to eq(minor)
  end

  it 'charges the home token at the track rights chit cost (Table 1)' do
    costs = { 'UK' => 40, 'PHS' => 40, 'FR' => 20, 'AH' => 20, 'IT' => 10, 'SP' => 10, 'SC' => 10, 'RU' => 10 }
    paid = costs.keys.to_h { |zone| [zone, 120 - float_next!(zone).cash] }

    expect(paid).to eq(costs)
  end

  it 'claims a chit from the chosen zone' do
    minor = float_next!('FR')

    expect(game.minor_floated_regions[minor.id]).to eq('FR')
    expect(game.minor_available_regions['FR']).to eq(1)
  end

  it 'closes a zone once both of its chits are taken' do
    2.times { float_next!('IT') }

    expect(game.minor_available_regions).not_to have_key('IT')
    expect(game.home_token_locations(next_minor).map { |h| game.region_for_hex(h) }).not_to include('IT')
  end

  it 'removes the remaining UK, France and Prussia chits when the fourth is taken' do
    %w[UK UK FR].each { |zone| float_next!(zone) }

    expect(game.minor_available_regions.keys).to include('FR', 'PHS')

    float_next!('PHS')

    expect(game.minor_available_regions.keys & %w[UK FR PHS]).to eq([])
  end

  it 'refuses a home city in a closed zone' do
    italian = game.home_token_locations(next_minor).select { |h| game.region_for_hex(h) == 'IT' }
    2.times { float_next!('IT') }
    minor = par_next!
    game.process_action(Engine::Action::PlaceToken.new(minor, city: italian.last.tile.cities.first, slot: 0))

    expect(game.exception.message).to match(/Region IT is not available/)
  end

  it 'never offers a metropolis' do
    expect(candidates & %w[A56 B41 C74 F87 K26 M28 M50 Q30 R55 Y14 AA82 AB51]).to eq([])
  end

  it 'never offers a Balkan or Ottoman city' do
    expect(candidates & %w[S76 W64 W74 Y70 AA62 AB69 AD79 AE72 AA82]).to eq([])
  end

  it 'never offers the home city of a regional in play' do
    homes = game.corporations.select { |c| c.type == :regional }.map(&:coordinates)

    expect(candidates & homes).to eq([])
  end

  it 'never offers a city that already holds another minor' do
    float_next_at!('A64')

    expect(candidates).not_to include('A64')
  end

  it 'gives Nancy the France chit' do
    minor = float_next_at!('Q38')

    expect(game.minor_floated_regions[minor.id]).to eq('FR')
  end

  it 'gives Dresden the Prussia chit (§9.1 example)' do
    minor = float_next_at!('O52')

    expect(game.minor_floated_regions[minor.id]).to eq('PHS')
  end

  it 'adds the minor to the end of the operating order' do
    minor = float_next!('SP')

    expect(game.minor_regional_order.last).to eq(minor)
  end

  it 'leaves the £20 token on the charter (§6.2)' do
    minor = float_next!('SP')

    expect(minor.tokens.reject(&:used).map(&:price)).to eq([20])
  end
end
