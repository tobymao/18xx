# frozen_string_literal: true

require_relative 'g_1846'
require_relative '../config/game/g_1846'
require_relative '../config/game/g_18_los_angeles'

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

      GROUP_ONE = [
        'Beverly Hills Carriage',
        'South Bay Line',
      ].freeze

      GROUP_TWO = [
        'Chino Hills Excavation',
        'Los Angeles Citrus',
        'Los Angeles Steamship',
      ].freeze

      CORPORATIONS_GROUP = [
        'Los Angeles Railway',
        'Santa Fe Railroad',
        'Southern Pacific Railroad',
      ].freeze

      def self.title
        '18 Los Angeles'
      end

      # meat packing == citrus
      def meat_packing
        @meat_packing ||= company_by_id('LAC')
      end

      def steamboat
        @steamboat ||= company_by_id('LAS')
      end

      def block_for_steamboat?
        false
      end

      # unlike in 1846, none of the private companies get 2 tile lays
      def check_special_tile_lay(_action); end
    end
  end
end
