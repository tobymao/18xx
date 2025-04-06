# frozen_string_literal: true

require 'find'
require './spec/spec_helper'
require 'json'

module Engine
  describe Game::G18Norway do
    let(:players) { %w[a b c] }

    let(:game_file) do
      Find.find(FIXTURES_DIR).find { |f| File.basename(f) == "#{game_file_name}.json" }
    end

    let(:id_first_index_by_action_type) do
      file = File.open(game_file)
      data = JSON.parse(file.read)
      file.close
      data['actions'].each do |action|
        return action['id'] - 1 if action['type'] == first_action_type
      end
      1
    end

    context '18Norway buy ship' do
      let(:game_file_name) { '18_norway_buy_ship' }
      let(:first_action_type) { 'buy_train' }

      it 'Should not show ships when corporation must buy a train' do
        game = Engine::Game.load(game_file, at_action: id_first_index_by_action_type)
        corporation = game.current_entity

        # Force corporation to have no trains
        corporation.trains.clear
        # Remove ignore mandatory train ability
        corporation.remove_ability(game.abilities(corporation, :ignore_mandatory_train))

        step = game.round.active_step
        available = step.buyable_trains(corporation)
        ships = available.select { |train| game.ship?(train) }
        expect(ships.size).to eq(0)
      end

      it 'Should show ships when corporation must buy a train with ignore mandatory train ability' do
        game = Engine::Game.load(game_file, at_action: id_first_index_by_action_type)
        corporation = game.current_entity

        # Force corporation to have no trains
        corporation.trains.clear

        # Add ignore mandatory train ability
        corporation.add_ability(Engine::Ability::Base.new(
          type: 'ignore_mandatory_train',
          description: 'Not mandatory to own a train',
        ))

        step = game.round.active_step
        available = step.buyable_trains(corporation)
        ships = available.select { |train| game.ship?(train) }
        expect(ships.size).to eq(1)
      end

      it 'Should show ships when corporation has trains but cannot afford next train' do
        game = Engine::Game.load(game_file, at_action: id_first_index_by_action_type)
        corporation = game.current_entity

        # Give corporation a train enough money to buy next ship but not enough cash for next train
        corporation.trains << game.depot.upcoming.first
        corporation.cash = 150 # Less than cheapest train price but enough to buy ship
        game.depot.export_all!('2', silent: true) # Export 2 trains so corporation can afford next train

        step = game.round.active_step
        available = step.buyable_trains(corporation)
        ships = available.select { |train| game.ship?(train) }
        expect(ships.size).to be > 0
      end

      it 'Should not show ships that corporation already owns' do
        game = Engine::Game.load(game_file, at_action: id_first_index_by_action_type)
        corporation = game.current_entity

        # Give corporation a ship
        ship = game.depot.upcoming.find { |t| game.ship?(t) }
        corporation.trains << ship

        step = game.round.active_step
        available = step.buyable_trains(corporation)
        duplicate_ships = available.select { |train| game.ship?(train) && train.name == ship.name }
        expect(duplicate_ships.size).to eq(0)
      end
    end
  end
end
