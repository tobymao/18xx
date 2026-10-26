# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1835::Game do
  describe 'baden_is_forced_to_place_home_token_during_stock_round' do
    it 'with L6 already green forces Baden to place home token during stock round' do
      game = fixture_at_action(365)

      expect(game.current_entity).to eq(game.corporation_by_id('BA'))
      expect(game.round.active_step).to be_a(Engine::Step::HomeToken)
    end
  end

  describe 'baden_is_forced_to_place_home_token_during_operating_round' do
    it 'forces Baden to place home token during operating round as soon as tile on L6 is laid' do
      game = fixture_at_action(262)

      expect(game.current_entity).to eq(game.corporation_by_id('BA'))
      expect(game.round.active_step).to be_a(Engine::Step::HomeToken)
    end

    it 'allows other corps to token in L6 after Baden has placed its home token' do
      game = fixture_at_action(281)

      expect(game.current_entity).to eq(game.corporation_by_id('BY'))

      expect do
        bayern = game.corporation_by_id('BY')
        l6 = game.hex_by_id('L6').tile.cities[1]
        game.process_action(Engine::Action::PlaceToken.new(bayern, city: l6)).maybe_raise!
      end.to_not raise_error
    end
  end

  describe 'corporations_cannot_token_in_L6_using_Pfalzbahnen_before_Baden_floats' do
    it 'does not let corporations token in L6 using the Pfalzbahnen private before Baden floats' do
      game = fixture_at_action(301)

      expect(game.current_entity).to eq(game.corporation_by_id('BY'))
      expect(game.round.active_step).to be_a(Engine::Step::Token)
      expect(game.corporation_by_id('BA').floated?).to be false

      expect do
        pfalzbahnen = game.company_by_id('PB')
        bayern = game.corporation_by_id('BY')
        l6 = game.hex_by_id('L6').tile.cities.first # Baden home station
        game.process_action(Engine::Action::PlaceToken.new(pfalzbahnen, city: l6, tokener: bayern)).maybe_raise!
      end.to raise_error(Engine::GameError)
    end

    it 'lets corporations token in L6 using the Pfalzbahnen private after Baden has placed its home token' do
      game = fixture_at_action(367)

      expect(game.current_entity).to eq(game.corporation_by_id('BY'))
      expect(game.round.active_step).to be_a(Engine::Step::Token)
      expect(game.corporation_by_id('BA').floated?).to be true

      pfalzbahnen = game.company_by_id('PB')
      expect do
        bayern = game.corporation_by_id('BY')
        l6 = game.hex_by_id('L6').tile.cities.first # Baden home station
        game.process_action(Engine::Action::PlaceToken.new(pfalzbahnen, city: l6, tokener: bayern)).maybe_raise!
      end.to_not raise_error

      expect(pfalzbahnen.closed?).to be true
    end

    it 'leaves the Pfalzbahnen open after using the lay track ability' do
      game = fixture_at_action(299)

      expect(game.current_entity).to eq(game.corporation_by_id('BY'))
      expect(game.round.active_step).to be_a(Engine::Step::Track)

      # Lay green tile on L6 without connectivity
      pfalzbahnen = game.company_by_id('PB')
      l6 = game.hex_by_id('L6')
      green_tile = game.tile_by_id('210-0')
      game.process_action(Engine::Action::LayTile.new(pfalzbahnen, tile: green_tile, hex: l6, rotation: 0)).maybe_raise!

      expect(pfalzbahnen.closed?).to be false
    end
  end

  describe 'corporations_cannot_manually_token_in_L6_before_Baden_floats' do
    it 'does not let corporations token manually in L6 private before Baden floats' do
      game = fixture_at_action(336)

      expect(game.current_entity).to eq(game.corporation_by_id('BY'))
      expect(game.round.active_step).to be_a(Engine::Step::Token)
      expect(game.corporation_by_id('BA').floated?).to be false

      expect do
        bayern = game.corporation_by_id('BY')
        l6 = game.hex_by_id('L6').tile.cities.first # Baden home station
        game.process_action(Engine::Action::PlaceToken.new(bayern, city: l6)).maybe_raise!
      end.to raise_error(Engine::GameError)
    end
  end
end
