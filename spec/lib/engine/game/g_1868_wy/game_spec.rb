# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1868WY::Game do
  describe 144_719 do
    it 'attaching the "Big Boy" locomotive token' do
      # OR 3.1
      # RCL attaches the token to a 3+2, making a [4+3]
      game = fixture_at_action(283)

      expect(game.big_boy_train.id).to eq('3-3')
      expect(game.big_boy_train.name).to eq('[4+3]')
      expect(game.big_boy_train_original.id).to eq('3-3')
      expect(game.big_boy_train_original.name).to eq('3+2')
      expect(game.big_boy_train_dh_original).to eq(nil)

      # RCL combines the 2+2 and [4+3] to a [6+5]
      game.process_to_action(363)
      expect(game.big_boy_train.id).to eq('2-4_3-3-0')
      expect(game.big_boy_train.name).to eq('[6+5]')
      expect(game.big_boy_train_original.id).to eq('2-4_3-3-0')
      expect(game.big_boy_train_original.name).to eq('5+4')
      expect(game.big_boy_train_dh_original.id).to eq('3-3')
      expect(game.big_boy_train_dh_original.name).to eq('3+2')

      # RCL is done running the [6+5]
      game.process_to_action(365)
      expect(game.big_boy_train.id).to eq('3-3')
      expect(game.big_boy_train.name).to eq('[4+3]')
      expect(game.big_boy_train_original.id).to eq('3-3')
      expect(game.big_boy_train_original.name).to eq('3+2')
      expect(game.big_boy_train_dh_original).to eq(nil)

      # RCL bought a 4+3 and moved the token to it
      # end of RCL in OR 3.1
      game.process_to_action(367)
      expect(game.big_boy_train.id).to eq('4-0')
      expect(game.big_boy_train.name).to eq('[5+4]')
      expect(game.big_boy_train_original.id).to eq('4-0')
      expect(game.big_boy_train_original.name).to eq('4+3')
      expect(game.big_boy_train_dh_original).to eq(nil)

      # after another company finishes running double-headed trains, RCL and
      # the Big Boy should be unaffected
      game.process_to_action(385)
      expect(game.big_boy_train.id).to eq('4-0')
      expect(game.big_boy_train.name).to eq('[5+4]')
      expect(game.big_boy_train_original.id).to eq('4-0')
      expect(game.big_boy_train_original.name).to eq('4+3')
      expect(game.big_boy_train_dh_original).to eq(nil)

      # OR 3.2
      # should be the same as end of OR 3.1
      game.process_to_action(433)
      expect(game.big_boy_train.id).to eq('4-0')
      expect(game.big_boy_train.name).to eq('[5+4]')
      expect(game.big_boy_train_original.id).to eq('4-0')
      expect(game.big_boy_train_original.name).to eq('4+3')
      expect(game.big_boy_train_dh_original).to eq(nil)
    end
  end

  describe 'tokenless DPR' do
    describe 'tokenless_dpr_choose_new_home' do
      it 'must choose home city when started' do
        game = fixture_at_action(540)

        expect(game.dpr.floated?).to eq(false)
        expect(game.dpr.coordinates).to eq(nil)
        expect(game.tokenless_dpr?(game.dpr)).to eq(true)
        expect(game.dpr.next_token.price).to eq(0)
        expect(game.active_step.class).to eq(Engine::Game::G1868WY::Step::HomeToken)
        expect(game.current_entity).to eq(game.dpr)
      end

      it 'if not floated when started (phase 5+), reserves home city' do
        game = fixture_at_action(540)

        expect(game.phase.name).to eq('6')
        expect(game.hex_by_id('K15').tile.reserved_by?(game.dpr)).to eq(false)

        game.process_to_action(541)

        expect(game.dpr.coordinates).to eq('K15')
        expect(game.hex_by_id('K15').tile.cities[0].reserved_by?(game.dpr)).to eq(true)
        expect(game.dpr.floated?).to eq(false)
        expect(game.tokenless_dpr?(game.dpr)).to eq(true)
        expect(game.dpr.next_token.price).to eq(0)
      end

      it 'home token is placed when floated' do
        game = fixture_at_action(553)

        expect(game.dpr.coordinates).to eq('K15')
        expect(game.hex_by_id('K15').tile.reserved_by?(game.dpr)).to eq(false)
        expect(game.dpr.floated?).to eq(true)
        expect(game.tokenless_dpr?(game.dpr)).to eq(false)
        expect(game.dpr.tokens.first.hex.id).to eq('K15')
      end

      it "BUSTS removes DPR's only token" do
        game = fixture_at_action(689)

        expect(game.tokenless_dpr?(game.dpr)).to eq(false)
        expect(game.dpr.coordinates).to eq('K15')
        expect(game.dpr.tokens.first.hex.id).to eq('K15')
        expect(game.dpr.next_token.price).to eq(40)

        game.process_to_action(690)

        expect(game.tokenless_dpr?(game.dpr)).to eq(true)
        expect(game.dpr.coordinates).to eq(nil)
        expect(game.dpr.tokens.first.hex).to eq(nil)
        expect(game.dpr.next_token.price).to eq(0)
      end

      it 'may choose any city as home on next OR but cannot lay track' do
        game = fixture_at_action(722)

        expect(game.tokenless_dpr?(game.dpr)).to eq(true)
        expect(game.active_step.class).to eq(Engine::Game::G1868WY::Step::Dividend)
        expect(game.current_entity).to eq(game.corporation_by_id('FE&MV'))

        game.process_to_action(723)

        expect(game.tokenless_dpr?(game.dpr)).to eq(true)
        expect(game.current_entity).to eq(game.dpr)
        expect(game.active_step.class).to eq(Engine::Game::G1868WY::Step::Token)
        expect(game.dpr.coordinates).to eq(nil)

        # can only place token in cities with available slots and a tile laid
        # there (so Boomtowns that have developed into Boom Cities but have no
        # tile are not available)
        expect(game).to have_available_hexes(%w[C9 C11 D20 D24 H18 J6 L2 M21 M25])

        game.process_to_action(724)

        expect(game.tokenless_dpr?(game.dpr)).to eq(false)
        expect(game.dpr.coordinates).to eq('H18')
        expect(game.dpr.tokens.first.hex.id).to eq('H18')
      end
    end

    describe 'tokenless_dpr_cannot_token_during_sr_can_lay_track_for_home' do
      it 'places token immediately when home is chosen if floated' do
        game = fixture_at_action(403)

        expect(game.dpr.floated?).to eq(true)
        expect(game.dpr.coordinates).to eq(nil)

        game.process_to_action(404)

        expect(game.dpr.floated?).to eq(true)
        expect(game.dpr.coordinates).to eq('C11')
      end

      it 'does not allow DPR to place home token during SR' do
        game = fixture_at_action(589)

        expect(game.current_entity).to eq(game.dpr.owner)
        expect(game.active_step.class).to eq(Engine::Game::G1868WY::Step::StockRoundAction)
        expect(game.active_step.actions(game.dpr.owner)).not_to include('place_token')
      end

      it 'skips the track step if there are any available token slots on the map' do
        game = fixture_at_action(676)

        expect(game.current_entity).to eq(game.corporation_by_id('WNW'))
        expect(game.home_token_locations(game.dpr)).not_to eq([])

        game.process_to_action(677)

        expect(game.current_entity).to eq(game.dpr)
        expect(game.active_step.class).to eq(Engine::Game::G1868WY::Step::Token)
      end

      it 'can upgrade lay/upgrade a tile if no cities are availbe for its new home, then must place token' do
        game = fixture_at_action(743)

        expect(game.active_step.class).to eq(Engine::Game::G1868WY::Step::Track)
        expect(game.current_entity).to eq(game.dpr)

        # cities should be available, regardless of whether an upgrade that
        # opens a new slot exists
        expect(game).to have_available_hexes(%w[B16 C9 H10 H18 I9 J6 K15 K17 L2 L8 L10 M21 M25])

        game.process_to_action(744)

        # must place the token in the laid hex
        token_step = game.active_step
        expect(token_step.class).to eq(Engine::Game::G1868WY::Step::Token)
        expect(game.tokenless_dpr?(game.dpr)).to eq(true)
        expect(token_step.actions(game.dpr)).to eq(['place_token'])
        expect(game).to have_available_hexes(%w[L10])
      end
    end
  end
end
