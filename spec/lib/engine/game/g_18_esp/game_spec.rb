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
    # 1334 = total action count for this fixture; loads the complete game.
    let(:game) { fixture_at_action(1334) }

    describe '#replaying?' do
      it 'is true when game is loading (normal replay)' do
        g = fixture_at_action(1, clear_cache: true)
        g.instance_variable_set(:@loading, true)
        expect(g.replaying?).to be true
      end

      it 'is true when game is in strict mode (validate_auto_actions)' do
        # fixture_at_action loads with strict: true, so @strict is already true.
        g = fixture_at_action(1)
        expect(g.loading).to be false
        expect(g.replaying?).to be true
      end

      it 'is false during live play' do
        g = fixture_at_action(1, clear_cache: true)
        g.instance_variable_set(:@strict, false)
        expect(g.loading).to be false
        expect(g.replaying?).to be false
      end
    end

    describe 'legacy_destination_format? detection' do
      it 'is true for a pre-#12579 save (no destination_connection actions in log)' do
        expect(game.legacy_destination_format?).to be true
      end

      it 'is false when @filtered_actions contains a destination_connection sub-action' do
        # Synthetic sub-action injection requires direct @filtered_actions manipulation;
        # use a fresh instance (clear_cache: true) to avoid polluting the fixture cache.
        g = fixture_at_action(1, clear_cache: true)
        g.instance_variable_set(:@filtered_actions, [
          {
            'type' => 'lay_tile',
            'auto_actions' => [{ 'type' => 'destination_connection' }],
          },
        ])
        g.instance_variable_set(:@legacy_destination_format, nil)
        expect(g.legacy_destination_format?).to be false
      end
    end

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
end
