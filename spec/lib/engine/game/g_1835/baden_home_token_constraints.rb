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
      end.to raise_error Engine::GameError
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
      end.to raise_error Engine::GameError
    end
  end


  # Weitere tests:
  # - Nicht manuell Pöppeln, bevor Baden in Betrieb
  # - manuell pöppeln geht, sobald Baden in Betrieb
  # - mit Pfalzbahnen pöppeln geht, sobald Baden in Betrieb
end
