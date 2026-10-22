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
end
