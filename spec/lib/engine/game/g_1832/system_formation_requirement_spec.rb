# frozen_string_literal: true

require 'spec_helper'

module Engine
  describe Game::G1832::Game do
    let(:game) { Game::G1832::Game.new(%w[a b c]) }

    describe 'system formation requirement' do
      let(:player_a) { game.players[0] }
      let(:player_b) { game.players[1] }
      let(:player_c) { game.players[2] }
      let(:acl) { game.corporation_by_id('ACL') }
      let(:salr) { game.corporation_by_id('SALR') }
      let(:system) { game.corporation_by_id('AMTK') }

      def give(player, shares)
        game.share_pool.buy_shares(player, ShareBundle.new(shares), exchange: :free)
      end

      before do
        game.send(:next_round!)
        par = game.stock_market.par_prices.find { |p| p.price == 100 }
        [acl, salr].each do |corp|
          game.par_corporation(corp, par)
          corp.ipoed = true
        end
        give(player_a, [acl.presidents_share])
        give(player_b, [salr.presidents_share])
      end

      context 'when no player holds 40% of the two corporations combined' do
        before do
          give(player_a, acl.ipo_shares.reject(&:president).first(1)) # 30%
          give(player_b, salr.ipo_shares.reject(&:president).first(1)) # 30%
          give(player_c, acl.ipo_shares.reject(&:president).first(2)) # 20%
        end

        it 'cannot form a system' do
          expect(game.can_form_system?(acl, salr)).to be(false)
        end

        it 'refuses to form one even if asked, and leaves both corporations alone' do
          expect { game.perform_system_formation(acl, salr, system) }
            .to raise_error(GameError, 'No player holds 40% of ACL and SALR combined')

          expect(system).not_to be_floated
          expect(acl).not_to be_closed
          expect(salr).not_to be_closed
        end
      end

      context 'when one player holds exactly 40% across the two corporations' do
        before { give(player_a, salr.ipo_shares.reject(&:president).first(2)) } # 20% + 20%

        it 'can form a system, with that player as its president' do
          expect(game.can_form_system?(acl, salr)).to be(true)

          game.perform_system_formation(acl, salr, system)

          expect(system.owner).to eq(player_a)
          expect(player_a.shares_of(system).map(&:percent)).to eq([20])
        end
      end

      it 'does not add up shares held by different players' do
        give(player_a, acl.ipo_shares.reject(&:president).first(1)) # 30%
        give(player_b, acl.ipo_shares.reject(&:president).first(1)) # 30% (20% SALR + 10% ACL)

        expect(game.can_form_system?(acl, salr)).to be(false)
      end
    end
  end
end
