# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18TS
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'Matthew Martin'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1825'
        GAME_LOCATION = 'NE USA'
        GAME_RULES_URL = 'https://github.com/tobymao/18xx/wiki/1825_Rules'

        PLAYER_RANGE = [3, 9].freeze
        OPTIONAL_RULES = [
          {
            sym: :unit_1,
            short_name: 'East Scenario',
            players: [3, 4, 5, 6, 7],
          },
          {
            sym: :unit_2,
            short_name: 'West Scenario',
            players: [3, 4, 5],
          },
          {
            sym: :unit_3,
            short_name: 'Full Scenario',
            players: [4, 5, 6, 7, 8, 9],
        }
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
            when 3, 4
              return { info: 'No scenario selected. Will use West Scenario based on player count.' }
            when 5
              return { info: 'No scenario selected. Will use East Scenario based on player count.' }
            when 6, 7, 8, 9
              return { info: 'No scenario selected. Will use Full Scenario based on player count' }
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
