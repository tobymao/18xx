# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1825
      module Meta
        include Game::Meta

        DEV_STAGE = :beta

        GAME_DESIGNER = 'Francis Tresham'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1825'
        GAME_LOCATION = 'United Kingdom'
        GAME_RULES_URL = 'https://github.com/tobymao/18xx/wiki/1825_Rules'

        PLAYER_RANGE = [2, 9].freeze
        OPTIONAL_RULES = [
          {
            sym: :unit_1,
            short_name: 'Unit 1',
            desc: '2-5 players',
            players: [2, 3, 4, 5],
          },
          {
            sym: :unit_2,
            short_name: 'Unit 2',
            desc: '2-3 players',
            players: [2, 3],
          },
          {
            sym: :unit_3,
            short_name: 'Unit 3',
            desc: '2 players',
            players: [2],
          },
          {
            sym: :unit_12,
            short_name: 'Units 1+2',
            desc: '3-7 players',
            players: [3, 4, 5, 6, 7],
          },
          {
            sym: :unit_23,
            short_name: 'Units 2+3',
            desc: '3-5 players',
            players: [3, 4, 5],
          },
          {
            sym: :unit_123,
            short_name: 'Units 1+2+3',
            desc: '4-8 players (4-9 with regionals)',
            players: [4, 5, 6, 7, 8, 9],
          },
          {
            sym: :unit_4,
            short_name: 'Unit 4',
            desc: 'Unpublished Unit 4 map for the north of Scotland',
          },
          {
            sym: :r1,
            short_name: 'R1',
            desc: 'Regional Kit 1 - Wales',
          },
          {
            sym: :r2,
            short_name: 'R2',
            desc: 'Regional Kit 2 - South West England',
          },
          {
            sym: :r3,
            short_name: 'R3',
            desc: 'Regional Kit 3 - North Norfolk',
          },
          {
            sym: :k1,
            short_name: 'K1',
            desc: 'Extension Kit 1 - Supplementary Tiles',
          },
          {
            sym: :k2,
            short_name: 'K2',
            desc: 'Extension Kit 2 - Advanced Trains',
          },
          {
            sym: :k3,
            short_name: 'K3',
            desc: 'Extension Kit 3 - Phase Four',
          },
          {
            sym: :k5,
            short_name: 'K5',
            desc: 'Extension Kit 5 - Minors for Unit 2',
          },
          {
            sym: :k6,
            short_name: 'K6',
            desc: 'Extension Kit 6 - Advanced Tiles',
          },
          {
            sym: :k7,
            short_name: 'K7',
            desc: 'Extension Kit 7 - London, Tilbury and Southend Railway',
          },
          {
            sym: :d1,
            short_name: 'D1',
            desc: 'Development Kit 1 - Additional Tiles',
          },
          {
            sym: :u3p,
            short_name: 'U3+',
            desc: 'Include 2 addtional 3T and U3 trains with Unit 3',
          },
          {
            sym: :big_bank,
            short_name: 'BigBank',
            desc: 'When combining units, add banks from each unit',
          },
          {
            sym: :strict_bank,
            short_name: 'StrictBank',
            desc: 'Do not increase bank size based on number of minors and kits',
          },
          {
            sym: :db1,
            short_name: 'DB1',
            desc: 'Dave Berry variant 1: allow double-dits to upgrade to 887/888',
          },
          {
            sym: :db2,
            short_name: 'DB2',
            desc: 'Dave Berry variant 2: SECR Changes for Unit 1',
          },
          {
            sym: :db3,
            short_name: 'DB3',
            desc: 'Dave Berry variant 3: Unit 3 map revision',
          },
        ].freeze

        MUTEX_RULES = [
          %i[unit_1 unit_2 unit_3 unit_12 unit_23 unit_123],
          %i[big_bank strict_bank],
        ].freeze

        def self.check_options(options, _min_players, max_players)
          optional_rules = (options || []).map(&:to_sym)

          return if optional_rules.empty? && !max_players

          if optional_rules.empty?
            case max_players
            when 2
              return { info: 'No Unit(s) selected. Will use Unit 3 based on player count' }
            when 3
              return { info: 'No Unit(s) selected. Will use Unit 2 based on player count' }
            when 4, 5
              return { info: 'No Unit(s) selected. Will use Unit 1 based on player count' }
            when 6, 7
              return { info: 'No Unit(s) selected. Will use Units 1+2 based on player count' }
            when 8
              return { info: 'No Unit(s) selected. Will use Units 1+2+3 based on player count' }
            else
              return { info: 'No Unit(s) selected. Will use Units 1+2+3 and R1+R2+R3 based on player count' }
            end
          end

          units = {}
          kits = {}
          regionals = {}
          units4 = false

          units[1] = true if optional_rules.include?(:unit_1)
          units[1] = true if optional_rules.include?(:unit_12)
          units[1] = true if optional_rules.include?(:unit_123)

          units[2] = true if optional_rules.include?(:unit_2)
          units[2] = true if optional_rules.include?(:unit_12)
          units[2] = true if optional_rules.include?(:unit_23)
          units[2] = true if optional_rules.include?(:unit_123)

          units[3] = true if optional_rules.include?(:unit_3)
          units[3] = true if optional_rules.include?(:unit_23)
          units[3] = true if optional_rules.include?(:unit_123)

          units4 = true if optional_rules.include?(:unit_4)

          kits[1] = true if optional_rules.include?(:k1)
          kits[2] = true if optional_rules.include?(:k2)
          kits[3] = true if optional_rules.include?(:k3)
          kits[5] = true if optional_rules.include?(:k5)
          kits[6] = true if optional_rules.include?(:k6)
          kits[7] = true if optional_rules.include?(:k7)

          regionals[1] = true if optional_rules.include?(:r1)
          regionals[2] = true if optional_rules.include?(:r2)
          regionals[3] = true if optional_rules.include?(:r3)

          if !units[1] && !units[2] && !units[3] && !optional_rules.empty?
            return { error: 'Must select at least one Unit if using other options' }
          end
          return { error: 'Cannot combine Units 1 and 3 without Unit 2' } if units[1] && !units[2] && units[3]
          return { error: 'Cannot add Regionals without Unit 1' } if !regionals.keys.empty? && !units[1]
          return { error: 'Cannot add K5 without Unit 2' } if kits[5] && !units[2]
          return { error: 'Cannot add K7 without Unit 1' } if kits[7] && !units[1]
          return { error: 'K2 not supported with just Unit 3' } if kits[2] && !units[1] && !units[2] && units[3]
          return { error: 'K2 not supported without K3' } if kits[2] && !kits[3]
          return { error: 'Cannot use extra Unit 3 trains without Unit 3' } if !units[3] && optional_rules.include?(:u3p)
          return { error: 'Cannot use K1 or K6 with D1' } if (kits[1] || kits[6]) && optional_rules.include?(:d1)
          if optional_rules.include?(:big_bank) && optional_rules.include?(:strict_bank)
            return { error: 'Cannot use both bank options' }
          end
          if !units[1] && !units[3] && optional_rules.include?(:db1)
            return { error: 'Variant DB1 not useful in a Unit 2 only game' }
          end
          return { error: 'Variant DB2 is for Unit 1' } if !units[1] && optional_rules.include?(:db2)
          return { error: 'Variant DB3 is for Unit 3' } if !units[3] && optional_rules.include?(:db3)
          return { error: 'Unit 4 requires Unit 3' } if units4 && !units[3]

          nil
        end

        def self.min_players(optional_rules, num_players)
          optional_rules = (optional_rules || []).map(&:to_sym)

          if optional_rules.empty?
            return unless num_players

            case num_players
            when 2, 3, 4, 5
              return 2
            when 6, 7
              return 3
            else
              return 4
            end
          end

          units = {}

          units[1] = true if optional_rules.include?(:unit_1)
          units[1] = true if optional_rules.include?(:unit_12)
          units[1] = true if optional_rules.include?(:unit_123)

          units[2] = true if optional_rules.include?(:unit_2)
          units[2] = true if optional_rules.include?(:unit_12)
          units[2] = true if optional_rules.include?(:unit_23)
          units[2] = true if optional_rules.include?(:unit_123)

          units[3] = true if optional_rules.include?(:unit_3)
          units[3] = true if optional_rules.include?(:unit_23)
          units[3] = true if optional_rules.include?(:unit_123)

          case units.keys.sort.map(&:to_s).join
          when '1', '2', '3'
            2
          when '12', '23'
            3
          else # all units
            4
          end
        end
      end
    end
  end
end
