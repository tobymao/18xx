# frozen_string_literal: true

require 'spec_helper'

module Engine
  describe Game::G1832::Game do
    let(:game) { Game::G1832::Game.new(%w[a b c]) }
    let(:player_a) { game.players[0] }
    let(:player_b) { game.players[1] }
    let(:player_c) { game.players[2] }
    let(:buyer) { game.corporation_by_id('ACL') }
    let(:target) { game.corporation_by_id('SALR') }

    def give(player, shares)
      game.share_pool.buy_shares(player, ShareBundle.new(shares), exchange: :free)
    end

    def place_token(corporation, index, hex_id)
      city = game.hex_by_id(hex_id).tile.cities.first
      city.place_token(corporation, corporation.tokens[index], free: true, check_tokenable: false)
    end

    describe 'takeover' do
      # B is SALR's president with 40%, C holds 10%, and its treasury holds the other 50%.
      before do
        game.send(:next_round!)
        par = game.stock_market.par_prices.find { |p| p.price == 100 }
        [buyer, target].each do |corp|
          game.par_corporation(corp, par)
          corp.ipoed = true
        end
        give(player_a, [buyer.presidents_share])
        give(player_b, [target.presidents_share, *target.ipo_shares.reject(&:president).first(2)])
        give(player_c, target.ipo_shares.reject(&:president).first(1))
      end

      describe '#takeover_cost' do
        it 'is par for the target\'s treasury shares and market price for everyone else\'s' do
          expect(target.shares_of(target).sum(&:percent)).to eq(50)

          # $500 for the treasury's 50% at par, $400 to B and $100 to C at market
          expect(game.takeover_cost(target)).to eq(1000)
        end

        it 'uses the market price, not par, for shares in the market and in players\' hands' do
          target.share_price = game.stock_market.market.flatten.compact.find { |space| space.price == 120 }

          expect(game.takeover_cost(target)).to eq(500 + (5 * 120)) # 500 at par for the treasury, 5 shares at 120
        end
      end

      describe '#can_afford_takeover?' do
        let(:other) { game.corporation_by_id('GMO') }

        def drain(president, leave:)
          buyer.spend(buyer.cash, game.bank) if buyer.cash.positive?
          game.bank.spend(1, buyer)
          president.spend(president.cash - leave, game.bank)
        end

        def pool_shares(corporation, count)
          shares = corporation.ipo_shares.reject(&:president).first(count)
          game.share_pool.transfer_shares(ShareBundle.new(shares), game.share_pool)
        end

        def par_other
          game.par_corporation(other, game.stock_market.par_prices.find { |p| p.price == 100 })
          other.ipoed = true
        end

        # B is GMO's president with 30%, A holds 20%
        def hold_other_shares
          par_other
          give(player_b, [other.presidents_share])
          give(player_b, other.ipo_shares.reject(&:president).first(1))
          give(player_a, other.ipo_shares.reject(&:president).first(2))
        end

        it 'counts the cash of the buyer and its president' do
          drain(player_a, leave: 100)
          game.bank.spend(899, buyer)

          expect(game.can_afford_takeover?(buyer, target)).to be(true)

          buyer.spend(1, game.bank)

          expect(game.can_afford_takeover?(buyer, target)).to be(false)
        end

        it 'counts shares of other corporations that fit in the market' do
          hold_other_shares
          drain(player_a, leave: 100)
          game.bank.spend(699, buyer)

          expect(game.can_afford_takeover?(buyer, target)).to be(true)
        end

        it 'does not count shares of the target' do
          give(player_a, target.ipo_shares.reject(&:president).first(1))
          drain(player_a, leave: 100)
          game.bank.spend(898, buyer)

          expect(game.can_afford_takeover?(buyer, target)).to be(false)
        end

        it 'does not count shares that would take the market above its limit' do
          hold_other_shares
          pool_shares(other, 5)
          drain(player_a, leave: 100)
          game.bank.spend(699, buyer)

          expect(game.can_afford_takeover?(buyer, target)).to be(false)
        end

        it 'counts the part of a holding that still fits in the market' do
          hold_other_shares
          pool_shares(other, 4)
          drain(player_a, leave: 100)
          game.bank.spend(798, buyer)

          expect(game.can_afford_takeover?(buyer, target)).to be(false)

          game.bank.spend(1, buyer)

          expect(game.can_afford_takeover?(buyer, target)).to be(true)
        end

        it 'counts a president\'s certificate of another corporation that another player could take over' do
          par_other
          give(player_a, [other.presidents_share])
          give(player_b, other.ipo_shares.reject(&:president).first(2))
          drain(player_a, leave: 100)
          game.bank.spend(699, buyer)

          expect(game.can_afford_takeover?(buyer, target)).to be(true)
        end

        it 'does not count a president\'s certificate that no other player could take over' do
          par_other
          give(player_a, [other.presidents_share])
          drain(player_a, leave: 100)
          game.bank.spend(699, buyer)

          expect(game.can_afford_takeover?(buyer, target)).to be(false)
        end

        context 'with shares of the buyer' do
          # A is ACL's president with 40% and B holds 30%
          before do
            give(player_a, buyer.ipo_shares.reject(&:president).first(2))
            give(player_b, buyer.ipo_shares.reject(&:president).first(3))
            drain(player_a, leave: 100)
          end

          it 'counts the shares that can be sold while A stays president' do
            game.bank.spend(799, buyer)

            expect(game.can_afford_takeover?(buyer, target)).to be(true)
          end

          it 'does not count the shares whose sale would make B the president' do
            game.bank.spend(798, buyer)

            expect(game.can_afford_takeover?(buyer, target)).to be(false)
          end

          it 'offers no bundle that includes the president\'s certificate or that gives B the lead' do
            bundles = game.takeover_sellable_bundles(buyer, target, buyer)

            expect(bundles.map(&:percent)).to eq([10])
          end
        end
      end

      describe Game::G1832::Step::SellSharesForTakeover do
        let(:round) { Struct.new(:pending_takeover).new({ buyer: buyer, target: target }) }
        let(:step) { described_class.new(game, round) }
        let(:other) { game.corporation_by_id('GMO') }

        before do
          game.par_corporation(other, game.stock_market.par_prices.find { |p| p.price == 100 })
          other.ipoed = true
          give(player_b, [other.presidents_share, other.ipo_shares.reject(&:president).first])
          give(player_a, other.ipo_shares.reject(&:president).first(2))
          give(player_a, target.ipo_shares.reject(&:president).first(1))
        end

        it 'offers shares of other corporations' do
          bundle = game.bundles_for_corporation(player_a, other).first

          expect(step.can_sell?(player_a, bundle)).to be(true)
        end

        it 'does not offer shares of the target' do
          bundle = game.bundles_for_corporation(player_a, target).first

          expect(step.can_sell?(player_a, bundle)).to be(false)
        end

        it 'does not offer shares held by another player' do
          bundle = game.bundles_for_corporation(player_b, other).reject(&:presidents_share).first

          expect(step.can_sell?(player_a, bundle)).to be(false)
        end

        it 'does not offer shares that would take the market above its limit' do
          game.share_pool.transfer_shares(ShareBundle.new(other.ipo_shares.reject(&:president).first(5)), game.share_pool)
          bundle = game.bundles_for_corporation(player_a, other).first

          expect(step.can_sell?(player_a, bundle)).to be(false)
        end
      end

      describe '#perform_takeover' do
        context 'when the buyer can pay' do
          before { game.bank.spend(2000, buyer) }

          it 'pays the players the market price and the bank the rest' do
            b_cash = player_b.cash
            c_cash = player_c.cash
            bank_cash = game.bank.cash

            game.perform_takeover(buyer, target)

            expect(player_b.cash).to eq(b_cash + 400)
            expect(player_c.cash).to eq(c_cash + 100)
            expect(game.bank.cash).to eq(bank_cash + 500)
            expect(buyer.cash).to eq(1000)
          end

          it 'closes the target and moves its cash and tokens to the buyer' do
            game.bank.spend(150, target)
            place_token(target, 0, 'F6')

            game.perform_takeover(buyer, target)

            expect(target).to be_closed
            expect(buyer.cash).to eq(1000 + 150)
            expect(buyer.tokens.select(&:city).map { |t| t.city.hex.id }).to eq(['F6'])
            expect(buyer.tokens.size).to eq(6) # its own three and the target's three
          end
        end

        context 'when the buyer cannot pay' do
          before { game.bank.spend(300, buyer) }

          it 'has the president contribute the shortfall' do
            a_cash = player_a.cash

            game.perform_takeover(buyer, target)

            expect(player_a.cash).to eq(a_cash - 700)
            expect(buyer.cash).to eq(0)
            expect(target).to be_closed
          end

          it 'refuses, and leaves the target alone, if the president cannot cover it' do
            player_a.spend(player_a.cash - 100, game.bank)

            expect { game.perform_takeover(buyer, target) }
              .to raise_error(GameError, /cannot fund the takeover/)

            expect(target).not_to be_closed
          end
        end

        it 'tightens the certificate limit one more step when the target is a system' do
          system = game.corporation_by_id('AMTK')
          game.par_corporation(system, game.stock_market.par_prices.find { |p| p.price == 100 })
          system.ipoed = true
          game.bank.spend(5000, buyer)

          expect(game).to receive(:tighten_cert_limit_by_one).once
          game.perform_takeover(buyer, system)
        end

        it 'does not tighten it again for an ordinary corporation' do
          game.bank.spend(5000, buyer)

          expect(game).not_to receive(:tighten_cert_limit_by_one)
          game.perform_takeover(buyer, target)
        end
      end
    end
  end
end
