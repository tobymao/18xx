# frozen_string_literal: true

require 'spec_helper'

module Engine
  module Game
    module GFrost1831
      describe Game do
        let(:game) { Engine::Game::GFrost1831::Game.new(%w[P1 P2 P3], id: 1) }
        let(:p1) { game.players[0] }
        let(:cm) { game.corporation_by_id('CM') }

        before do
          game.par_corporation(cm, game.stock_market.par_prices.first)
          cm.ipo_shares.first(5).each { |share| share.transfer(p1) }
          cm.owner = p1
          game.apply_faction_influence!(cm, 'TEC')
          game.apply_faction_influence!(cm, 'LOR')
          game.instance_variable_set(:@round, game.operating_round(1))
        end

        def choose(faction)
          game.process_action(Engine::Action::Choose.new(cm, choice: faction))
          expect(game.exception&.message).to be_nil
        end

        def straight_tile(rotation)
          game.tiles.find { |t| t.name == '9' }.tap { |t| t.rotate!(rotation) }
        end

        it 'gives Influence for completing a section of the New London Route' do
          hex = game.hex_by_id('A4')
          game.after_lay_tile(hex, straight_tile(0), cm)

          expect(game.round.active_step).to be_a(GFrost1831::Step::ChooseInfluence)
          expect(game.round.active_step.ipo_type(cm)).to be_nil
          expect(game.round.active_step.choices.keys).to eq(%w[TEC LOR])
          expect(game.round.active_step.choice_view).to eq(:influence_arena)
          expect(hex.tile.icons.map(&:name)).not_to include('influence_cube')

          choose('LOR')

          expect(game.corporation_influence(cm)).to eq('TEC' => 1, 'LOR' => 2)
          expect(game.faction_influence('LOR')).to eq(2)
          expect(game.pending_influence_choice).to be_nil
          expect(game.log.map(&:message)).to include('CM gains 1 Influence (New London Route, A4)')
        end

        it 'gives no Influence when the tile does not cover the route' do
          game.after_lay_tile(game.hex_by_id('A4'), straight_tile(1), cm)

          expect(game.pending_influence_choice).to be_nil
        end

        it 'gives Influence to the first Corporation to reach a blue space' do
          blue = game.stock_market.share_prices_with_types([:pays_bonus_1]).first
          from = cm.share_price
          cm.share_price = blue
          game.log_share_price(cm, from)

          expect(game.pending_influence_choice[:reason]).to eq(:blue_space)
          expect(game.log.map(&:message).last(3)).to match([a_string_starting_with("CM's share price moves"),
                                                            "CM is first to reach #{game.format_currency(blue.price)}",
                                                            'CM gains 1 Influence (first to reach a blue space)'])
        end

        it 'returns a Corporation from the Influence Zone with Influence' do
          start = game.stock_market.share_price([1, 1])
          cm.share_price.corporations.delete(cm)
          cm.share_price = start
          start.corporations << cm
          game.sold_out_stock_movement(cm)

          expect(cm.share_price).to eq(start)
          expect(game.pending_influence_choice[:reason]).to eq(:influence_zone)
        end

        it 'ends the Stock Round once after a sold-out Corporation allocates its Influence' do
          start = game.stock_market.share_price([1, 1])
          cm.share_price.corporations.delete(cm)
          cm.share_price = start
          start.corporations << cm
          cm.ipoed = true
          cm.ipo_shares.each { |share| share.transfer(game.players[1]) }
          game.instance_variable_set(:@round, game.stock_round)
          game.players.each { |player| game.process_action(Engine::Action::Pass.new(player)) }

          expect(game.round.active_step).to be_a(GFrost1831::Step::ChooseInfluence)

          choose('TEC')

          expect(game.round).to be_a(Engine::Round::Operating)
          expect(game.players.first.name).to eq('P1')
          expect(game.log.map(&:message).count('CM gains 1 Influence (Influence Zone)')).to eq(1)
        end

        it 'discards the Influence when both Factions are at the limit' do
          2.times do
            game.apply_faction_influence!(cm, 'TEC')
            game.apply_faction_influence!(cm, 'LOR')
          end
          game.after_lay_tile(game.hex_by_id('A4'), straight_tile(0), cm)

          expect(game.pending_influence_choice).to be_nil
        end

        it 'allocates the D-train Influence before the Turmoil it triggers' do
          game.instance_variable_set(:@government_marker, [0, 0])
          d_train = game.depot.upcoming.find { |t| t.name == 'D' }
          game.bank.spend(d_train.price, cm)
          game.buy_train(cm, d_train, d_train.price)
          game.phase.buying_train!(cm, d_train, game.depot)

          expect(game.log.map(&:message)).to include('D train influence must be allocated before Turmoil consequences')
          expect(game.log.map(&:message)).not_to include(a_string_starting_with('Government: '))

          choose('TEC')

          expect(game.log.map(&:message)).to include(a_string_starting_with('Government: '))
        end
      end
    end
  end
end
