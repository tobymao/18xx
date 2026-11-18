# frozen_string_literal: true

require 'spec_helper'
require_relative '../g_18_oe/helpers'

describe 'G18OE UK-France port authorities (PB §6.1.5)' do
  include G18OESpecHelpers

  let(:optional_rules) { [] }
  let(:game) { new_game(%w[a b], klass: Engine::Game::G18OEUKFR::Game, optional_rules: optional_rules) }
  let(:major) { fund!(game, start_major!(game, 'LNWR', game.players.first), 500) }
  let(:round) do
    major
    enter_round!(game, game.operating_round(1)).tap(&:start_operating)
  end
  let(:step) { round_step(round, Engine::Game::G18OE::Step::BuyPortAuthority) }
  let(:north_sea) { Engine::Item.new(description: 'North Sea port authority', cost: 125) }
  let(:mediterranean) { Engine::Item.new(description: 'Mediterranean port authority', cost: 125) }

  def buy!(item)
    step.process_special_buy(Engine::Action::SpecialBuy.new(major, item: item))
  end

  it 'offers four North Sea and six Mediterranean markers' do
    expect(step.buyable_items(major).map { |item| step.item_str(item) })
      .to eq(['Buy North Sea port authority (£125, 4 left)', 'Buy Mediterranean port authority (£125, 6 left)'])
  end

  it 'suppresses the North Sea purchase once its four markers are sold' do
    %w[GWR GSWR PLM OU].each do |id|
      holder = game.corporation_by_id(id)
      game.instance_variable_get(:@port_authorities)[holder] = [:north_sea]
    end

    expect(step.buyable_items(major)).to eq([mediterranean])
  end

  it 'forbids a second marker of the same type while the other type is available' do
    buy!(north_sea)

    expect(step.buyable_items(major)).to eq([mediterranean])
    expect { buy!(north_sea) }.to raise_error(Engine::GameError, 'Cannot buy North Sea port authority')
  end

  shared_examples 'a major owning both port authorities' do
    it 'allows a major to buy one of each type for £125 each' do
      round
      cash = major.cash
      bank = game.bank.cash

      buy!(mediterranean)
      buy!(north_sea)

      expect(major.cash).to eq(cash - 250)
      expect(game.bank.cash).to eq(bank + 250)
      expect(game.status_array(major)).to contain_exactly(['North Sea port authority'], ['Mediterranean port authority'])
      expect(step.buyable_items(major)).to be_empty
    end
  end

  include_examples 'a major owning both port authorities'

  context 'with Long Endgame' do
    let(:optional_rules) { [:long_endgame] }

    include_examples 'a major owning both port authorities'
  end

  it 'adds two route reduction units per owned sea to the railroad pool' do
    buy!(north_sea)
    buy!(mediterranean)

    expect(game.sea_pool(major, game.phase)).to include(north_sea: 2, mediterranean: 2)
  end
end
