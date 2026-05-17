# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G18ESP::Corporation do
  # SFVA at action 106: goals_reached_counter=0, destination_connected=false,
  # par_price=90, cash=350, three blocked tokens (used=true, no hex),
  # destination icon still present on hex C1.
  # Action 107 is the first action that causes SFVA to reach its destination,
  # so 106 is the last moment before any destination goal has been processed.
  let(:fixture_data) { JSON.parse(File.read("#{FIXTURES_DIR}/18ESP/18ESP_game_end_second_eight.json")) }
  let(:game) { Engine::Game.load(fixture_data, at_action: 106, strict: false) }
  let(:corp) { game.corporation_by_id('SFVA') }

  describe '#goal_reached!(:destination)' do
    context 'when destination is not yet connected' do
      it 'pays the bonus exactly once no matter how many times it is called' do
        pre_cash    = corp.cash # 350
        pre_goals   = corp.goals_reached_counter # 0
        pre_log     = game.log.to_a.size
        pre_bank    = game.bank.cash
        pre_blocked = corp.tokens.count { |t| t.used && !t.hex } # 3
        expected_bonus = corp.par_price.price * (pre_goals + 1) # 90

        expect(corp.destination_connected?).to be_falsy
        expect(game.hex_by_id(corp.destination).tile.icons.map(&:name)).to include(corp.name)

        corp.goal_reached!(:destination)

        snap_cash    = corp.cash
        snap_goals   = corp.goals_reached_counter
        snap_log     = game.log.to_a.size
        snap_bank    = game.bank.cash
        snap_blocked = corp.tokens.count { |t| t.used && !t.hex }

        expect(corp.destination_connected?).to be true
        expect(snap_goals).to eq(pre_goals + 1)
        expect(snap_cash).to eq(pre_cash + expected_bonus)
        expect(snap_bank).to eq(pre_bank - expected_bonus)
        expect(snap_log).to eq(pre_log + 1)
        expect(snap_blocked).to eq(pre_blocked - 1)
        expect(game.hex_by_id(corp.destination).tile.icons.map(&:name)).not_to include(corp.name)

        # second call must change nothing
        corp.goal_reached!(:destination)

        expect(corp.destination_connected?).to be true
        expect(corp.goals_reached_counter).to eq(snap_goals)
        expect(corp.cash).to eq(snap_cash)
        expect(game.bank.cash).to eq(snap_bank)
        expect(game.log.to_a.size).to eq(snap_log)
        expect(corp.tokens.count { |t| t.used && !t.hex }).to eq(snap_blocked)
      end

      it 'three calls produce the same result as one call' do
        corp.goal_reached!(:destination)
        after_one = {
          goals: corp.goals_reached_counter,
          cash: corp.cash,
          blocked: corp.tokens.count { |t| t.used && !t.hex },
          log: game.log.to_a.size,
        }

        2.times { corp.goal_reached!(:destination) }

        expect(corp.goals_reached_counter).to eq(after_one[:goals])
        expect(corp.cash).to eq(after_one[:cash])
        expect(corp.tokens.count { |t| t.used && !t.hex }).to eq(after_one[:blocked])
        expect(game.log.to_a.size).to eq(after_one[:log])
      end
    end

    context 'when destination is already connected' do
      before { corp.goal_reached!(:destination) }

      it 'is a no-op' do
        pre_cash  = corp.cash
        pre_goals = corp.goals_reached_counter
        pre_log   = game.log.to_a.size
        pre_bank  = game.bank.cash

        corp.goal_reached!(:destination)

        expect(corp.cash).to eq(pre_cash)
        expect(corp.goals_reached_counter).to eq(pre_goals)
        expect(game.log.to_a.size).to eq(pre_log)
        expect(game.bank.cash).to eq(pre_bank)
      end
    end

    it 'does not affect offboard or harbor goal flags' do
      expect(corp.ran_offboard).to be_falsy
      expect(corp.ran_harbor).to be_falsy

      3.times { corp.goal_reached!(:destination) }

      expect(corp.ran_offboard).to be_falsy
      expect(corp.ran_harbor).to be_falsy
    end
  end
end
