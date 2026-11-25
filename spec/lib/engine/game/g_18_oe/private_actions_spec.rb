# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE private pre-actions (§4.1, §6.1, §10)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:round) { stock_round!(game) }
  let(:step) { round.active_step }
  let(:player) { round.current_entity }
  let(:wcf) { give_company!(player, game.company_by_id('WCF')) }
  let(:rsc) { give_company!(player, game.company_by_id('RSC')) }

  def choose!(entity, choice, target)
    act!(round, Engine::Action::Choose.new(entity, choice: choice, target: target))
  end

  def flip!(company)
    choose!(player, 'flip_private', company)
  end

  it 'offers face down and remove before the stock action (§10)' do
    expect(step.entity_choices(wcf)).to eq(
      'remove_private' => 'Remove from game',
      'flip_private' => 'Flip face down',
    )
    expect(step.choice_available?(wcf)).to be(true)
    expect(step.actions(player)).to include('choose')
  end

  it 'exposes choices only for the active player\'s eligible private cards (§6.2, §6.3)' do
    other = give_company!(game.players[1], game.company_by_id('PeC'))
    minor = give_company!(player, game.company_by_id('A'))
    concession = give_company!(player, game.company_by_id('CON1'))

    expect([other, minor, concession].map { |company| step.entity_choices(company) }).to all(eq({}))
    expect([other, minor, concession].map { |company| step.choice_available?(company) }).to all(be(false))
  end

  it 'lists only the active player\'s eligible private cards as choice companies (§10, §6.2, §6.3)' do
    give_company!(game.players[1], game.company_by_id('PeC'))
    give_company!(player, game.company_by_id('A'))
    give_company!(player, game.company_by_id('CON1'))
    wcf

    expect(step.choice_companies(player)).to eq([wcf])
    expect(step.choice_companies(game.players[1])).to eq([])
  end

  it 'keeps a face-down private owned, open, and usable (§6.1)' do
    flip!(wcf)

    expect(wcf.owner).to eq(player)
    expect(wcf.closed?).to be(false)
    expect(game.company_status_str(wcf)).to eq('Face down')
    expect(wcf.abilities.map(&:type)).to include(:token)
  end

  it 'frees a certificate slot when a private is turned face down (§4.1, §6.1)' do
    wcf

    expect { flip!(wcf) }.to change { game.num_certs(player) }.by(-1)
  end

  it 'does not pay revenue for a face-down private (§6.1, §11)' do
    expect { flip!(wcf) }.to change(wcf, :revenue).from(15).to(0)
  end

  it 'does not score a face-down private (§6.1)' do
    wcf

    expect { flip!(wcf) }.to change { game.player_value(player) }.by(-wcf.value)
  end

  it 'allows one private action and then requires a stock action (§10)' do
    wcf
    rsc
    flip!(wcf)

    expect(step.entity_choices(rsc)).to eq({})
    expect do
      step.process_choose(Engine::Action::Choose.new(player, choice: 'flip_private', target: rsc))
    end.to raise_error(Engine::GameError)
    expect(round.current_actions).to be_empty
    expect(step.actions(player)).to include('pass')
  end

  it 'allows turning a private face down before forced stock sales (§4.1)' do
    allow(game).to receive(:major_phase?).and_return(true)
    major = start_major!(game, 'LNWR', player)
    take_treasury_shares!(game, player, major, 3)
    wcf
    allow(game).to receive(:cert_limit).and_return(game.num_certs(player) - 1)

    expect(step.actions(player)).to eq(%w[sell_shares choose])
    expect(step.entity_choices(wcf)).to include('flip_private')
  end

  it 'requires using a private when over the certificate limit with nothing to sell (§4.1)' do
    start_regional!(game, 'PLM', player)
    wcf
    allow(game).to receive(:cert_limit).and_return(game.num_certs(player) - 1)

    expect(step.actions(player)).to eq(%w[choose])
    expect(step.entity_choices(wcf)).to include('flip_private')
  end

  it 'does not offer a face-down private during forced certificate correction (§4.1)' do
    start_regional!(game, 'PLM', player)
    wcf
    rsc
    game.flip_private!(rsc)
    allow(game).to receive(:cert_limit).and_return(game.num_certs(player) - 1)

    expect(step.actions(player)).to eq(%w[choose])
    expect(step.entity_choices(wcf)).to include('flip_private')
    expect(step.entity_choices(rsc)).to eq({})
    expect do
      step.process_choose(Engine::Action::Choose.new(player, choice: 'remove_private', target: rsc))
    end.to raise_error(Engine::GameError)
  end

  context 'with corporation-target choices available' do
    let(:regional) { game.corporation_by_id('LNWR') }
    let(:minor) { game.corporation_by_id('K') }
    let(:remove_regional_action) { Engine::Action::Choose.new(player, choice: 'remove', target: regional) }
    let(:reserve_regional_action) { Engine::Action::Choose.new(player, choice: 'reserve', target: regional) }
    let(:merge_minor_action) { Engine::Action::Choose.new(player, choice: minor.id) }

    before do
      start_regional!(game, 'PLM', player)
      wcf
      allow(game).to receive(:removable_regional?).and_return(true)
      allow(game).to receive(:can_reserve_regional?).and_return(true)
      allow(game).to receive(:merge_targets).and_return([regional])
    end

    it 'rejects corporation choices while over the certificate limit (§4.1)' do
      allow(game).to receive(:cert_limit).and_return(game.num_certs(player) - 1)

      expect(step.entity_choices(regional)).to eq({})
      expect(step.choice_available?(regional)).to be(false)
      expect(step.entity_choices(wcf)).to include('flip_private')
      [remove_regional_action, reserve_regional_action, merge_minor_action].each do |action|
        expect { step.process_choose(action) }.to raise_error(Engine::GameError)
      end
      expect(round.current_actions).to be_empty
    end

    it 'keeps corporation choices when not over the certificate limit (§10)' do
      expect(step.entity_choices(regional)).to eq('remove' => 'Remove from game', 'reserve' => 'Reserve share')
      expect(step.can_merge?(player, minor)).to be(true)
    end
  end

  it 'offers private choices before the Major RR Phase (§10)' do
    expect(game.major_phase?).to be(false)
    expect(step.entity_choices(wcf)).to include('flip_private', 'remove_private')
  end

  it 'offers no private action after the stock action has started (§10)' do
    allow(game).to receive(:major_phase?).and_return(true)
    major = start_major!(game, 'LNWR', player)
    take_treasury_shares!(game, player, major, 1)
    wcf
    share = player.shares_of(major).reject(&:president).first

    act!(round, Engine::Action::SellShares.new(player, shares: [share], percent: share.percent))

    expect(step.entity_choices(wcf)).to eq({})
    expect(step.choice_companies(player)).to eq([])
    expect(step.actions(player)).not_to include('choose')
    expect do
      step.process_choose(Engine::Action::Choose.new(player, choice: 'flip_private', target: wcf))
    end.to raise_error(Engine::GameError)
  end

  it 'leaves the stock action and Pass untouched by a private pre-action (§10)' do
    wcf
    flip!(wcf)

    expect(round.current_actions).to be_empty
    expect(round.last_to_act).to be_nil

    act!(round, Engine::Action::Pass.new(player))

    expect(round.pass_order).to include(player)
    expect(player.passed?).to be(true)
  end

  it 'offers no action for a face-down private on a later turn (§6.1, §10)' do
    flip!(wcf)
    step.setup

    expect(step.entity_choices(wcf)).to eq({})
    expect(step.choice_available?(wcf)).to be(false)
    expect(step.choice_companies(player)).not_to include(wcf)
    expect do
      step.process_choose(Engine::Action::Choose.new(player, choice: 'remove_private', target: wcf))
    end.to raise_error(Engine::GameError)
  end

  it 'removes ownership and abilities when a private is removed (§10)' do
    wcf
    choose!(player, 'remove_private', wcf)

    expect(wcf.closed?).to be(true)
    expect(wcf.owner).to be_nil
    expect(player.companies).not_to include(wcf)
    expect(wcf.abilities).to be_empty
  end
end
