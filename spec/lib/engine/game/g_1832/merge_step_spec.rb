# frozen_string_literal: true

require 'spec_helper'

module Engine
  describe Game::G1832::Step::Merge do
    let(:game) { Game::G1832::Game.new(%w[a b c]) }
    let(:player_a) { game.players[0] }
    let(:player_b) { game.players[1] }
    let(:acl) { game.corporation_by_id('ACL') }
    let(:salr) { game.corporation_by_id('SALR') }
    let(:round) do
      Game::G1832::Round::Merger.new(
        game, [described_class, Game::G1832::Step::SellSharesForTakeover, Engine::Step::DiscardTrain]
      )
    end
    let(:step) { round.steps.find { |s| s.is_a?(described_class) } }

    def give(player, shares)
      game.share_pool.buy_shares(player, ShareBundle.new(shares), exchange: :free)
    end

    # ACL and SALR both have a token in D16, which is given a two-slot tile, so they are connected.
    before do
      game.send(:next_round!)
      par = game.stock_market.par_prices.find { |p| p.price == 100 }
      hex = game.hex_by_id('D16')
      hex.lay(game.tiles.find { |t| t.color == :green && t.cities.any? { |c| c.slots == 2 } })
      [acl, salr].each do |corp|
        game.par_corporation(corp, par)
        corp.ipoed = true
        corp.floated = true
        corp.instance_variable_set(:@operating_history, { [1, 1] => :ran })
        hex.tile.cities.first.place_token(corp, corp.tokens[0], free: true, check_tokenable: false)
      end
      give(player_a, [acl.presidents_share])
      give(player_b, [salr.presidents_share])
      game.bank.spend(3000, acl)
      allow(game).to receive(:operating_order).and_return([acl, salr])
    end

    context 'when a player holds 40% of two connected corporations' do
      before { give(player_a, salr.ipo_shares.reject(&:president).first(2)) }

      it 'can merge with the other corporation, and offers a system or a takeover' do
        expect(round.entities).to include(acl)
        expect(step.mergeable_corporations(acl)).to eq([salr])

        step.process_merge(Action::Merge.new(acl, corporation: salr))

        expect(step.choices.keys).to include('takeover')
        expect(step.choices.keys).to include(*%w[system_AMTK system_BNSF system_IC system_CSX system_NS])
      end

      it 'forms the chosen system and lets the system act next' do
        step.process_merge(Action::Merge.new(acl, corporation: salr))
        step.process_choose(Action::Choose.new(acl, choice: 'system_AMTK'))

        system = game.corporation_by_id('AMTK')
        expect(system).to be_floated
        expect(acl).to be_closed
        expect(salr).to be_closed
        expect(round.post_merge_entity).to eq(system)
      end

      it 'takes over the other corporation when that is chosen' do
        step.process_merge(Action::Merge.new(acl, corporation: salr))
        step.process_choose(Action::Choose.new(acl, choice: 'takeover'))

        expect(salr).to be_closed
        expect(acl).not_to be_closed
        expect(round.post_merge_entity).to eq(acl)
      end
    end

    context 'when no player holds 40% of the two corporations combined' do
      it 'offers a takeover but no system formation' do
        step.process_merge(Action::Merge.new(acl, corporation: salr))

        expect(step.choices.keys).to eq(['takeover'])
      end

      it 'refuses to form a system even if one is chosen' do
        step.process_merge(Action::Merge.new(acl, corporation: salr))

        expect { step.process_choose(Action::Choose.new(acl, choice: 'system_AMTK')) }
          .to raise_error(GameError, /No player holds 40%/)
      end
    end
  end
end
