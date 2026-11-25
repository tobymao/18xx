# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE port authorities (§11.3.5)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:president) { game.players[0] }
  let(:major) { start_major!(game, 'LNWR', president) }
  let(:round) do
    major
    game.instance_variable_set(:@turn, 2)
    enter_round!(game, game.operating_round(1)).tap do |r|
      r.entities.replace([major])
      r.instance_variable_set(:@entity_index, 0)
      r.start_operating
    end
  end
  let(:step) { round_step(round, Engine::Game::G18OE::Step::BuyPortAuthority) }

  def item_for(sea)
    step.buyable_items(major).find { |item| item.description == game.port_authority_name(sea) }
  end

  def buy_item!(entity, sea)
    act!(round, Engine::Action::SpecialBuy.new(entity, item: item_for(sea)))
  end

  before { fund!(game, major, 500) }

  it 'lets a major buy a port authority for £125' do
    round
    expect(step.buyable_items(major).map(&:description)).to eq(['North Sea port authority', 'Mediterranean port authority'])
    cash = major.cash
    bank = game.bank.cash

    buy_item!(major, :north_sea)

    expect(major.cash).to eq(cash - 125)
    expect(game.bank.cash).to eq(bank + 125)
    expect(game.port_authorities(major)).to eq([:north_sea])
    expect(game.log.map(&:message)).to include("#{major.name} buys a North Sea port authority for £125")
  end

  it 'applies the reduction to cross-water fees right after purchase without a manual graph clear (§11.1.6)' do
    round
    city = game.hex_by_id('M28').tile.cities.first
    city.place_token(major, major.next_token, free: true, check_tokenable: false)
    christiania = game.hex_by_id('C48').tile.cities.first
    expect(game.cross_water_token_fee(major, christiania)).to eq(120)

    buy_item!(major, :north_sea)

    expect(game.cross_water_token_fee(major, christiania)).to eq(40)
  end

  it 'offers no second port authority' do
    round
    buy_item!(major, :north_sea)
    other = Engine::Item.new(description: 'Mediterranean port authority', cost: 125)

    expect(step.buyable_items(major)).to be_empty
    expect { act!(round, Engine::Action::SpecialBuy.new(major, item: other)) }.to raise_error(Engine::GameError)
  end

  it 'stops offering a sea once its eight markers are sold' do
    round
    8.times do |i|
      holder = double("holder#{i}", type: :major, cash: 0)
      game.instance_variable_get(:@port_authorities)[holder] = [:north_sea]
    end

    expect(game.port_authorities_left(:north_sea)).to eq(0)
    expect(step.buyable_items(major).map(&:description)).to eq(['Mediterranean port authority'])
  end

  it 'offers nothing to a minor, a regional or a major short of £125' do
    round
    regional = start_regional!(game, 'KSS', president)
    minor_id = game.corporations.find { |c| c.type == :minor }.id
    minor = start_minor!(game, minor_id, president, game.minor_available_regions.keys.first)
    fund!(game, regional, 500)
    fund!(game, minor, 500)
    major.spend(major.cash - 124, game.bank)

    expect(step.buyable_items(regional)).to be_empty
    expect(step.buyable_items(minor)).to be_empty
    expect(step.buyable_items(major)).to be_empty
  end

  it 'offers the purchase in every step of the turn, Buy Trains included' do
    round
    %w[Track Route BuyTrain].each do |name|
      klass = Engine::Game::G18OE::Step.const_get(name)
      target = round_step(round, klass)
      allow(target).to receive(:active?).and_return(true)
      allow(target).to receive(:blocking?).and_return(true)
      round.steps.each { |s| allow(s).to receive(:blocking?).and_return(false) unless s == target }
      expect(round.actions_for(major)).to include('special_buy')
    end
  end

  it 'offers nothing to a major that is not the operating entity' do
    round
    other = start_major!(game, 'GWR', game.players[1])
    fund!(game, other, 500)

    expect(step.buyable_items(other)).to be_empty
    expect(round.actions_for(other)).not_to include('special_buy')
  end

  it 'does not raise when asked for the actions of a player' do
    round

    expect(step.buyable_items(president)).to be_empty
    expect { round.actions_for(president) }.not_to raise_error
  end

  it 'shows the marker on the charter' do
    round
    buy_item!(major, :north_sea)
    expect(game.status_array(major)).to include(['North Sea port authority'])

    game.place_orient_express_marker!(major)
    expect(game.status_array(major)).to include(['Orient Express marker'], ['North Sea port authority'])
  end

  it 'shows how many markers of the sea are left on the buy button' do
    round
    expect(step.buyable_items(major).map { |item| step.item_str(item) })
      .to eq(['Buy North Sea port authority (£125, 8 left)', 'Buy Mediterranean port authority (£125, 8 left)'])

    game.buy_port_authority!(start_major!(game, 'GWR', game.players[1]).tap { |gwr| fund!(game, gwr, 500) }, :north_sea)

    expect(step.item_str(item_for(:north_sea))).to eq('Buy North Sea port authority (£125, 7 left)')
  end

  it 'lists the markers left on the Info page' do
    expect(game.timeline).to eq(['Port authorities left: North Sea 8, Mediterranean 8'])

    game.buy_port_authority!(major, :mediterranean)

    expect(game.timeline).to eq(['Port authorities left: North Sea 8, Mediterranean 7'])
  end
end
