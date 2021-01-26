# frozen_string_literal: true

require_relative 'g_1817'
require_relative '../config/game/g_18_usa'

module Engine
  module Game
    class G18USA < G1817
      load_from_json(Config::Game::G18USA::JSON)

      DEV_STAGE = :prealpha
      GAME_PUBLISHER = :all_aboard_games
      PITTSBURGH_PRIVATE_NAME = 'DTC'
      PITTSBURGH_PRIVATE_HEX = 'F14'

      GAME_LOCATION = 'United States'
      SEED_MONEY = 200
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18USA'
      GAME_RULES_URL = {
        '18USA' => 'https://boardgamegeek.com/filepage/145024/18usa-rules',
        '1817 Rules' => 'https://drive.google.com/file/d/0B1SWz2pNe2eAbnI4NVhpQXV4V0k/view',
      }.freeze
      # Alphabetized. Not sure what official ordering is
      GAME_DESIGNER = 'Edward Reece, Mark Hendrickson, and Shawn Fox'

      OFFBOARD_VALUES = [[20, 30, 40, 50], [20, 30, 40, 60], [20, 30, 50, 60], [20, 30, 50, 60], [20, 30, 60, 90],
                         [20, 40, 50, 80], [30, 40, 40, 50], [30, 40, 50, 60], [30, 50, 60, 80], [30, 50, 60, 80],
                         [40, 50, 40, 40]].freeze

      def self.title
        '18USA'
      end

      def optional_hexes
        ofboard = OFFBOARD_VALUES.sort_by { rand }
        plain_hexes = %w[B20 B26 C5 C11 C13 C15 D2 D4 D12 D22 E13 E27 F2 F6 F12 F14 G9 G13 G19 G25 H10 H12 H16
                         H24 H26]
        {
          red: {
            ['A27'] => "offboard=revenue:yellow_#{ofboard[0][0]}|green_#{ofboard[0][1]}"\
            "|brown_#{ofboard[0][2]}|gray_#{ofboard[0][3]};"\
            'path=a:5,b:_0;path=a:0,b:_0',
            ['J20'] => "offboard=revenue:yellow_#{ofboard[1][0]}|green_#{ofboard[1][1]}|brown_#{ofboard[1][2]}"\
            "|gray_#{ofboard[1][3]};path=a:2,b:_0",
            ['I5'] => "offboard=revenue:yellow_#{ofboard[2][0]}|green_#{ofboard[2][1]}|brown_#{ofboard[2][2]}"\
            "|gray_#{ofboard[2][3]},groups:Mexico,hide:1;path=a:2,b:_0;path=a:3,b:_0;border=edge:4",
            %w[I7
               I9] => "offboard=revenue:yellow_#{ofboard[2][0]}|green_#{ofboard[2][1]}|brown_#{ofboard[2][2]}"\
               "|gray_#{ofboard[2][3]},groups:Mexico,hide:1;path=a:2,b:_0;path=a:3,b:_0;border=edge:4;border=edge:1",
            ['I11'] => "offboard=revenue:yellow_#{ofboard[2][0]}|green_#{ofboard[2][1]}|brown_#{ofboard[2][2]}"\
            "|gray_#{ofboard[2][3]},groups:Mexico;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;border=edge:1;"\
            'border=edge:5',
            ['J12'] => "offboard=revenue:yellow_#{ofboard[2][0]}|green_#{ofboard[2][1]}|brown_#{ofboard[2][2]}"\
            "|gray_#{ofboard[2][3]},groups:Mexico,hide:1;path=a:3,b:_0;border=edge:2;border=edge:5",
            ['K13'] => "offboard=revenue:yellow_#{ofboard[2][0]}|green_#{ofboard[2][1]}|brown_#{ofboard[2][2]}"\
            "|gray_#{ofboard[2][3]},groups:Mexico,hide:1;path=a:3,b:_0;border=edge:2",
          },
          white: {
            %w[E11 G3 H14 I15 H20 H22 F26 C29 D24] => 'city=revenue:0',
            %w[D6 E3 E7 G7 G11 H8 I13 I25 G27 E23] => 'city=revenue:0;icon=image:18_ms/coins',
            %w[C17 E15 E17 F20 G17 I19] => 'city=revenue:0;upgrade=cost:10,terrain:water;icon=image:18_usa/bridge',
            %w[C3
               D14] => 'city=revenue:0;upgrade=cost:10,terrain:water;icon=image:18_ms/coins;icon=image:18_usa/bridge',
            %w[B28 C27 F4 G5 G23] => 'upgrade=cost:15,terrain:mountain',
            %w[D18 E21 F18 H18] => 'upgrade=cost:10,terrain:water',
            ['B22'] => 'upgrade=cost:20,terrain:lake',
            %w[C7 E9 G21] => 'upgrade=cost:15,terrain:mountain;icon=image:18_usa/mine',
            %w[D16 E5 H6] => 'icon=image:18_usa/mine',
            %w[G15 H4 I17 I21 I23 J14] => 'icon=image:18_usa/oil-derrick',
            %w[E19 F16] => 'icon=image:18_usa/coalcar',
            %w[C9 D8 D10 D26 E25 F8 F10 F22 F24] => 'upgrade=cost:15,terrain:mountain;icon=image:18_usa/coalcar',
            %w[B16 B18] => 'icon=image:18_usa/gnr',
            ['C19'] => 'icon=image:18_usa/gnr;icon=image:18_usa/mine',
            ['B10'] => 'icon=image:18_usa/gnr;icon=image:18_usa/coalcar;icon=image:18_usa/mine',
            ['B12'] => 'icon=image:18_usa/gnr;icon=image:18_usa/coalcar;icon=image:18_usa/oil-derrick',
            ['D20'] => 'icon=image:18_usa/gnr;city=revenue:0',
            %w[B8 B14] => 'icon=image:18_usa/gnr;city=revenue:0;icon=image:18_ms/coins',
            ['B6'] => 'icon=image:18_usa/gnr;upgrade=cost:15,terrain:mountain;icon=image:18_usa/coalcar',
            ['B4'] => 'icon=image:18_usa/gnr;upgrade=cost:10,terrain:water',
            plain_hexes => '',
          },
          gray: {
            ['A15'] => "town=revenue:yellow_#{ofboard[3][0]}|green_#{ofboard[3][1]}|brown_#{ofboard[3][2]}"\
            "|gray_#{ofboard[3][3]};path=a:0,b:_0;path=a:5,b:_0",
            ['B2'] => "town=revenue:yellow_#{ofboard[4][0]}|green_#{ofboard[4][1]}|brown_#{ofboard[4][2]}"\
            "|gray_#{ofboard[4][3]};path=a:4,b:_0;path=a:5,b:_0",
            ['J24'] => "town=revenue:yellow_#{ofboard[5][0]}|green_#{ofboard[5][1]}|brown_#{ofboard[5][2]}"\
            "|gray_#{ofboard[5][3]};path=a:2,b:_0;path=a:3,b:_0",
            ['E1'] => "town=revenue:yellow_#{ofboard[6][0]}|green_#{ofboard[6][1]}|brown_#{ofboard[6][2]}"\
            "|gray_#{ofboard[6][3]};path=a:4,b:_0;path=a:5,b:_0;path=a:3,b:_0",
            ['B30'] => 'path=a:1,b:0',
            ['C23'] => 'town=revenue:yellow_30|green_40|brown_50|gray_60;path=a:4,b:_0;path=a:2,b:_0;path=a:0,b:_0',
            ['C25'] => 'town=revenue:yellow_20|green_30|brown_40|gray_50;path=a:1,b:_0;path=a:5,b:_0;path=a:3,b:_0',
          },
          yellow: {
            ['D28'] => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:1,b:_1;path=a:3,b:_0;label=NY',
          },
          blue: {
            %w[B24 C21] => '',
          },
        }
      end
    end
  end
end
