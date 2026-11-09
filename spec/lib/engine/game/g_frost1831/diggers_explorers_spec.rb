# frozen_string_literal: true

require 'spec_helper'

module Engine
  module Game
    module GFrost1831
      describe Game do
        let(:game) { Engine::Game::GFrost1831::Game.new(%w[P1 P2 P3], id: 1) }
        let(:p1) { game.players[0] }
        let(:corporation) { game.corporation_by_id('CM') }

        def give_company(player, sym)
          company = game.company_by_id(sym)
          company.owner = player
          player.companies << company
          company
        end

        def float(corporation, player)
          game.bank.spend(1000, player)
          game.par_corporation(corporation, game.stock_market.par_prices.find { |p| p.price == 100 })
          game.share_pool.buy_shares(player, corporation.shares.first)
          3.times { game.share_pool.buy_shares(player, corporation.ipo_shares.first) }
          game.place_home_token(corporation)
        end

        def start_operating_round
          game.phase.next!
          game.instance_variable_set(:@round, game.operating_round(1))
        end

        def buy_company(company)
          game.process_action(Engine::Action::BuyCompany.new(corporation, company: company, price: company.value))
        end

        def lay(entity, hex_id, tile_name)
          hex = game.hex_by_id(hex_id)
          tile = game.tiles.find { |t| t.name == tile_name }
          step = game.round.active_step
          rotation = (0..5).find do |r|
            tile.rotate!(r)
            step.legal_tile_rotation?(entity, hex, tile)
          end
          game.process_action(Engine::Action::LayTile.new(entity, tile: tile, hex: hex, rotation: rotation))
        end

        def tile_lay_ability(company)
          game.abilities(company, :tile_lay, time: 'sold')
        end

        before do
          float(corporation, p1)
        end

        it 'lets the buying corporation lay a free yellow tile on I4 with Diggers' do
          diggers = give_company(p1, 'PDI')
          start_operating_round
          buy_company(diggers)

          expect(game.round.active_step).to be_a(GFrost1831::Step::SpecialTrack)
          expect(game.round.active_step.actions(diggers)).to eq(%w[lay_tile])

          cash = corporation.cash
          lay(diggers, 'I4', '7')

          expect(game.hex_by_id('I4').tile.name).to eq('7')
          expect(corporation.cash).to eq(cash)
          expect(tile_lay_ability(diggers)).to be_nil
          expect(game.round.active_step).not_to be_a(GFrost1831::Step::SpecialTrack)
        end

        it 'lets the buying corporation lay a free yellow tile on one of the Explorers hexes' do
          explorers = give_company(p1, 'PEX')
          start_operating_round
          buy_company(explorers)

          lay(explorers, 'J7', '8')

          expect(game.exception).to be_nil
          expect(game.hex_by_id('J7').tile.name).to eq('8')
          expect(tile_lay_ability(explorers)).to be_nil
        end

        it 'refuses an Explorers tile outside I10, J7 and K10' do
          explorers = give_company(p1, 'PEX')
          start_operating_round
          buy_company(explorers)

          lay(explorers, 'I4', '7')

          expect(game.exception).to be_a(GameError)
          expect(game.hex_by_id('I4').tile.color).to eq(:white)
        end

        it 'does not let the corporation pass while a tile can be laid' do
          diggers = give_company(p1, 'PDI')
          start_operating_round
          buy_company(diggers)

          game.process_action(Engine::Action::Pass.new(diggers))

          expect(game.exception).to be_a(GameError)
          expect(tile_lay_ability(diggers)).not_to be_nil
          expect(game.round.active_step).to be_a(GFrost1831::Step::SpecialTrack)
        end

        it 'skips the free tile automatically when no tile can be laid' do
          diggers = give_company(p1, 'PDI')
          game.tiles.reject! { |t| %w[7 8 9].include?(t.name) }
          start_operating_round
          game.process_action(Engine::Action::BuyCompany.new(corporation, company: diggers, price: diggers.value),
                              add_auto_actions: true)

          expect(game.exception).to be_nil
          expect(tile_lay_ability(diggers)).to be_nil
          expect(game.hex_by_id('I4').tile.color).to eq(:white)
          expect(game.round.active_step).not_to be_a(GFrost1831::Step::SpecialTrack)
          expect(game.log.map(&:message)).to include('Diggers passes lay track')
        end

        it 'does not let corporations buy private companies in phase 2' do
          diggers = give_company(p1, 'PDI')
          game.instance_variable_set(:@round, game.operating_round(1))

          expect(game.round.active_step.actions(corporation)).not_to include('buy_company')

          buy_company(diggers)

          expect(game.exception).to be_a(GameError)
          expect(diggers.owner).to eq(p1)
        end
      end
    end
  end
end
