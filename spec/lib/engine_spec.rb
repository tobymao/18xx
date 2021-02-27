# frozen_string_literal: true

require './spec/spec_helper'

describe Engine do
  context 'create games with game_by_title' do
    {
      '1889' => (2..6),
      '18Chesapeake' => (3..6),
    }.each do |game_title, player_counts|
      player_counts.each do |count|
        it "creates a new game of #{game_title} with #{count} players" do
          players = (1..count).map(&:to_s)
          game = Engine.game_by_title(game_title).new(players)

          # the expectation here isn't very important, the main purpose of these
          # tests are for the previous line to execute without failing
          expect(game.tiles.size).to be > 0
        end
      end
    end
  end
end
