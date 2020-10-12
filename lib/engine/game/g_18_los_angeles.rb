# frozen_string_literal: true

require_relative 'g_1846'
require_relative '../config/game/g_1846'
require_relative '../config/game/g_18_los_angeles'
require_relative '../step/g_18_los_angeles/draft_distribution'

module Engine
  module Game
    class G18LosAngeles < G1846
      load_from_json(Config::Game::G18LosAngeles::JSON, Config::Game::G1846::JSON)

      DEV_STAGE = :prealpha

      GAME_LOCATION = nil
      GAME_RULES_URL = {
        '18 Los Angeles Rules' => 'https://drive.google.com/file/d/1G_fLbak96VWQ0Vfvg7-Qh2gXgv7r0BQi/view?usp=sharing',
        '1846 Rules' => 'https://s3-us-west-2.amazonaws.com/gmtwebsiteassets/1846/1846-RULES-GMT.pdf',
      }.freeze
      GAME_DESIGNER = 'Anthony Fryer'
      GAME_PUBLISHER = Publisher::INFO[:traxx]
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18LosAngeles'

      ASSIGNMENT_TOKENS = {
        'LAC' => '/icons/18_los_angeles/lac_token.svg',
        'LAS' => '/icons/1846/sc_token.svg',
      }.freeze

      ORANGE_GROUP = [
        'Beverly Hills Carriage',
        'South Bay Line',
      ].freeze

      BLUE_GROUP = [
        'Chino Hills Excavation',
        'Los Angeles Citrus',
        'Los Angeles Steamship',
      ].freeze

      GREEN_GROUP = %w[LA SF SP].freeze

      LSL_HEXES = %w[E4 E6].freeze
      LSL_ICON = 'lsl'

      MEAT_HEXES = %w[C14 F7].freeze
      STEAMBOAT_HEXES = %w[B1 C2 F7 F9].freeze

      def self.title
        '18 Los Angeles'
      end

      def num_removals(group)
        return 0 if @players.size == 5
        return 1 if @players.size == 4

        case group
        when ORANGE_GROUP, BLUE_GROUP
          1
        when GREEN_GROUP
          2
        end
      end

      def corporation_removal_groups
        [GREEN_GROUP]
      end

      def place_second_token(corporation)
        hex = case corporation.id
              when 'LA'
                'B9'
              when 'SF'
                'C8'
              when 'SP'
                'C6'
              end
        return unless hex

        token = corporation.find_token_by_type
        hex_by_id(hex).tile.cities.first.place_token(corporation, token, check_tokenable: false)
        @log << "#{corporation.id} places a token on #{hex}"
      end

      def check_removed_corp_second_token(_hex, _tile); end

      def init_round
        Round::Draft.new(self, [Step::G18LosAngeles::DraftDistribution])
      end

      def init_round_finished
        @minors.reject(&:owned_by_player?).each { |m| close_corporation(m) }
        @companies.reject(&:owned_by_player?).each(&:close!)
        @draft_finished = true
      end

      def num_pass_companies(_players)
        0
      end

      # meat packing == citrus
      def meat_packing
        @meat_packing ||= company_by_id('LAC')
      end

      def steamboat
        @steamboat ||= company_by_id('LAS')
      end

      def lake_shore_line
        @lake_shore_line ||= company_by_id('SBL')
      end

      def block_for_steamboat?
        false
      end

      # unlike in 1846, none of the private companies get 2 tile lays
      def check_special_tile_lay(_action); end

      def east_west_bonus(stops)
        bonus = { revenue: 0 }

        east = stops.find { |stop| stop.tile.label&.to_s =~ /E/ }
        west = stops.find { |stop| stop.tile.label&.to_s =~ /W/ }
        north = stops.find { |stop| stop.tile.label&.to_s =~ /N/ }
        south = stops.find { |stop| stop.tile.label&.to_s =~ /S/ }
        if east && west
          bonus[:revenue] += east.tile.icons.sum { |icon| icon.name.to_i }
          bonus[:revenue] += west.tile.icons.sum { |icon| icon.name.to_i }
          bonus[:description] = 'E/W'
        elsif north && south
          bonus[:revenue] += north.tile.icons.sum { |icon| icon.name.to_i }
          bonus[:revenue] += south.tile.icons.sum { |icon| icon.name.to_i }
          bonus[:description] = 'N/S'
        end

        bonus
      end
    end
  end
end
