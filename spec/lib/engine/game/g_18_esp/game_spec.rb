# frozen_string_literal: true

require 'spec_helper'

# Frozen snapshot of the destination goal mechanism after a full fixture replay.
# Any deviation signals that a refactor step (Issue #12579) changed the behaviour,
# intentionally or not.
#
# Values captured at commit bc6657312. AVT and TBF reach their destination not via
# goal_reached!(:destination) but through the full-cap mechanism (game.rb ~line 589),
# hence goals=0.

describe Engine::Game::G18ESP::Game do
  describe '18ESP_game_end_second_eight' do
    # 1335 = total action count for this fixture; loads the complete game.
    let(:game) { fixture_at_action(1335) }

    it 'replays without exceptions' do
      expect(game.exception).to be_nil
    end

    it 'logs the destination goal exactly 8 times' do
      count = game.log.to_a.count { |e| e.message.include?('reached destination goal') }
      expect(count).to eq(8)
    end

    it 'logs each corporation reaching its destination goal at most once' do
      # Guards against double-emission from CDC (inter-OR) and Track (same-turn).
      # goal_reached! is idempotent, but a double log entry would still surface here.
      # Log format: "SFVA reached destination goal. ..." — split.first is the corp name.
      per_corp = game.log.to_a
        .select { |e| e.message.include?('reached destination goal') }
        .group_by { |e| e.message.split.first }
      per_corp.each do |corp, entries|
        expect(entries.size).to eq(1), "#{corp} logged 'reached destination goal' #{entries.size} times"
      end
    end

    it 'removes all destination icons by game end' do
      game.corporations.select(&:destination).each do |corp|
        icons = game.hex_by_id(corp.destination).tile.icons.map(&:name)
        expect(icons).not_to include(corp.name),
                             "#{corp.name}: destination icon still present on #{corp.destination}"
      end
    end

    # Frozen expected state per corporation at game end.
    # goals     = goals_reached_counter
    # connected = destination_connected?
    {
      'CRB' => { goals: 3, connected: true },
      'MCP' => { goals: 3, connected: true },
      'ZPB' => { goals: 3, connected: true },
      'FdSB' => { goals: 3, connected: true },
      'FdLR' => { goals: 2, connected: true },
      'SFVA' => { goals: 3, connected: true },
      'FdC' => { goals: 3, connected: true },
      'GSSR' => { goals: 3, connected: true },
      'AVT' => { goals: 0, connected: true },
      'TBF' => { goals: 0, connected: true },
    }.each do |sym, expected|
      it "#{sym} ends with goals_reached_counter=#{expected[:goals]} and destination_connected=#{expected[:connected]}" do
        corp = game.corporation_by_id(sym)
        expect(corp.goals_reached_counter).to eq(expected[:goals])
        expect(corp.destination_connected?).to eq(expected[:connected])
      end
    end
  end

  describe '18ESP_unreached_destination_phase_8' do
    # The graph walk can only report hexes with paths, so these cases are answerable without it.
    describe 'destination connection short-circuits' do
      # Phase 3: the minors still exist and three destinations have no track laid on them yet.
      let(:game) { fixture_at_action(600) }

      # What the check did before the short circuit was added.
      def by_graph(corp)
        return false unless corp&.corporation?
        return true if corp.destination_connected?

        Engine::Graph.new(game, no_blocking: true).reachable_hexes(corp).include?(game.hex_by_id(corp.destination))
      end

      it 'answers false for a corporation without a destination, without walking' do
        minor = game.corporations.find { |c| !c.destination }
        expect(minor).not_to be_nil
        # Arm after the load, and on reachable_hexes: the graph itself is built once, inside that load.
        expect_any_instance_of(Engine::Graph).not_to receive(:reachable_hexes)
        expect(game.check_for_destination_connection(minor)).to be(false)
      end

      it 'answers false without walking while the destination has no track' do
        corp = game.corporations.find do |c|
          c.destination && !c.destination_connected? && game.hex_by_id(c.destination).tile.paths.empty?
        end
        expect(corp).not_to be_nil
        expect_any_instance_of(Engine::Graph).not_to receive(:reachable_hexes)
        expect(game.check_for_destination_connection(corp)).to be(false)
      end

      # Equivalence with the body this replaced; walked counts the corporations that still reach the graph.
      it 'agrees with the graph walk for every corporation' do
        walked = 0
        game.corporations.each do |corp|
          destination = corp.destination && game.hex_by_id(corp.destination)
          walked += 1 if destination && !destination.tile.paths.empty? && !corp.destination_connected?
          expect(game.check_for_destination_connection(corp)).to eq(by_graph(corp)), corp.id
        end
        expect(walked).to be_positive
      end
    end

    describe 'the last playable action, GSSR still short of its destination' do
      let(:game) { fixture_at_action(1072) }

      it 'answers without walking, with no track on the destination hex' do
        gssr = game.corporation_by_id('GSSR')
        expect(game.hex_by_id(gssr.destination).tile.paths).to be_empty
        expect_any_instance_of(Engine::Graph).not_to receive(:reachable_hexes)
        expect(game.check_for_destination_connection(gssr)).to be(false)
      end
    end
  end
end
