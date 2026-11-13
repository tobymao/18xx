# frozen_string_literal: true

require 'spec_helper'

module Engine
  module Game
    module GFrost1831
      describe Game do
        let(:game) { Engine::Game::GFrost1831::Game.new(%w[P1 P2 P3], id: 1) }
        let(:p1) { game.players[0] }
        let(:p2) { game.players[1] }
        let(:tec) { game.corporation_by_id('TEC') }
        let(:gua) { game.corporation_by_id('GUA') }

        def start_stock_round(parliament: true)
          game.event_parliament_opens! if parliament
          game.instance_variable_set(:@round, game.stock_round)
        end

        def step
          game.round.active_step
        end

        def buy(player, faction)
          game.round.goto_entity!(player)
          game.process_action(Engine::Action::BuyShares.new(player, shares: faction.ipo_shares.first))
        end

        def sell(player, faction)
          game.round.goto_entity!(player)
          bundle = Engine::ShareBundle.new(player.shares_of(faction).first)
          game.process_action(Engine::Action::SellShares.new(player, shares: bundle.shares, share_price: nil,
                                                                     percent: bundle.percent))
        end

        it 'puts the Factions on their Parliament track at £70 when Parliament opens' do
          game.event_parliament_opens!

          game.factions.each do |faction|
            expect(faction.share_price.price).to eq(70)
            expect(faction.share_price.coordinates).to eq([Game::FACTION_ROW, 0])
          end
        end

        it 'does not sell Faction certificates before Parliament opens' do
          start_stock_round(parliament: false)

          expect(step.can_buy?(p1, tec.ipo_shares.first.to_bundle)).to be(false)
        end

        it 'sells a Faction certificate from Parliament and gives the Faction 1 Influence' do
          start_stock_round
          buy(p1, tec)

          expect(p1.cash).to eq(800 - 70)
          expect(p1.percent_of(tec)).to eq(20)
          expect(game.faction_influence('TEC')).to eq(1)
          expect(game.government_marker).not_to eq(Game::GOVERNMENT_START)
        end

        it 'applies the Opposition Rule' do
          start_stock_round
          buy(p1, tec)

          expect(step.can_buy?(p1, gua.ipo_shares.first.to_bundle)).to be(false)
          expect(step.can_buy?(p2, gua.ipo_shares.first.to_bundle)).to be(true)
        end

        it 'limits a player to 60% of a Faction' do
          start_stock_round
          3.times { tec.ipo_shares.first.transfer(p1) }

          expect(step.can_buy?(p1, tec.ipo_shares.first.to_bundle)).to be(false)
        end

        it 'founds the Faction at 40% and asks for a reserved city' do
          start_stock_round
          tec.ipo_shares.first.transfer(p1)
          buy(p1, tec)

          expect(tec.floated?).to be(true)
          expect(step).to be_a(GFrost1831::Step::HomeToken)
          expect(step.ipo_type(tec)).to be_nil
          expect(step.pending_token[:hexes].map(&:id)).to match_array(Game::FACTION_RESERVED_CITIES)

          city = game.hex_by_id('G8').tile.cities.first
          game.process_action(Engine::Action::PlaceToken.new(tec, city: city, slot: 0))

          expect(tec.tokens.first.hex.id).to eq('G8')
          expect(game.hex_by_id('G8').tile.icons.map(&:name)).not_to include('faction_base')
          expect(game.token_string(tec)).to eq('8/9')
        end

        it 'does not let Factions operate yet' do
          tec.floated = true

          expect(game.operating_order).not_to include(tec)
        end

        it 'returns sold certificates to Parliament without lowering the price' do
          start_stock_round
          buy(p1, tec)
          buy(p2, tec)
          start_stock_round(parliament: false)
          sell(p2, tec)

          expect(game.exception&.message).to be_nil
          expect(p2.percent_of(tec)).to eq(0)
          expect(tec.ipo_shares.size).to eq(4)
          expect(tec.share_price.price).to eq(70)
          expect(game.faction_influence('TEC')).to eq(1)
        end

        it 'lets the President sell the last certificate only if another player can take over' do
          start_stock_round
          buy(p1, tec)

          expect(step.can_sell?(p1, p1.shares_of(tec).first.to_bundle)).to be(false)
        end

        it 'does not sell a certificate when the Faction has no Influence to lose' do
          start_stock_round
          tec.ipo_shares.first.transfer(p1)

          expect(step.can_sell?(p1, p1.shares_of(tec).first.to_bundle)).to be(false)
        end

        it 'exchanges the Affiliate for a Faction certificate' do
          affiliate = game.company_by_id('PAF')
          affiliate.owner = p1
          p1.companies << affiliate
          start_stock_round
          game.round.goto_entity!(p1)

          exchange = game.round.steps.find { |s| s.is_a?(GFrost1831::Step::Exchange) }
          expect(game.factions.select { |f| exchange.can_exchange?(affiliate, f.ipo_shares.first.to_bundle) })
            .to match_array(game.factions)
          expect(tec.ipo_shares.first.president).to be(false)
          # the Exchange buttons on the Faction charter and in the abilities panel get a Share
          expect(step.can_gain?(p1, tec.ipo_shares.first, exchange: true)).to be(true)

          game.process_action(Engine::Action::BuyShares.new(affiliate, shares: tec.ipo_shares.first, percent: 20))

          expect(game.exception&.message).to be_nil
          expect(p1.percent_of(tec)).to eq(20)
          expect(tec.owner).to eq(p1)
          expect(tec.presidents_share.owner).to eq(p1)
          expect(p1.cash).to eq(800)
          expect(game.faction_influence('TEC')).to eq(1)
          expect(affiliate.closed?).to be(true)
          expect(exchange.can_exchange?(affiliate, gua.ipo_shares.first.to_bundle)).to be(false)
        end

        it 'does not exchange the Affiliate for an opposing Faction' do
          affiliate = game.company_by_id('PAF')
          affiliate.owner = p1
          p1.companies << affiliate
          start_stock_round
          buy(p1, tec)
          game.round.goto_entity!(p1)

          exchange = game.round.steps.find { |s| s.is_a?(GFrost1831::Step::Exchange) }
          expect(exchange.can_exchange?(affiliate, gua.ipo_shares.first.to_bundle)).to be(false)
          expect(exchange.can_exchange?(affiliate, game.corporation_by_id('LOR').ipo_shares.first.to_bundle)).to be(true)
        end

        it 'keeps corporations out of the Faction row' do
          cm = game.corporation_by_id('CM')
          price = game.stock_market.share_price([Game::FACTION_ROW - 1, 0])

          expect(game.stock_market.down(cm, price.coordinates)).to eq(price.coordinates)
        end
      end
    end
  end
end
