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

module Engine
  module Game
    {
      G1817 => ['1817'],
      G1822 => ['1822'],
      G1830 => %w[1830 Robber],
      G1846 => %w[1846 46],
      G1846TwoPlayerVariant => ['1846 2p Variant'],
      G1849 => ['1849', 'Sicilian Railways'],
      G1849Boot => ['1849Boot', '1849K2S', 'Two Sicilies'],
      G1860 => %w[1860 Wight],
      G1873 => ['Harzbahn 1873', '1873', '73'],
      G1889 => ['1889', 'Shikoku', 'Shikoku 1889', 'History of Shikoku Railways'],
      G18Chesapeake => %w[18Chesapeake Chessie],
      G18ChesapeakeOffTheRails => ['ChesapeakeOTR', 'OTR', '18Chesapeake: Off the Rails'],
      G18LosAngeles1 => ['18 Los Angeles', '18LA1'],
      G18LosAngeles => ['18 Los Angeles 2', '18LA', '18LA2'],
    }.each do |game_module, fuzzy_titles|
      expected_title = game_module.const_get('Meta').title

      describe 'closest_title' do
        fuzzy_titles.each do |fuzzy|
          it "matches '#{fuzzy}' to '#{expected_title}'" do
            expect(Engine.closest_title(fuzzy)).to eq(expected_title)
          end
        end
      end
    end
  end
end
