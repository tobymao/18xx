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
        it 'counts the president\'s cash and the value of the president\'s shares' do
          game.bank.spend(1, buyer)
          player_a.spend(player_a.cash - 100, game.bank)

          expect(game.can_afford_takeover?(buyer, target)).to be(false)

          # The president's ACL president's certificate is worth 20% of $100 x 10
          game.bank.spend(700, buyer)

          expect(game.can_afford_takeover?(buyer, target)).to be(true)
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
