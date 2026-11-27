# frozen_string_literal: true

require 'spec_helper'

module Engine
  describe Game::GSystem18::Game do
    # Each map customizes the game by redefining constants on the shared
    # GSystem18::Game class, so #setup must reset every constant a map changes.
    # Otherwise a map's value leaks into the next System18 game set up in the
    # same process (e.g. Russia's HOME_TOKEN_TIMING = :par broke UK Limited).
    describe 'map constants' do
      maps = Game::GSystem18::Meta::OPTIONAL_RULES.select { |r| r[:sym].to_s.start_with?('map_') }

      def new_game(rule)
        players = rule[:players].first
        Game::GSystem18::Game.new(Array.new(players) { |i| "Player #{i + 1}" }, optional_rules: [rule[:sym]])
      end

      def constant_values
        Game::GSystem18::Game.constants(false).to_h { |c| [c, Game::GSystem18::Game.const_get(c)] }
      end

      it 'are not carried over from one game to the next' do
        uk_limited = maps.find { |r| r[:sym] == :map_UK_Limited }
        new_game(uk_limited)
        expected = constant_values

        maps.each do |map|
          new_game(map)
          new_game(uk_limited)
          expect(constant_values).to eq(expected), "constants differ after setting up a #{map[:sym]} game"
        end
      end
    end
  end
end
