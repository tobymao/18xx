# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE regionals (§8.2, §9.2)' do
  include G18OESpecHelpers

  let(:game) { finish_auction!(new_game) }

  it 'offers only par values the player can pay twice' do
    player = game.current_entity
    player.spend(player.cash - 150, game.bank)
    prices = game.round.active_step.get_par_prices(player, game.corporation_by_id('LNWR'))

    expect(prices.map(&:price).sort).to eq([60, 65, 70, 75])
  end

  it 'funds the treasury with twice par less the home token cost' do
    lnwr = float_regional!(game, 'LNWR', par: 60)
    plm = float_regional!(game, 'PLM', par: 60)
    sfai = float_regional!(game, 'SFAI', par: 90)

    expect([lnwr.cash, plm.cash, sfai.cash]).to eq([80, 100, 170])
  end

  it 'places the home token and charges it once' do
    lnwr = float_regional!(game, 'LNWR')

    expect(lnwr.tokens.first.used).to be(true)
    expect(lnwr.cash).to eq(120 - 40)
  end

  it 'gives the president 50% and leaves both 25% shares in the treasury' do
    player = game.current_entity
    lnwr = float_regional!(game, 'LNWR')

    expect(player.percent_of(lnwr)).to eq(50)
    expect(lnwr.ipo_shares.map(&:percent)).to eq([25, 25])
  end

  it 'leaves the £20 token on the charter' do
    lnwr = float_regional!(game, 'LNWR')

    expect(lnwr.tokens.reject(&:used).map(&:price)).to eq([20])
  end

  it 'joins the operating order and the regional count' do
    lnwr = float_regional!(game, 'LNWR')

    expect(game.minor_regional_order.last).to eq(lnwr)
    expect(game.regional_corps_floated).to eq(1)
  end

  it 'keeps the 25% shares off sale before the Major RR Phase' do
    lnwr = float_regional!(game, 'LNWR')
    game.process_action(Engine::Action::BuyShares.new(game.current_entity, shares: lnwr.ipo_shares.first, percent: 25))

    expect(game.exception).not_to be_nil
  end

  it 'removes the six unfloated regionals when the 18th floats' do
    game = game_at_or1
    regionals = game.corporations.select { |c| c.type == :regional }

    expect(regionals.size).to eq(18)
    expect(regionals).to all(be_floated)
  end

  it 'starts the Major RR Phase only with 18 regionals and all 12 minors floated (§5.1.3)' do
    minors = game.corporations.select { |c| c.type == :minor }
    game.regional_corps_floated = 18
    game.minor_floated_regions = minors.first(11).to_h { |m| [m.id, 'RU'] }
    expect(game.major_phase?).to be(false)

    game.minor_floated_regions = minors.to_h { |m| [m.id, 'RU'] }
    expect(game.major_phase?).to be(true)

    game.regional_corps_floated = 17
    expect(game.major_phase?).to be(false)
  end

  it 'sells no level 3 trains while the Major RR Phase has not begun (§8.2)' do
    game = finish_or!(game_at_or1(regionals: 17))
    minor = game.minor_regional_order.first
    step = round_step(game, Engine::Game::G18OE::Step::BuyTrain)

    expect(game.major_phase?).to be(false)
    expect(step.buyable_trains(minor)).to eq([])
  end

  it 'never lets a player sell a regional share (§10.1)' do
    game = game_at_sr2
    player = game.current_entity
    regional = game.corporations.find { |c| c.type == :regional && c.president?(player) }

    expect(game.round.active_step.can_sell?(player, player.shares_of(regional).first.to_bundle)).to be(false)
  end

  it 'does not offer conversion before the Major RR Phase' do
    lnwr = float_regional!(game, 'LNWR')

    expect(game.round.active_step.actions(lnwr)).to eq([])
  end
end
