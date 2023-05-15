# frozen_string_literal: true

require_relative '../g_1846/game'
require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'step/buy_sell_par_shares'
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

        attr_reader :drafted_companies, :parred_corporations
        attr_accessor :dump_token, :rj_token, :use_che_discount

        ASSIGNMENT_TOKENS = {
          'LAC' => '/icons/18_los_angeles/lac_token.svg',
          'LAS' => '/icons/1846/sc_token.svg',
          'RKO' => '/icons/18_los_angeles/bt_token.svg',
        }.freeze

        CORPORATIONS_GROUP = %w[
          ELA
          LA
          LAIR
          PER
          SF
          SP
          UP
        ].freeze

        REMOVED_CORP_SECOND_TOKEN = {
          'ELA' => 'C4',
          'LA' => 'B9',
          'LAIR' => 'E6',
          'SF' => 'D11',
          'SP' => 'C6',
          'UP' => 'B13',
        }.freeze

        HOME_TOKEN_TIMING = :par

        PER_HEXES = %w[
          A4 A6
          B5 B13
          C8
          D7 D9 D11 D13
          E4 E6
          F9 F11 F13
        ].freeze

        ABILITY_ICONS = {
          LAC: 'meat',
          LAS: 'port',
          RKO: 'boom',
        }.freeze

        LITTLE_MIAMI_HEXES = [].freeze

        MEAT_HEXES = %w[C14 F7].freeze
        STEAMBOAT_HEXES = %w[B1 C2 F7 F9].freeze
        BOOMTOWN_HEXES = %w[B5].freeze

        MEAT_REVENUE_DESC = 'Citrus'
        BOOMTOWN_REVENUE_DESC = 'RKO'

        EVENTS_TEXT = G1846::Game::EVENTS_TEXT.merge(
          'remove_markers' => ['Remove Tokens & Markers', 'Remove RJ token and LA Steamship, LA Citrus, and RKO Pictures markers']
        ).freeze

        CORPORATION_START_LIMIT = {
          2 => 5,
          3 => 5,
          4 => 6,
          5 => 7,
        }.freeze

        COMPANY_DRAFT_LIMIT = {
          2 => 8,
          3 => 9,
          4 => 10,
          5 => 11,
        }.freeze

        CHE_DISCOUNT = 20

        DUMP_PENALTY = 20
        DUMP_PENALTY_WESTMINSTER = 10
        WESTMINSTER_HEX = 'F9'

        def setup
          super

          %w[a5 a9 G14].each do |id|
            hex_by_id(id)&.ignore_for_axes = true
          end

          post_setup
        end

        def post_setup
          @parred_corporations = 0
          @drafted_companies = 0
          @corporations.each do |corporation|
            place_home_token(corporation) unless corporation.id == 'PER'
          end
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

        def num_removals(_group)
          two_player? ? 2 : 0
        end

        def corporation_removal_groups
          two_player? ? [CORPORATIONS_GROUP] : []
        end

        def place_second_token_kwargs(_corporation)
          { two_player_only: true, deferred: false }
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

        def after_par(corporation)
          super
          after_par_check_limit!
        end

        def par_limit
          @par_limit ||= CORPORATION_START_LIMIT[@players.size]
        end

        def after_par_check_limit!
          @parred_corporations += 1

          return if @players.size == 5
          return unless @parred_corporations >= par_limit

          closing = []
          @corporations.select { |c| c.par_price.nil? }.each do |corporation|
            abilities(corporation, :reservation) do |ability|
              corporation.remove_ability(ability)
            end
            @corporations.reject! { |e| e == corporation }
            closing << corporation.name
          end
          @log << "Closing remaining corporations: #{closing.join(', ')}"
        end

        def after_bid
          @drafted_companies += 1
        end

        def draft_limit
          @draft_limit ||= COMPANY_DRAFT_LIMIT[@players.size]
        end

        def draft_finished?
          @drafted_companies >= draft_limit
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::HomeToken,
            G1846::Step::Assign,
            G18LosAngeles::Step::BuySellParShares,
          ])
        end

        def home_token_locations(corporation)
          return [] unless corporation.id == 'PER'

          self.class::PER_HEXES.map { |coord| hex_by_id(coord) }.select do |hex|
            hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) }
          end
        end

        def operating_round(round_num)
          @round_num = round_num
          G1846::Round::Operating.new(self, [
            G1846::Step::Bankrupt,
            Engine::Step::Assign,
            G18LosAngeles::Step::SpecialToken,
            G18LosAngeles::Step::SpecialTrack,
            G1846::Step::BuyCompany,
            G1846::Step::IssueShares,
            G18LosAngeles::Step::TrackAndToken,
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

        def boomtown
          @boomtown ||= company_by_id('RKO')
        end

        def dch
          @dch ||= company_by_id('DC&H')
        end

        def rj
          @rj ||= company_by_id('RJ')
        end

        def che
          @che ||= company_by_id('CHE2')
        end

        def upgrade_cost(tile, _hex, entity, spender)
          @use_che_discount ||= che&.owner == entity && !tile.upgrades.empty?

          cost = super
          return cost unless @use_che_discount

          discount = self.class::CHE_DISCOUNT
          @log << "#{spender.name} receives a discount of "\
                  "#{format_currency(discount)} from "\
                  "#{che.name}"
          cost - discount
        end

        def dump_company
          @dump_company ||= company_by_id('APD')
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

        def event_remove_markers!
          super

          # piggy-back on the markers event to avoid redefining all the trains
          # from 1846 just for the sake of adding a single new event
          event_remove_rj_token!
        end

        def event_remove_rj_token!
          return unless rj_token

          @log << "-- Event: #{rj_token.corporation.id}'s \"RJ\" token removed from #{rj_token.hex.id} --"
          rj_token.destroy!
          @rj_token = nil
        end

        def dump_corp
          @dump_corp ||= Corporation.new(
            sym: 'DUMP',
            name: 'Dump',
            logo: '18_los_angeles/dump',
            tokens: [0],
          )
        end

        def dump_penalty(route, stops)
          return 0 unless (dump_stop = @dump_token && stops&.find { |s| s.hex == @dump_token.hex })
          return DUMP_PENALTY unless dump_stop.hex.id == WESTMINSTER_HEX

          # Westminster (F9) has a base value of $10 and the Dump can reduce
          # that to $0 but not -$10; however, if Westminster is getting the
          # bonus $40 value from the LA Steamship (steamboat), then the Dump
          # does reduce the total from $50 to $30
          steamboat&.owner == route.corporation && dump_stop.hex.assigned?(steamboat.id) ? DUMP_PENALTY : DUMP_PENALTY_WESTMINSTER
        end

        def revenue_for(route, stops)
          super - dump_penalty(route, stops)
        end

        def revenue_str(route)
          str = super
          str += ' - $20 (Dump)' if dump_penalty(route, route.stops).positive?
          str
        end
      end
    end
  end
end
