# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE place token (§11.2)' do
  include G18OESpecHelpers

  let(:game) { game_at_or1 }
  let(:step) { round_step(game, Engine::Game::G18OE::Step::Token) }

  def corp(id)
    game.corporation_by_id(id)
  end

  def check(corp_id, hex_id)
    hex = game.hex_by_id(hex_id)
    step.check_connected(corp(corp_id), hex.tile.cities.first, hex)
  end

  it 'keeps a regional token inside its zone' do
    expect { check('LNWR', 'Q30') }.to raise_error(Engine::GameError, /outside .* track rights zone/)
    expect(step.available_hex(corp('LNWR'), game.hex_by_id('Q30'))).to be_nil
  end

  it 'lets only French rights token in Nancy (§11.2 example)' do
    expect { check('KSS', 'Q38') }.to raise_error(Engine::GameError, /outside .* track rights zone/)
    expect { check('PLM', 'Q38') }.to raise_error(Engine::GameError, /not connected/)
  end

  it 'counts Dresden as Prussian (§2.1)' do
    expect { check('SB', 'O52') }.to raise_error(Engine::GameError, /outside .* track rights zone/)
  end

  it 'lets a major token outside its home zone' do
    game = game_at_sr2
    major = convert!(game, game.corporations.find { |c| c.type == :regional && c.president?(game.current_entity) })
    finish_sr!(game)
    step = round_step(game, Engine::Game::G18OE::Step::Token)
    paris = game.hex_by_id('Q30')

    expect { step.check_connected(major, paris.tile.cities.first, paris) }.to raise_error(Engine::GameError, /not connected/)
  end
end
