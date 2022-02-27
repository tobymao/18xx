# frozen_string_literal: true

require_relative '../g_1846/game'
require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'step/draft_distribution'
require_relative 'step/special_token'
require_relative '../stubs_are_restricted'

module Engine
  module Game
    module G18LosAngeles
      class Game < G1846::Game
        include_meta(G18LosAngeles::Meta)
        include Entities
        include Map
        include StubsAreRestricted

        register_colors(red: '#ff0000',
                        pink: '#ff7fed',
                        orange: '#ff6a00',
                        green: '#00830e',
                        blue: '#0026ff',
                        black: '#727272',
                        lightBlue: '#b8ffff',
                        brown: '#644c00',
                        purple: '#832e9a')

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

        ABILITY_ICONS = {
          SBL: 'sbl',
          LAC: 'meat',
          LAS: 'port',
        }.freeze

        LSL_HEXES = %w[E4 E6].freeze
        LSL_ICON = 'sbl'
        LSL_ID = 'SBL'

        LITTLE_MIAMI_HEXES = [].freeze

        MEAT_HEXES = %w[C14 F7].freeze
        STEAMBOAT_HEXES = %w[B1 C2 F7 F9].freeze
        BOOMTOWN_HEXES = [].freeze

        MEAT_REVENUE_DESC = 'Citrus'

        EVENTS_TEXT = G1846::Game::EVENTS_TEXT.merge(
          'remove_markers' => ['Remove Markers', 'Remove LA Steamship and LA Citrus markers']
        ).freeze

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
            hex.ignore_for_axes = true if %w[a5 a9 G14].include?(hex.id)
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
          super(corporation, two_player_only: false, deferred: false)
        end

        def init_round
          Round::Draft.new(self,
                           [G18LosAngeles::Step::DraftDistribution],
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
          @round_num = round_num
          G1846::Round::Operating.new(self, [
            G1846::Step::Bankrupt,
            Engine::Step::Assign,
            G18LosAngeles::Step::SpecialToken,
            G1846::Step::SpecialTrack,
            G1846::Step::BuyCompany,
            G1846::Step::IssueShares,
            G1846::Step::TrackAndToken,
            Engine::Step::Route,
            G1846::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1846::Step::BuyTrain,
            [G1846::Step::BuyCompany, { blocks: true }],
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

        def east_west_bonus(stops)
          bonus = { revenue: 0 }

          east = stops.find { |stop| stop.tile.label.to_s.include?('E') }
          west = stops.find { |stop| stop.tile.label.to_s.include?('W') }
          north = stops.find { |stop| stop.tile.label.to_s.include?('N') }
          south = stops.find { |stop| stop.tile.label.to_s.include?('S') }
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
              raise GameError, "Route cannot reuse track on #{k[0].id}" if v.size > 1
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

        def train_help(_entity, runnable_trains, _routes)
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
end
