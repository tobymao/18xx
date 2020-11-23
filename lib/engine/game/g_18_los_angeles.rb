# frozen_string_literal: true

require_relative 'g_1846'
require_relative '../config/game/g_1846'
require_relative '../config/game/g_18_los_angeles'
require_relative '../step/g_18_los_angeles/draft_distribution'
require_relative '../step/g_18_los_angeles/special_token'

module Engine
  module Game
    class G18LosAngeles < G1846
      register_colors(red: '#ff0000',
                      pink: '#ff7fed',
                      orange: '#ff6a00',
                      green: '#00830e',
                      blue: '#0026ff',
                      black: '#727272',
                      lightBlue: '#b8ffff',
                      brown: '#644c00',
                      purple: '#832e9a')

      load_from_json(Config::Game::G18LosAngeles::JSON, Config::Game::G1846::JSON)

      DEV_STAGE = :production

      GAME_LOCATION = nil
      GAME_RULES_URL = {
        '18 Los Angeles Rules' => 'https://drive.google.com/file/d/1I1G0ly8EpQyJ9hPCqItb2pZPERunKhwh/view',
        '1846 Rules' => 'https://s3-us-west-2.amazonaws.com/gmtwebsiteassets/1846/1846-RULES-GMT.pdf',
      }.freeze
      GAME_DESIGNER = 'Anthony Fryer'
      GAME_PUBLISHER = %i[traxx sea_horse].freeze
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18LosAngeles'

      OPTIONAL_RULES = [
        {
          sym: :dch,
          short_name: 'Dewey, Cheatham, and Howe',
          desc: 'add a private company which allows the owning corporation to '\
                'place a token in a city that has no open slots; 3+ players only',
          players: [3, 4, 5],
        },
        {
          sym: :la_title,
          short_name: 'LA Title',
          desc: 'add a private company which can lay an Open City token; 3+ players only',
          players: [3, 4, 5],
        },
      ].freeze

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

      REMOVED_CORP_SECOND_TOKEN = {
        'LA' => 'B9',
        'SF' => 'C8',
        'SP' => 'C6',
      }.freeze

      LSL_HEXES = %w[E4 E6].freeze
      LSL_ICON = 'sbl'

      MEAT_HEXES = %w[C14 F7].freeze
      STEAMBOAT_HEXES = %w[B1 C2 F7 F9].freeze

      MEAT_REVENUE_DESC = 'Citrus'

      def self.title
        '18 Los Angeles'
      end

      def setup_turn
        1
      end

      def init_companies(_players)
        companies = super
        companies.reject! { |c| c.sym == 'DC&H' } unless @optional_rules.include?(:dch)
        companies.reject! { |c| c.sym == 'LAT' } unless @optional_rules.include?(:la_title)
        companies
      end

      def init_hexes(_companies, _corporations)
        hexes = super

        hexes.each do |hex|
          hex.ignore_for_axes = true if %w[a9 G14].include?(hex.id)
        end

        hexes
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

      def place_second_token(corporation, **_kwargs)
        super(corporation, two_player_only: false, cheater: false)
      end

      def init_round
        Round::Draft.new(self,
                         [Step::G18LosAngeles::DraftDistribution],
                         snake_order: true)
      end

      def init_round_finished
        @minors.reject(&:owned_by_player?).each { |m| close_corporation(m) }
        @companies.reject(&:owned_by_player?).sort_by(&:name).each do |company|
          company.close!
          @log << "#{company.name} is removed" unless company.value >= 100
        end
        @draft_finished = true
      end

      def operating_round(round_num)
        Round::G1846::Operating.new(self, [
          Step::G1846::Bankrupt,
          Step::DiscardTrain,
          Step::G1846::Assign,
          Step::G18LosAngeles::SpecialToken,
          Step::SpecialTrack,
          Step::G1846::BuyCompany,
          Step::G1846::IssueShares,
          Step::G1846::TrackAndToken,
          Step::Route,
          Step::G1846::Dividend,
          Step::G1846::BuyTrain,
          [Step::G1846::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def num_pass_companies(_players)
        0
      end

      def priority_deal_player
        players = @players.reject(&:bankrupt)
        case @round
        when Round::Draft, Round::Operating
          players.min_by { |p| [p.cash, players.index(p)] }
        when Round::Stock
          players.first
        end
      end

      def reorder_players
        current_order = @players.dup
        @players.sort_by! { |p| [p.cash, current_order.index(p)] }
        @log << "Priority order: #{@players.reject(&:bankrupt).map(&:name).join(', ')}"
      end

      def new_stock_round
        @log << "-- #{round_description('Stock')} --"
        reorder_players
        stock_round
      end

      def meat_packing
        @meat_packing ||= company_by_id('LAC')
      end

      def steamboat
        @steamboat ||= company_by_id('LAS')
      end

      def lake_shore_line
        @lake_shore_line ||= company_by_id('SBL')
      end

      def dch
        @dch ||= company_by_id('DC&H')
      end

      def block_for_steamboat?
        false
      end

      def tile_lays(entity)
        entity.minor? ? [{ lay: true, upgrade: true }] : super
      end

      # unlike in 1846, none of the private companies get 2 tile lays
      def check_special_tile_lay(_action); end

      def legal_tile_rotation?(_entity, hex, tile)
        hex.tile.stubs.empty? || tile.exits.include?(hex.tile.stubs.first.edge)
      end

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

      def compute_other_paths(routes, route)
        routes
          .reject { |r| r == route }
          .select { |r| train_type(route.train) == train_type(r.train) }
          .flat_map(&:paths)
      end

      def train_type(train)
        train.name.include?('/') ? :freight : :passenger
      end

      def check_overlap(routes)
        tracks_by_type = Hash.new { |h, k| h[k] = [] }

        routes.each do |route|
          route.paths.each do |path|
            a = path.a
            b = path.b

            tracks = tracks_by_type[train_type(route.train)]
            tracks << [path.hex, a.num, path.lanes[0][1]] if a.edge?
            tracks << [path.hex, b.num, path.lanes[1][1]] if b.edge?
          end
        end

        tracks_by_type.each do |_type, tracks|
          tracks.group_by(&:itself).each do |k, v|
            @game.game_error("Route cannot reuse track on #{k[0].id}") if v.size > 1
          end
        end
      end

      def next_round!
        @round =
          case @round
          when Round::Stock
            @operating_rounds = @phase.operating_rounds
            new_operating_round
          when Round::Operating
            if @round.round_num < @operating_rounds
              or_round_finished
              new_operating_round(@round.round_num + 1)
            else
              @turn += 1
              or_round_finished
              or_set_finished
              new_stock_round
            end
          when init_round.class
            init_round_finished
            new_stock_round
          end
      end

      def train_help(runnable_trains)
        trains = runnable_trains.group_by { |t| train_type(t) }

        help = []

        if trains.keys.size > 1
          passenger_trains = trains[:passenger].map(&:name).uniq.sort.join(', ')
          freight_trains = trains[:freight].map(&:name).uniq.sort.join(', ')
          help << "The routes of N trains (#{passenger_trains}) may overlap "\
                  "with the routes of N/M trains (#{freight_trains})."
        end

        super + help
      end

      def east_west_desc
        'E/W or N/S'
      end
    end
  end
end
