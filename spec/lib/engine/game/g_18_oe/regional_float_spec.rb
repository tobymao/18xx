# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE regionals (§8.2, §9.2)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:round) { enter_round!(game, game.stock_round) }
  let(:step) { round.active_step }

  def par!(id, par = 60)
    regional = game.corporation_by_id(id)
    act!(round, Engine::Action::Par.new(round.current_entity, corporation: regional, share_price: cell(game, par, :par)))
    regional
  end

  it 'offers only par values the player can pay twice' do
    player = round.current_entity
    player.spend(player.cash - 150, game.bank)

    expect(step.get_par_prices(player, game.corporation_by_id('LNWR')).map(&:price).sort).to eq([60, 65, 70, 75])
  end

  it 'funds the treasury with twice par less the home token cost' do
    expect([par!('LNWR').cash, par!('PLM').cash, par!('SFAI', 90).cash]).to eq([80, 100, 170])
  end

  it 'places the home token and charges it once' do
    lnwr = par!('LNWR')

    expect(lnwr.tokens.first.used).to be(true)
    expect(lnwr.cash).to eq(120 - 40)
  end

  it 'gives the president 50% and leaves both 25% shares in the treasury' do
    player = round.current_entity
    lnwr = par!('LNWR')

    expect(player.percent_of(lnwr)).to eq(50)
    expect(lnwr.ipo_shares.map(&:percent)).to eq([25, 25])
  end

  it 'leaves the £20 token on the charter' do
    expect(par!('LNWR').tokens.reject(&:used).map(&:price)).to eq([20])
  end

  it 'joins the operating order and the regional count' do
    lnwr = par!('LNWR')

    expect(game.minor_regional_order.last).to eq(lnwr)
    expect(game.regional_corps_floated).to eq(1)
  end

  it 'keeps the 25% shares off sale before the Major RR Phase' do
    par!('LNWR')
    buyer = fund!(game, round.current_entity)

    expect(step.actions(buyer)).not_to include('buy_shares')
  end

  it 'puts the 25% shares on sale once the Major RR Phase begins' do
    par!('LNWR')
    buyer = fund!(game, round.current_entity)
    allow(game).to receive(:major_phase?).and_return(true)

    expect(step.actions(buyer)).to include('buy_shares')
  end

  it 'removes every unfloated regional when the 18th floats' do
    game.regional_corps_floated = 17
    lnwr = par!('LNWR')

    expect(game.corporations.select { |c| c.type == :regional }).to eq([lnwr])
  end

  it 'runs the regional closing once (§8.2)' do
    game.regional_corps_floated = 17
    par!('LNWR')
    fresh = round_step(enter_round!(game, game.stock_round), Engine::Game::G18OE::Step::BuySellParShares)

    expect { fresh.close_unfloated_regionals_at_maximum! }.not_to(change { game.corporations.size })
    expect(fresh.passed?).to be_falsey
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

  it 'never lets a player sell a regional share (§10.1)' do
    player = round.current_entity
    lnwr = start_regional!(game, 'LNWR', player)

    expect(step.can_sell?(player, player.shares_of(lnwr).first.to_bundle)).to be(false)
  end

  it 'does not offer conversion before the Major RR Phase' do
    president = round.current_entity
    lnwr = start_regional!(game, 'LNWR', president)

    expect(step.can_convert?(lnwr, president)).to be(false)
  end

  it 'offers conversion once the Major RR Phase begins' do
    president = round.current_entity
    lnwr = start_regional!(game, 'LNWR', president)
    allow(game).to receive(:major_phase?).and_return(true)

    expect(step.can_convert?(lnwr, president)).to be(true)
  end
end
