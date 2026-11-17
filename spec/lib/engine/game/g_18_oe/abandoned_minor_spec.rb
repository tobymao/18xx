# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE abandoning a minor (§9.5)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:player) { game.players.first }
  let(:minor) { start_minor!(game, 'D', player, 'UK') }
  let(:city) { game.hex_by_id('Q38').tile.cities.first }
  let(:train) { game.depot.upcoming.first }

  before do
    city.place_token(minor, minor.next_token, free: true, check_tokenable: false)
    game.buy_train(minor, train, :free)
  end

  describe 'abandoning a minor (§9.5)' do
    it 'keeps the minor open, with no owner' do
      game.abandon_minor!(minor)
      expect(minor).not_to be_closed
      expect(minor.owner).to be_nil
      expect(game.corporations).to include(minor)
      expect(game.abandoned_minors).to eq([minor])
    end

    it 'moves its trains to the Open Market' do
      game.abandon_minor!(minor)
      expect(minor.trains).to be_empty
      expect(game.depot.discarded).to include(train)
    end

    it 'removes its tokens permanently, freeing the slot' do
      game.abandon_minor!(minor)
      expect(city.tokens.compact).to be_empty
      expect(minor.placed_tokens).to be_empty
    end

    it 'sends its cash to the bank' do
      expect { game.abandon_minor!(minor) }.to change { game.bank.cash }.by(minor.cash)
      expect(minor.cash).to eq(0)
    end

    it 'keeps the track rights chit and abilities on the charter' do
      game.abandon_minor!(minor)
      expect(game.minor_floated_regions[minor.id]).to eq('UK')
      expect(minor.abilities).not_to be_empty
    end

    it 'stops operating' do
      game.abandon_minor!(minor)
      expect(game.operating_order).not_to include(minor)
    end

    it 'removes the certificate from the former owner' do
      expect { game.abandon_minor!(minor) }.to change { game.num_certs(player) }.by(-1)
      expect(player.percent_of(minor)).to eq(0)
    end

    it 'is not a share anyone can buy, so a funded player has nothing to buy' do
      allow(game).to receive(:major_phase?).and_return(true)
      step = stock_round!(game).active_step
      fund!(game, game.players.last)
      game.abandon_minor!(minor)
      expect(step.can_buy_any?(game.players.last)).to be_falsey
    end

    it 'does not count an unfloated minor as abandoned' do
      unfloated = game.corporation_by_id('L')
      expect(unfloated.owner).to be_nil
      expect(game.abandoned_minor?(unfloated)).to be(false)
      expect(game.abandoned_minors).not_to include(unfloated)
    end

    it 'cannot be bought, traded or merged by a player' do
      allow(game).to receive(:major_phase?).and_return(true)
      step = stock_round!(game, turn: 1).active_step
      expect(step.can_buy_corporation?(game.players.last, minor)).to be(true)
      game.abandon_minor!(minor)
      expect(step.can_buy?(game.players.last, minor.ipo_shares.first.to_bundle)).to be_falsey
      expect(step.can_buy_corporation?(game.players.last, minor)).to be(false)
      expect(game.merge_targets(player, minor)).to be_empty
    end
  end

  describe 'merge offer eligibility (§10.6)' do
    let(:rival) { game.players[1] }
    let(:third) { game.players[2] }
    let!(:third_major) { start_major!(game, 'GWR', third) }
    let!(:rival_major) { start_major!(game, 'LNWR', rival) }
    let(:round) { stock_round!(game) }

    before { enter_round!(game, round) }

    it 'lists other players majors, left of the owner first' do
      expect(game.merge_offer_majors(minor)).to eq([rival_major, third_major])
    end

    it 'excludes the owner own majors' do
      own_major = start_major!(game, 'PLM', player)
      expect(game.merge_offer_majors(minor)).not_to include(own_major)
    end

    it 'excludes a major with no treasury share, even with one in the Open Market' do
      treasury = rival_major.treasury_shares.reject(&:president)
      treasury.each { |share| game.share_pool.transfer_shares(share.to_bundle, game.share_pool) }
      expect(game.merge_offer_majors(minor)).to eq([third_major])
    end

    it 'excludes a major that merged this SR' do
      round.merged_majors << rival_major
      expect(game.merge_offer_majors(minor)).to eq([third_major])
    end

    it 'excludes an unconverted regional' do
      regional = start_regional!(game, 'SB', rival)
      expect(game.merge_offer_majors(minor)).not_to include(regional)
    end
  end

  describe 'moving the charter to a major' do
    it 'records the minor and transfers its abilities to a major' do
      major = start_major!(game, 'LNWR', player)
      abilities = minor.abilities.dup
      game.add_minor_charter!(minor, major)
      expect(game.merged_minors[major]).to include(minor)
      expect(minor.abilities).to be_empty
      expect(major.abilities).to include(*abilities)
    end

    it 'leaves the abilities on the charter for a national' do
      national = start_major!(game, 'LNWR', player)
      national.type = :national
      game.add_minor_charter!(minor, national)
      expect(game.merged_minors[national]).to include(minor)
      expect(minor.abilities).not_to be_empty
    end
  end

  describe 'minor A one-time payment (§15.1, §10.5)' do
    let(:minor) { start_minor!(game, 'A', player, 'SP') }
    let(:major) { start_major!(game, 'LNWR', player) }

    before do
      allow(game).to receive(:major_phase?).and_return(true)
      major.spend(major.cash, game.bank) if major.cash.positive?
    end

    it 'pays the major the current share value from the bank' do
      ability = minor.abilities.first
      bank_before = game.bank.cash
      game.add_minor_charter!(minor, major)
      expect(major.cash).to eq(major.share_price.price)
      expect(game.bank.cash).to eq(bank_before - major.share_price.price)
      expect(ability).to be_used
    end

    it 'never pays again once the ability is used' do
      minor.abilities.first.use!
      expect { game.add_minor_charter!(minor, major) }.not_to(change { major.cash })
    end

    it 'pays nothing to a national' do
      national = start_major!(game, 'PLM', player)
      national.type = :national
      cash_before = national.cash
      game.add_minor_charter!(minor, national)
      expect(national.cash).to eq(cash_before)
    end
  end

  describe 'buying an abandoned minor (§11.7)' do
    let(:former_owner) { game.players[1] }
    let(:minor_id) { 'D' }
    let(:zone) { 'UK' }
    let(:minor) { start_minor!(game, minor_id, former_owner, zone) }
    let(:charter) { minor }
    let!(:major) { start_major!(game, 'LNWR', player) }
    let(:round) { enter_round!(game, game.operating_round(1)) }
    let(:step) { round_step(round, Engine::Game::G18OE::Step::IssueShares) }
    let(:start_cash) { 300 }

    before do
      major.spend(major.cash, game.bank) if major.cash.positive?
      game.bank.spend(start_cash, major)
      game.abandon_minor!(minor)
      round.instance_variable_set(:@current_operator, major)
      step.setup
    end

    def buy!(entity = major, target = minor)
      step.process_choose(Engine::Action::Choose.new(entity, choice: target.id))
    end

    def sell_share!
      bundle = game.issuable_shares(major).first
      step.process_sell_shares(Engine::Action::SellShares.new(major, shares: bundle.shares, percent: bundle.percent))
    end

    it 'pays £60 to the bank' do
      expect { buy! }.to change { game.bank.cash }.by(60)
      expect(major.cash).to eq(start_cash - 60)
    end

    context 'with minor A' do
      let(:minor_id) { 'A' }
      let(:zone) { 'SP' }

      it 'pays the current share value from the bank besides the £60 price (§15.1)' do
        bank_before = game.bank.cash
        buy!
        expect(major.cash).to eq(start_cash - 60 + major.share_price.price)
        expect(game.bank.cash).to eq(bank_before + 60 - major.share_price.price)
      end
    end

    it 'gives the major the track rights and closes the minor' do
      buy!
      expect(game.merged_minors[major]).to eq([minor])
      expect(game.track_rights_zones(major)).to include('UK')
      expect(minor).to be_closed
      expect(game.abandoned_minors).to be_empty
    end

    { 'D' => 'UK', 'L' => 'RU', 'M' => 'IT' }.each do |id, region|
      context "with minor #{id}" do
        let(:minor_id) { id }
        let(:zone) { region }

        it "transfers #{id}'s ability to the major" do
          ability = charter.abilities.first
          buy!
          expect(major.abilities).to include(ability)
        end
      end
    end

    it 'gives the former owner nothing' do
      expect { buy! }.not_to(change { [former_owner.cash, former_owner.shares.size] })
    end

    it 'transfers no trains or tokens' do
      expect { buy! }.not_to(change { [major.trains.size, major.placed_tokens.size] })
      expect(city.tokens.compact).to be_empty
    end

    it 'is offered to a major with at least £60, as a choice' do
      expect(step.actions(major)).to include('choose', 'pass')
    end

    it 'is not offered below £60' do
      major.spend(major.cash - 59, game.bank)
      expect(step.actions(major)).not_to include('choose')
    end

    it 'lists the abandoned minors as cards while the major can buy one' do
      expect(step.choice_corporations(major)).to eq([minor])
    end

    it 'lists no cards once the major has bought one' do
      buy!
      expect(step.choice_corporations(major)).to be_empty
    end

    it 'lists no cards to a major below £60' do
      major.spend(major.cash - 59, game.bank)
      expect(step.choice_corporations(major)).to be_empty
    end

    it 'labels the button under an abandoned minor with the price' do
      expect(step.entity_choices(minor)).to eq(minor.id => "Buy for #{game.format_currency(60)}")
    end

    it 'has no choices for no target' do
      expect(step.entity_choices(nil)).to eq({})
    end

    it 'has no heading above the cards' do
      expect(step.choice_name).to be_nil
    end

    it 'is not offered to a regional or minor' do
      regional = start_regional!(game, 'SB', former_owner)
      fund!(game, regional, 100)
      round.instance_variable_set(:@current_operator, regional)
      expect(step.actions(regional)).not_to include('choose')
      other_minor = start_minor!(game, 'L', former_owner, 'RU')
      fund!(game, other_minor, 100)
      round.instance_variable_set(:@current_operator, other_minor)
      expect(step.actions(other_minor)).not_to include('choose')
    end

    it 'is not offered to a major that is not operating' do
      other = start_major!(game, 'PLM', player)
      fund!(game, other, 100)
      expect(step.actions(other)).not_to include('choose')
    end

    it 'is not offered when no minor is abandoned' do
      game.close_corporation(minor, quiet: true)
      expect(step.actions(major)).not_to include('choose')
    end

    it 'allows only one purchase per OR' do
      second = start_minor!(game, 'L', former_owner, 'RU')
      game.abandon_minor!(second)
      buy!
      expect(game.abandoned_minors).to eq([second])
      expect(step.can_buy_abandoned_minor?(major)).to be(false)
      expect(step.actions(major)).not_to include('choose')
    end

    it 'rejects a minor that is not abandoned' do
      other = start_minor!(game, 'L', former_owner, 'RU')
      expect { buy!(major, other) }.to raise_error(Engine::GameError)
    end

    it 'keeps the step open after buying while the major can still sell or redeem' do
      buy!
      expect(step.actions(major)).to include('sell_shares')
      expect(step).not_to be_passed
    end

    it 'leaves the purchase available and the step open after a sale' do
      sell_share!
      expect(step.can_buy_abandoned_minor?(major)).to be(true)
      expect(step).not_to be_passed
    end

    it 'keeps the step open after a sale while more shares can be sold' do
      game.close_corporation(minor, quiet: true)
      sell_share!
      expect(step).not_to be_passed
      expect(step.actions(major)).to include('sell_shares')
    end
  end

  describe 'showing an abandoned minor' do
    it 'hides the share table on an abandoned minor' do
      game.abandon_minor!(minor)
      expect(game.corporation_show_shares?(minor)).to be(false)
    end

    it 'keeps the share table on an open minor and a major' do
      major = start_major!(game, 'LNWR', player)
      expect(game.corporation_show_shares?(minor)).to be(true)
      expect(game.corporation_show_shares?(major)).to be(true)
    end
  end

  describe 'merge offers (§10.6)' do
    let(:rival) { game.players[1] }
    let(:third) { game.players[2] }
    let!(:third_major) { start_major!(game, 'GWR', third) }
    let!(:rival_major) { start_major!(game, 'LNWR', rival) }
    let(:offer_step) { Engine::Game::G18OE::Step::MergeOffer }
    let(:round) do
      allow(game).to receive(:major_phase?).and_return(true)
      game.phase.next!
      game.instance_variable_set(:@turn, 2)
      enter_round!(game, game.new_consolidation_round)
    end

    before { round }

    def own_major!
      start_major!(game, 'PLM', player)
    end

    def offer!
      own_major!
      act!(round, Engine::Action::Choose.new(player, choice: 'offer_or_merge', target: minor))
    end

    def offer_or_abandon!
      act!(round, Engine::Action::Choose.new(player, choice: 'offer_or_abandon', target: minor))
    end

    def accept!(president)
      act!(round, Engine::Action::Choose.new(president, choice: 'merge_offer'))
    end

    def decline_all!
      while round.active_step.is_a?(offer_step) && round.active_step.actions(round.current_entity).include?('pass')
        act!(round, Engine::Action::Pass.new(round.current_entity))
      end
    end

    it 'asks each eligible RR president in player order' do
      offer!
      expect(round.active_step).to be_a(offer_step)
      expect(round.active_step.current_entity).to eq(rival)
      act!(round, Engine::Action::Pass.new(rival))
      expect(round.active_step.current_entity).to eq(third)
    end

    it 'abandons after the last decline when the owner cannot merge' do
      offer_or_abandon!
      decline_all!
      expect(game.abandoned_minor?(minor)).to be(true)
      expect(round.current_actions).to be_empty
    end

    it 'abandons at once when nobody can be asked' do
      round.merged_majors.concat([rival_major, third_major])
      offer_or_abandon!
      expect(game.abandoned_minor?(minor)).to be(true)
      expect(round.merge_offer).to be_nil
      expect(round.current_actions).to be_empty
    end

    it 'goes straight to the owner merge choice after declines, with no pass' do
      offer!
      decline_all!
      expect(round.merge_minor).to eq(minor)
      expect(round.active_step.actions(minor.owner)).to eq(['merge'])
    end

    it 'merges a single offer without asking the owner' do
      offer!
      accept!(rival)
      decline_all!
      expect(round.pending_acquisition[:corporation]).to eq(rival_major)
      expect(round.merge_minor).to be_nil
    end

    it 'merges a single offer even when the owner could merge it' do
      own = own_major!
      act!(round, Engine::Action::Choose.new(player, choice: 'offer_or_merge', target: minor))
      accept!(rival)
      decline_all!
      expect(game.merged_minors[rival_major]).to eq([minor])
      expect(game.merged_minors[own]).to be_empty
    end

    it 'lets the owner choose among several offers, with no pass' do
      offer!
      accept!(rival)
      accept!(third)
      expect(round.active_step.current_entity).to eq(player)
      expect(round.active_step.actions(player)).to eq(['choose'])
      expect(round.active_step.choices.keys).to eq([rival_major.id, third_major.id])
    end

    it 'merges into the offer the owner chooses' do
      offer!
      accept!(rival)
      accept!(third)
      act!(round, Engine::Action::Choose.new(player, choice: third_major.id))
      expect(game.merged_minors[third_major]).to eq([minor])
      expect(game.merged_minors[rival_major]).to be_empty
    end

    it 'rejects a choice that is not an offer' do
      offer!
      accept!(rival)
      accept!(third)
      expect { act!(round, Engine::Action::Choose.new(player, choice: 'PLM')) }.to raise_error(Engine::GameError)
    end

    it 'gives the owner the share, and the major the cash and trains' do
      cash_before = rival_major.cash
      offer!
      accept!(rival)
      decline_all!
      expect(player.num_shares_of(rival_major)).to eq(1)
      expect(rival_major.cash).to eq(cash_before + 120)
      expect(train.owner).to eq(rival_major)
      expect(minor.cash).to eq(0)
    end

    it 'has the other president resolve token follow-ups' do
      offer!
      accept!(rival)
      decline_all!
      expect(round.active_step.current_entity).to eq(rival_major)
    end

    it 'counts an offer merge as the owner action, not a pass' do
      offer!
      accept!(rival)
      decline_all!
      expect(round.current_actions).not_to be_empty
      expect(round.last_to_act).to eq(player)
      expect(player.passed?).to be_falsey
    end

    it 'does not offer a second minor to a major that just merged (§10.5)' do
      second = start_minor!(game, 'L', player, 'RU')
      offer!
      accept!(rival)
      decline_all!
      expect(game.merge_offer_majors(second)).to eq([third_major])
    end

    it 'keeps the full president list in order while asking and moves the acting entity along it' do
      offer!
      step = round.active_step
      expect(step.context_entities).to eq([minor])
      expect(step.active_context_entity).to eq(minor)
      expect(step.override_entities).to eq([rival, third])
      act!(round, Engine::Action::Pass.new(rival))
      expect(round.active_step.override_entities).to eq([rival, third])
      expect(round.active_step.current_entity).to eq(third)
    end

    it 'keeps the full president list while the owner is choosing' do
      offer!
      accept!(rival)
      accept!(third)
      step = round.active_step
      expect(step.context_entities).to eq([minor])
      expect(step.active_context_entity).to eq(minor)
      expect(step.override_entities).to eq([rival, third])
      expect(step.current_entity).to eq(player)
    end

    it 'ends the round with no minors left' do
      offer_or_abandon!
      decline_all!
      act!(game, Engine::Action::Pass.new(game.round.current_entity)) while game.round.is_a?(Engine::Round::G18OE::Consolidation)
      expect(game.round).to be_a(Engine::Round::G18OE::Operating)
      expect(game.players.flat_map { |p| game.corporations.select { |c| c.type == :minor && c.owner == p } }).to be_empty
      expect(game.corporations.select { |c| c.type == :regional && c.floated? }).to be_empty
    end
  end
end
