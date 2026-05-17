# frozen_string_literal: true

require 'spec_helper'

# Frozen snapshot of the destination goal mechanism after a full fixture replay.
# Any deviation signals that a refactor step (Issue #12579) changed the behaviour,
# intentionally or not.
#
# Values captured with Engine::Game.load(data, strict: false) at commit bc6657312.
# AVT and TBF reach their destination not via goal_reached!(:destination) but through
# the full-cap mechanism (game.rb ~line 589), hence goals=0.

describe Engine::Game::G18ESP::Game do
  describe '18ESP_game_end_second_eight' do
    subject(:game) do
      data = JSON.parse(File.read("#{FIXTURES_DIR}/18ESP/18ESP_game_end_second_eight.json"))
      Engine::Game.load(data, strict: false).tap(&:maybe_raise!)
    end

    it 'replays without exceptions' do
      expect(game.exception).to be_nil
    end

    it 'logs the destination goal exactly 8 times' do
      count = game.log.to_a.count { |e| e.message.include?('reached destination goal') }
      expect(count).to eq(8)
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
