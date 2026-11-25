# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE Extended Full Game opening (PB §5.6)' do
  include G18OESpecHelpers

  let(:game) { new_game(optional_rules: [:extended_full_game]) }
  let(:round) { stock_round!(game, turn: 1) }
  let(:step) { round_step(round, Engine::Game::G18OE::Step::BuySellParShares) }
  let(:regionals) { game.corporations.select { |corporation| corporation.type == :regional } }
  let(:minors) { game.corporations.select { |corporation| corporation.type == :minor } }
  let(:track_rights) { %w[UK UK FR FR AH AH SC SC SP SP IT RU] }
  let(:plm) { game.corporation_by_id('PLM') }

  def record_float!(corporation)
    corporation.ipoed = true
    corporation.floated = true
    game.minor_regional_order << corporation
  end

  it 'neither offers nor accepts the stock action to remove a regional' do
    expect(step.entity_choices(plm)).not_to have_key('remove')
    action = Engine::Action::Choose.new(round.current_entity, choice: 'remove', target: plm)

    expect { step.process_choose(action) }.to raise_error(Engine::GameError, /Cannot remove PLM/)
  end

  it 'retains all 24 regionals when the 18th floats' do
    (regionals - [plm]).first(17).each { |regional| record_float!(regional) }
    action = Engine::Action::Par.new(round.current_entity, corporation: plm, share_price: cell(game, 60, :par))
    step.process_par(action)

    expect(game.corporations.count { |corporation| corporation.type == :regional }).to eq(24)
    expect(game.removed_regionals).to be_empty
  end

  it 'waits for the last parred regional to float before entering the Major Railroad Phase' do
    (regionals - [plm]).each { |regional| record_float!(regional) }
    minors.each { |minor| record_float!(minor) }
    minors.zip(track_rights).each { |minor, zone| game.claim_region!(minor, zone) }
    game.par_corporation(plm, cell(game, 60, :par))
    plm.ipoed = true
    game.minor_regional_order << plm

    expect(game.major_phase?).to be(false)
    step.process_buy_shares(Engine::Action::BuyShares.new(round.current_entity, shares: plm.presidents_share))

    expect(game.major_phase?).to be(true)
    expect(game.operating_order.count(plm)).to eq(1)
  end

  it 'waits for the last minor to assign its track rights before entering the Major Railroad Phase' do
    (regionals + minors).each { |railroad| record_float!(railroad) }
    minors.take(11).zip(track_rights).each { |minor, zone| game.claim_region!(minor, zone) }

    expect(game.major_phase?).to be(false)
    game.claim_region!(minors.last, track_rights.last)
    expect(game.major_phase?).to be(true)
  end

  it 'operates all 36 railroads in the order of their markers' do
    order = regionals.first(12).zip(minors).flatten + regionals.drop(12)
    order.each { |railroad| record_float!(railroad) }

    expect(game.operating_order.size).to eq(36)
    expect(game.operating_order).to eq(order)
  end
end
