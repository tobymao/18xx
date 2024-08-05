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
          units[2] = true if optional_rules.include?(:unit_2)
          units[3] = true if optional_rules.include?(:unit_3)

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
          units[2] = true if optional_rules.include?(:unit_2)
          units[3] = true if optional_rules.include?(:unit_3)
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

