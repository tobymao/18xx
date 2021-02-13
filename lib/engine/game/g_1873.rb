# frozen_string_literal: true

require_relative 'base'

module Engine
  module Game
    class G1873 < Base
      attr_reader :tile_groups, :unused_tiles, :sik, :skev, :ldsteg, :mavag, :raba, :snw, :gc, :terrain_tokens
      attr_accessor :premium, :premium_order

      register_colors(tan: '#d6a06c')

      CURRENCY_FORMAT_STR = '%d M'
      BANK_CASH = 100_000
      CERT_LIMIT = {
        2 => 99,
        3 => 99,
        4 => 99,
        5 => 99,
      }.freeze
      STARTING_CASH = {
        2 => 2100,
        3 => 1400,
        4 => 1050,
        5 => 840,
      }.freeze
      CAPITALIZATION = :incremental
      MUST_SELL_IN_BLOCKS = false
      LAYOUT = :pointy
      COMPANIES = [].freeze

      GAME_LOCATION = 'Germany'
      GAME_RULES_URL = 'https://docs.google.com/viewer?a=v&pid=sites&srcid=YWxsLWFib2FyZGdhbWVzLmNvbXxhYWdsbGN8Z3g6MThhODUwM2Q3MWUyMmI2Nw'
      GAME_DESIGNER = 'Klaus Kiermeier'
      GAME_PUBLISHER = :all_aboard_games
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/Harzbahn-1873'

      # DEV_STAGE = :alpha

      EBUY_PRES_SWAP = false # allow presidential swaps of other corps when ebuying
      EBUY_OTHER_VALUE = false # allow ebuying other corp trains for up to face
      HOME_TOKEN_TIMING = :float
      SELL_AFTER = :first
      SELL_BUY_ORDER = :sell_buy
      MARKET_SHARE_LIMIT = 80

      TRACK_RESTRICTION = :restrictive # FIXME: needs to be very_restrictive when implemented

      SELL_MOVEMENT = :down_share

      TILE_LAYS = [{ lay: true, upgrade: true }, { lay: true, upgrade: :not_if_upgraded, cost: 10 }].freeze

      # FIXME
      # EVENTS_TEXT = Base::EVENTS_TEXT.merge(
      #  'first_three' => ['First 3', 'Advance phase'],
      #  'first_four' => ['First 4', 'Advance phase'],
      #  'first_six' => ['First 6', 'Advance phase'],
      # ).freeze

      # FIXME: on purchase of 1st 5 train: two more OR sets
      GAME_END_CHECK = { stock_market: :current_or, custom: :one_more_full_or_set }.freeze

      # FIXME
      STATUS_TEXT = Base::STATUS_TEXT.merge(
        'end_game_triggered' => ['End Game', 'After next SR, final three ORs are played'],
      ).freeze

      RAILWAY_MIN_BID = 100

      def self.title
        'Harzbahn 1873'
      end

      def location_name(coord)
        @location_names ||= game_location_names

        @location_names[coord]
      end

      def setup
        @premium = nil
        @premium_order = nil
        @premium_auction = true

        @minor_info = load_minor_extended
        @corporation_info = load_corporation_extended
      end

      def load_minor_extended
        game_minors.map do |gm|
          minor = @minors.find { |m| m.name == gm[:sym] }
          [minor, gm[:extended]]
        end.to_h
      end

      def load_corporation_extended
        game_corporations.map do |cm|
          corp = @corporations.find { |m| m.name == cm[:sym] }
          [corp, cm[:extended]]
        end.to_h
      end

      # create "dummy" companies based on minors and railways
      def init_companies(_players)
        mine_comps = game_minors.map do |gm|
          description = "Mine in #{gm[:coordinates]}. Machine revenue: "\
            "#{gm[:extended][:machine_revenue].join('/')}. Switcher revenue: "\
            "#{gm[:extended][:switcher_revenue].join('/')}"

          Company.new(sym: gm[:sym], name: gm[:name], value: gm[:extended][:value],
                      revenue: gm[:extended][:machine_revenue].last + gm[:extended][:switcher_revenue].last,
                      desc: description)
        end
        corp_comps = game_corporations.map do |gc|
          next unless gc[:extended][:type] == 'railway'

          description = "Railway in #{gc[:coordinates].join(', ')}. "\
            "Total concession tile cost: #{format_currency(gc[:extended][:concession_cost])}"

          Company.new(sym: gc[:sym], name: gc[:name], value: RAILWAY_MIN_BID,
                      desc: description)
        end.compact
        mine_comps + corp_comps
      end

      def start_companies
        mine_ids = @minors.map(&:id)
        mine_comps = @companies.select { |c| mine_ids.include?(c.id) }

        corp_ids = @corporations.select do |corp|
          @corporation_info[corp][:type] == 'railway' && @corporation_info[corp][:concession_phase] == 1
        end.map(&:id)
        corp_comps = @companies.select { |c| corp_ids.include?(c.id) }

        mine_comps + corp_comps
      end

      def company_header(company)
        if get_mine(company)
          'INDEPENDENT MINE'
        elsif @corporations.any? { |c| c.id == company.id && @corporation_info[c][:concession_pending] }
          'CONCESSION'
        else
          'PURCHASE OPTION'
        end
      end

      def get_mine(company)
        @minors.find { |m| m.id == company.id }
      end

      def close_mine(minor)
        @log << "#{minor.name} is closed"
        @minor_info[minor][:open] = false

        # flip token to closed side
        open_name = "#{minor.id}_open"
        closed_image = "1873/#{minor.id}_closed"
        @hexes.each do |hex|
          if (icon = hex.tile.icons.find { |i| i.name == open_name })
            hex.tile.icons[hex.tile.icons.find_index(icon)] = Part::Icon.new(closed_image, sticky: true)
          end
        end
      end

      def open_mine(minor)
        @log << "#{minor.name} is opened"
        @minor_info[minor][:open] = true

        # flip token to open side
        closed_name = "#{minor.id}_closed"
        open_image = "1873/#{minor.id}_open"
        @hexes.each do |hex|
          if (icon = hex.tile.icons.find { |i| i.name == closed_name })
            hex.tile.icons[hex.tile.icons.find_index(icon)] = Part::Icon.new(open_image, sticky: true)
          end
        end
      end

      def all_corporations
        minors + corporations
      end

      def can_par?(corporation, player)
        return false if corporation.ipoed

        # see if player has corresponding concession (private)
        if @corporation_info[corporation][:type] == 'railway'
          player.companies.any? { |c| c.id == corporation.id }
        else
          @corporation_info[corporation][:vor_harzer] || @turn > 1
        end
      end

      # FIXME: public mines
      def float_corporation(corporation)
        @log << "#{corporation.name} floats"

        num_ipo_shares = corporation.ipo_shares.size
        added_cash = num_ipo_shares * corporation.share_price.price

        return unless added_cash.positive?

        corporation.ipo_shares.each do |share|
          @share_pool.transfer_shares(
              share.to_bundle,
              share_pool,
              spender: share_pool,
              receiver: @bank,
              price: 0
            )
        end

        @bank.spend(added_cash, corporation)
        @log << "#{num_ipo_shares} IPO shares of #{corporation.name} transfered to market"
        @log << "#{corporation.name} receives #{format_currency(added_cash)}"
      end

      def place_home_token(corporation)
        corporation.coordinates.each do |coord|
          hex = hex_by_id(coord)
          tile = hex&.tile
          cities = tile.cities
          city = cities.find { |c| c.reserved_by?(corporation) } || cities.first
          token = corporation.find_token_by_type

          @log << "#{corporation.name} places a token on #{hex.name}"
          city.place_token(corporation, token)
        end
      end

      def init_round
        new_premium_round
      end

      def new_premium_round
        Round::Auction.new(self, [
          Step::G1873::Premium,
        ])
      end

      def reorder_players_start
        @players = @premium_order
        @log << "#{@players.first.name} has priority deal"
      end

      def new_start_auction_round
        Round::Auction.new(self, [
          Step::G1873::Draft,
        ])
      end

      # FIXME
      def new_auction_round
        Round::Auction.new(self, [
          Step::G1873::BuyConcessionOr,
        ])
      end

      # FIXME
      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Track,
          Step::Token,
          Step::Route,
          Step::Dividend,
          Step::BuyTrain,
        ], round_num: round_num)
      end

      def next_round!
        @round =
          case @round
          when Round::Auction
            if @premium_auction
              @premium_auction = false
              init_round_finished
              reorder_players_start
              new_start_auction_round
            else
              new_stock_round
            end
          when Round::Stock
            @operating_rounds = @phase.operating_rounds
            reorder_players
            new_operating_round
          when Round::Operating
            no_train_advance!
            if @round.round_num < @operating_rounds && !@phase_change
              or_round_finished
              new_operating_round(@round.round_num + 1)
            else
              @phase_change = false
              @turn += 1
              or_round_finished
              or_set_finished
              new_auction_round
            end
          when init_round.class
            init_round_finished
            reorder_players_start
            new_start_auction_round
          end
      end

      # FIXME
      def upgrades_to?(from, to, special = false)
        # correct color progression?
        return false unless Engine::Tile::COLORS.index(to.color) == (Engine::Tile::COLORS.index(from.color) + 1)

        # honors pre-existing track?
        return false unless from.paths_are_subset_of?(to.paths)

        # If special ability then remaining checks is not applicable
        return true if special

        # correct label?
        return false if from.label != to.label && !(from.label.to_s == 'K' && to.color == :yellow)

        # honors existing town/city counts?
        # - allow labelled cities to upgrade regardless of count; they're probably
        #   fine (e.g., 18Chesapeake's OO cities merge to one city in brown)
        # - TODO: account for games that allow double dits to upgrade to one town
        return false if from.towns.size != to.towns.size
        return false if (!from.label || from.label.to_s == 'K') && from.cities.size != to.cities.size

        # handle case where we are laying a yellow OO tile and want to exclude single-city tiles
        return false if (from.color == :white) && from.label.to_s == 'OO' && from.cities.size != to.cities.size

        true
      end

      # FIXME: take care of compulsory train
      def must_buy_train?(_entity)
        false
      end

      def price_movement_chart
        [
          ['Dividend', 'Share Price Change'],
          ['0', '1 space to the left'],
          ['> 0 and < stock value', 'none'],
          ['>= stock value and < 2x stock value', '1 space to the right'],
          ['>= 2x stock value and < 3x stock value', '2 spaces to the right'],
          ['>= 3x stock value', '3 spaces to the right'],
        ]
      end

      def player_card_minors(player)
        minors.select { |m| m.owner == player }
      end

      def player_sort(entities)
        minors, majors = entities.partition(&:minor?)
        (minors.sort_by { |m| m.name.to_i } + majors.sort_by(&:name)).group_by(&:owner)
      end

      def game_location_names
        {
          'B9' => 'Wernigerode',
          'B13' => 'Derenbug',
          'B19' => 'Halberstadt',
          'C4' => 'Brocken',
          'C6' => 'Knaupsholz',
          'C12' => 'Bezingerode',
          'C14' => 'Heimburg',
          'C16' => 'Langenstein',
          'D5' => 'Schierke',
          'D7' => 'Drie Annen Hohne',
          'D9' => 'Elbingerode',
          'D11' => 'Hüttenrode',
          'D13' => 'Braunesumpf',
          'D15' => 'Blankenburg',
          'D17' => 'Westerhausen',
          'E4' => 'Braunlage Wurmberg',
          'E6' => 'Elend',
          'E8' => 'Königshütte',
          'E10' => 'Rübeland',
          'E16' => 'Timmenrode',
          'E18' => 'Weddersleben',
          'E20' => 'Quedlinburg',
          'F3' => 'Brunnenbachsmühle',
          'F5' => 'Sorge',
          'F7' => 'Tanne',
          'F9' => 'Trautenstein',
          'F11' => 'Hasselfelde',
          'F15' => 'Thale',
          'G2' => 'Wieda',
          'G4' => 'Zorge',
          'G6' => 'Benneckenstein',
          'G12' => 'Stiege',
          'G14' => 'Allrode',
          'G16' => 'Friedrichsbrunn',
          'G20' => 'Gernrode',
          'H9' => 'Eisfelder Talmühle',
          'H13' => 'Güntersberge',
          'H17' => 'Alexisbad',
          'I2' => 'Walkenried',
          'I4' => 'Ellrich',
          'I8' => 'Netzkater',
          'I14' => 'Lindenberg',
          'I16' => 'Silberhütte',
          'I18' => 'Harzgerode',
          'J7' => 'Nordhausen',
        }
      end

      def game_tiles
        {
          '77' => 2,
          '78' => 10,
          '79' => 4,
          '75' => 4,
          '76' => 7,
          '956' => 10,
          '957' => 2,
          '958' => 2,
          '959' => 1,
          '960' => 1,
          '961' => 2,
          '100' => 4,
          '101' => 1,
          '962' => 6,
          '963' => 6,
          '971' => 2,
          '972' => 3,
          '973' => 1,
          '974' => 1,
          '964' => 1,
          '965' => 1,
          '966' => 1,
          '967' => 1,
          '968' => 2,
          '969' => 2,
          '970' => 1,
          '975' => 4,
          '976' => 6,
          '977' => 5,
          '978' => 2,
          '979' => 2,
          '980' => 2,
          '985' => 2,
          '986' => 1,
          '987' => 2,
          '988' => 3,
          '989' => 2,
          '990' => 2,
        }
      end

      def game_market
        [
          %w[
            50
            70
            85
            100
            110
            120p
            130
            140
            150p
            160
            170
            180
            190p
            200
            220
            240
            260
            280
            300p
            330
            360
            390
            420
            450
            490
            530
            570
            610
            650
            700
            750
            800
            850
            900
            950
            1000e
          ],
        ]
      end

      def game_minors
        [
          {
            sym: '1',
            name: 'Mine 1 (V-H)',
            logo: '1873/1',
            tokens: [],
            coordinates: 'E8',
            color: '#772500',
            extended: {
              value: 110,
              vor_harzer: true,
              machine_revenue: [40, 50, 60, 70, 80],
              switcher_revenue: [30, 40, 50, 60],
              open: true,
            },
          },
          {
            sym: '2',
            name: 'Mine 2',
            logo: '1873/2',
            tokens: [],
            coordinates: 'E4',
            color: 'black',
            extended: {
              value: 120,
              vor_harzer: false,
              machine_revenue: [40, 60, 80, 100, 120],
              switcher_revenue: [20, 30, 40, 50],
              open: true,
            },
          },
          {
            sym: '3',
            name: 'Mine 3',
            logo: '1873/3',
            tokens: [],
            coordinates: 'I16',
            color: 'black',
            extended: {
              value: 130,
              vor_harzer: false,
              machine_revenue: [40, 60, 80, 100, 120],
              switcher_revenue: [20, 30, 40, 50],
              open: true,
            },
          },
          {
            sym: '4',
            name: 'Mine 4 (V-H)',
            logo: '1873/4',
            tokens: [],
            coordinates: 'D11',
            color: '#772500',
            extended: {
              value: 140,
              vor_harzer: true,
              machine_revenue: [40, 60, 80, 100, 120],
              switcher_revenue: [20, 30, 40, 50],
              open: true,
            },
          },
          {
            sym: '5',
            name: 'Mine 5 (V-H)',
            logo: '1873/5',
            tokens: [],
            coordinates: 'D13',
            color: '#772500',
            extended: {
              value: 150,
              vor_harzer: true,
              machine_revenue: [50, 60, 70, 80, 90],
              switcher_revenue: [40, 50, 60, 70],
              open: true,
            },
          },
          {
            sym: '6',
            name: 'Mine 6 (V-H)',
            logo: '1873/6',
            tokens: [],
            coordinates: 'E10',
            color: '#772500',
            extended: {
              value: 160,
              vor_harzer: true,
              machine_revenue: [50, 70, 90, 110, 130],
              switcher_revenue: [30, 40, 50, 60],
              open: true,
            },
          },
          {
            sym: '7',
            name: 'Mine 7',
            logo: '1873/7',
            tokens: [],
            coordinates: 'I14',
            color: 'black',
            extended: {
              value: 170,
              vor_harzer: false,
              machine_revenue: [50, 80, 110, 140, 170],
              switcher_revenue: [20, 30, 40, 50],
              open: true,
            },
          },
          {
            sym: '8',
            name: 'Mine 8',
            logo: '1873/8',
            tokens: [],
            coordinates: 'I8',
            color: 'black',
            extended: {
              value: 180,
              vor_harzer: false,
              machine_revenue: [60, 80, 100, 120, 140],
              switcher_revenue: [40, 50, 60, 70],
              open: true,
            },
          },
          {
            sym: '9',
            name: 'Mine 9',
            logo: '1873/9',
            tokens: [],
            coordinates: 'G2',
            color: 'black',
            extended: {
              value: 190,
              vor_harzer: false,
              machine_revenue: [60, 90, 120, 150, 180],
              switcher_revenue: [30, 40, 50, 60],
              open: true,
            },
          },
          {
            sym: '10',
            name: 'Mine 10 (V-H)',
            logo: '1873/10',
            tokens: [],
            coordinates: 'D9',
            color: '#772500',
            extended: {
              value: 200,
              vor_harzer: true,
              machine_revenue: [60, 90, 120, 150, 180],
              switcher_revenue: [30, 40, 50, 60],
              open: true,
            },
          },
          {
            sym: '11',
            name: 'Mine 11 (V-H)',
            logo: '1873/11',
            tokens: [],
            coordinates: 'F7',
            color: '#772500',
            extended: {
              value: 220,
              vor_harzer: true,
              machine_revenue: [70, 90, 110, 130, 150],
              switcher_revenue: [50, 60, 70, 80],
              open: true,
            },
          },
          {
            sym: '12',
            name: 'Mine 12 (V-H)',
            logo: '1873/12',
            tokens: [],
            coordinates: 'D15',
            color: '#772500',
            extended: {
              value: 240,
              vor_harzer: true,
              machine_revenue: [70, 90, 110, 130, 150],
              switcher_revenue: [50, 60, 70, 80],
              open: true,
            },
          },
          {
            sym: '13',
            name: 'Mine 13',
            logo: '1873/13',
            tokens: [],
            coordinates: 'I18',
            color: 'black',
            extended: {
              value: 260,
              vor_harzer: false,
              machine_revenue: [70, 100, 130, 160, 190],
              switcher_revenue: [40, 50, 60, 70],
              open: true,
            },
          },
          {
            sym: '14',
            name: 'Mine 14 (V-H)',
            logo: '1873/14',
            tokens: [],
            coordinates: 'G4',
            color: '#772500',
            extended: {
              value: 280,
              vor_harzer: true,
              machine_revenue: [90, 110, 130, 150, 170],
              switcher_revenue: [70, 80, 90, 100],
              open: true,
            },
          },
          {
            sym: '15',
            name: 'Mine 15',
            logo: '1873/15',
            tokens: [],
            coordinates: 'F15',
            color: 'black',
            extended: {
              value: 300,
              vor_harzer: true,
              machine_revenue: [90, 120, 150, 180, 210],
              switcher_revenue: [60, 70, 80, 90],
              open: true,
            },
          },
        ]
      end

      def game_corporations
        [
          {
            sym: 'HBE',
            name: 'Halberstadt-Blankenburger Eisenbahn',
            logo: '1873/HBE',
            float_percent: 60,
            shares: [20, 20, 20, 20, 20],
            max_ownership_percent: 100,
            coordinates: %w[B19 D15],
            city: 0,
            tokens: [
              0,
              0,
              100,
              100,
              100,
              100,
              100,
              100,
            ],
            color: '#FF0000',
            text_color: 'black',
            extended: {
              type: 'railway',
              concession_phase: 1,
              concession_routes: [%w[B19 B17 C16 D15]],
              concession_cost: 0,
              concession_pending: true,
              extra_tokens: 4,
            },
          },
          {
            sym: 'GHE',
            name: 'Gernrode-Harzgeroder Eisenbahn',
            logo: '1873/GHE',
            float_percent: 60,
            shares: [20, 20, 20, 20, 20],
            max_ownership_percent: 100,
            coordinates: %w[G20 I18],
            city: 0,
            tokens: [
              0,
              0,
              100,
              100,
              100,
              100,
            ],
            color: '#326199',
            text_color: 'white',
            extended: {
              type: 'railway',
              concession_phase: 1,
              concession_routes: [%w[G20 H19 G17 I18]],
              concession_cost: 150,
              concession_pending: true,
              extra_tokens: 3,
            },
          },
          {
            sym: 'NWE',
            name: 'Nordhausen-Wernigeroder Eisenbahn',
            logo: '1873/NWE',
            float_percent: 60,
            shares: [20, 20, 20, 20, 20],
            max_ownership_percent: 100,
            coordinates: %w[J7 B9 G6],
            city: 0,
            tokens: [
              0,
              0,
              0,
              100,
              100,
              100,
            ],
            color: '#A2A024',
            text_color: 'black',
            extended: {
              type: 'railway',
              concession_phase: 3,
              concession_routes: [%w[B9 C8 D7 E6 F5 G6], %w[G6 H7 H9 I8 J7]],
              concession_cost: 500,
              concession_pending: true,
              extra_tokens: 3,
            },
          },
          {
            sym: 'SHE',
            name: 'Südharzeisenbahn',
            logo: '1873/SHE',
            float_percent: 60,
            shares: [20, 20, 20, 20, 20],
            max_ownership_percent: 100,
            coordinates: %w[I2 E4],
            city: 0,
            tokens: [
              0,
              0,
              100,
              100,
            ],
            color: '#FFFF00',
            text_color: 'black',
            extended: {
              type: 'railway',
              concession_phase: 3,
              concession_routes: [%w[E4 F3 G2 H1 I2]],
              concession_cost: 300,
              concession_pending: true,
              extra_tokens: 2,
            },
          },
          {
            sym: 'KEZ',
            name: 'Kleinbahn Ellrich-Zorge',
            logo: '1873/KEZ',
            float_percent: 60,
            shares: [20, 20, 20, 20, 20],
            max_ownership_percent: 100,
            coordinates: %w[I4 G4],
            city: 0,
            tokens: [
              0,
              0,
              100,
              100,
            ],
            color: '#2E270D',
            text_color: 'white',
            extended: {
              type: 'railway',
              concession_phase: 3,
              concession_routes: [%w[G4 H3 I4]],
              concession_cost: 100,
              concession_pending: true,
              extra_tokens: 2,
            },
          },
          {
            sym: 'WBE',
            name: 'Wernigerode-Blankenburger Eisenbahn',
            logo: '1873/WBE',
            float_percent: 60,
            shares: [20, 20, 20, 20, 20],
            max_ownership_percent: 100,
            coordinates: %w[B9 D15],
            city: 0,
            tokens: [
              0,
              0,
              100,
              100,
            ],
            color: '#2E270D',
            text_color: 'white',
            extended: {
              type: 'railway',
              concession_phase: 4,
              concession_routes: [%w[B9 C10 C12 C14 D15]],
              concession_cost: 0,
              concession_pending: true,
              extra_tokens: 2,
            },
          },
          {
            sym: 'QLB',
            name: 'Quedlinburger Lokalbahn',
            logo: '1873/QLB',
            float_percent: 60,
            shares: [20, 20, 20, 20, 20],
            max_ownership_percent: 100,
            coordinates: ['E20'],
            city: 0,
            tokens: [
              0,
              0,
              100,
              100,
            ],
            color: '#FF740E',
            text_color: 'black',
            extended: {
              type: 'railway',
              concession_phase: 4,
              concession_routes: [],
              concession_cost: 0,
              concession_pending: false,
              extra_tokens: 2,
            },
          },
          {
            sym: 'MHE',
            name: 'Magdeburg-Halberstädter Eisenbahn',
            logo: '1873/MHE',
            float_percent: 60,
            shares: [10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
            tokens: [],
            max_ownership_percent: 100,
            color: '#C0C0C0',
            text_color: 'black',
            extended: {
              type: 'external',
            },
          },
          {
            sym: 'U',
            name: 'Union',
            logo: '1873/U',
            float_percent: 100,
            shares: [50, 50],
            tokens: [],
            max_ownership_percent: 100,
            color: '#950822',
            text_color: 'white',
            extended: {
              type: 'mine',
              vor_harzer: false,
            },
          },
          {
            sym: 'HW',
            name: 'Harzer Werke',
            logo: '1873/HW',
            float_percent: 100,
            shares: [50, 50],
            tokens: [],
            max_ownership_percent: 100,
            color: '#772500',
            text_color: 'white',
            extended: {
              type: 'mine',
              vor_harzer: true,
            },
          },
          {
            sym: 'CO',
            name: 'Concordia',
            logo: '1873/CO',
            float_percent: 100,
            shares: [50, 50],
            tokens: [],
            max_ownership_percent: 100,
            color: '#16CE91',
            text_color: 'white',
            extended: {
              type: 'mine',
              vor_harzer: false,
            },
          },
          {
            sym: 'SN',
            name: 'Schachtbau',
            logo: '1873/SN',
            float_percent: 100,
            shares: [50, 50],
            tokens: [],
            max_ownership_percent: 100,
            color: '#F7848D',
            text_color: 'black',
            extended: {
              type: 'mine',
              vor_harzer: false,
            },
          },
          {
            sym: 'MO',
            name: 'Montania',
            logo: '1873/MO',
            float_percent: 100,
            shares: [50, 50],
            tokens: [],
            max_ownership_percent: 100,
            color: '#448A28',
            text_color: 'black',
            extended: {
              type: 'mine',
              vor_harzer: false,
            },
          },
        ]
      end

      def game_trains
        [
          {
            name: '1T',
            distance: 1,
            price: 100,
            num: 1,
          },
          {
            name: '2T',
            distance: 2,
            price: 250,
            num: 10,
            variants: [
              {
                name: '2M',
                distance: 2,
                price: 150,
              },
            ],
          },
          {
            name: '3T',
            distance: 3,
            price: 450,
            num: 7,
            variants: [
              {
                name: '3M',
                distance: 3,
                price: 300,
              },
            ],
          },
          {
            name: '4T',
            distance: 4,
            price: 750,
            num: 3,
            variants: [
              {
                name: '4M',
                distance: 4,
                price: 500,
              },
            ],
          },
          {
            name: '5T',
            distance: 5,
            price: 1200,
            num: 99,
            variants: [
              {
                name: '5M',
                distance: 5,
                price: 800,
              },
            ],
          },
          {
            name: 'D',
            distance: 999,
            price: 250,
            num: 7,
          },
        ]
      end

      def game_hexes
        {
          white: {
            # HBE concession route
            %w[
              B17
            ] => 'icon=image:1873/HBE,sticky:1',
            # GHE concession route
            %w[
              H19
            ] => 'upgrade=cost:150,terrain:mountain;icon=image:1873/GHE,sticky:1',
            # NWE concession route
            %w[
              I8
            ] => 'town=revenue:0;upgrade=cost:150,terrain:mountain;icon=image:1873/NWE,sticky:1;'\
                'border=edge:2,type:impassible;'\
                'icon=image:1873/8_open,sticky:1',
            %w[
              H7
            ] => 'upgrade=cost:100,terrain:mountain;icon=image:1873/NWE,sticky:1;'\
                'border=edge:5,type:impassible',
            %w[
              E6
              D7
            ] => 'town=revenue:0;upgrade=cost:50,terrain:mountain;icon=image:1873/NWE,sticky:1',
            %w[
              C8
            ] => 'upgrade=cost:150,terrain:mountain;icon=image:1873/NWE,sticky:1;',
            # SHE concession route
            %w[
              G2
            ] => 'town=revenue:0;upgrade=cost:150,terrain:mountain;icon=image:1873/SHE,sticky:1;'\
                'border=edge:4,type:impassible;border=edge:5,type:impassible;'\
                'icon=image:1873/9_open,sticky:1',
            %w[
              F3
            ] => 'town=revenue:0;upgrade=cost:150,terrain:mountain;icon=image:1873/SHE,sticky:1',
            # KEZ concession route
            %w[
              H3
            ] => 'upgrade=cost:100,terrain:mountain;icon=image:1873/KEZ,sticky:1;'\
                'border=edge:2,type:impassible',
            # WBE concession route
            %w[
              C10
            ] => 'border=edge:5,type:impassible;'\
              'icon=image:1873/lock;'\
              'icon=image:1873/WBE,sticky:1',
            %w[
              C12
            ] => 'town=revenue:0;border=edge:0,type:impassible;border=edge:5,type:impassible;'\
              'icon=image:1873/lock;'\
              'icon=image:1873/WBE,sticky:1',
            %w[
              C14
            ] => 'town=revenue:0;border=edge:0,type:impassible;'\
              'icon=image:1873/lock;'\
              'icon=image:1873/WBE,sticky:1',
            # empty tiles
            %w[
              C18
              D19
            ] => '',
            # no towns
            %w[
              B15
            ] => 'upgrade=cost:50,terrain:mountain',
            %w[
              G8
              H11
            ] => 'upgrade=cost:100,terrain:mountain',
            %w[
              E12
            ] => 'upgrade=cost:100,terrain:mountain;border=edge:1,type:impassible',
            %w[
              E14
              G10
              G18
              H5
              H15
              I12
            ] => 'upgrade=cost:150,terrain:mountain',
            # towns
            %w[
              D5
            ] => 'town=revenue:0;upgrade=cost:150,terrain:mountain;border=edge:0,type:impassible',
            %w[
              D11
            ] => 'town=revenue:0;upgrade=cost:100,terrain:mountain;border=edge:1,type:impassible;'\
              'border=edge:2,type:impassible;border=edge:3,type:impassible;'\
              'icon=image:1873/4_open,sticky:1',
            %w[
              D13
            ] => 'town=revenue:0;upgrade=cost:150,terrain:mountain;'\
              'border=edge:2,type:impassible;border=edge:3,type:impassible;'\
              'icon=image:1873/5_open,sticky:1',
            %w[
              D17
            ] => 'town=revenue:0;',
            %w[
              E8
            ] => 'town=revenue:0;upgrade=cost:100,terrain:mountain;border=edge:4,type:impassible;'\
              'icon=image:1873/1_open,sticky:1',
            %w[
              E10
            ] => 'town=revenue:0;upgrade=cost:100,terrain:mountain;border=edge:1,type:impassible;'\
              'border=edge:4,type:impassible;'\
              'icon=image:1873/6_open,sticky:1',
            %w[
              E16
              G12
              G14
            ] => 'town=revenue:0;upgrade=cost:50,terrain:mountain',
            %w[
              F9
              G16
            ] => 'town=revenue:0;upgrade=cost:100,terrain:mountain',
            %w[
              I14
            ] => 'town=revenue:0;upgrade=cost:50,terrain:mountain;'\
              'icon=image:1873/7_open,sticky:1',
            %w[
              I16
            ] => 'town=revenue:0;upgrade=cost:100,terrain:mountain;'\
              'icon=image:1873/3_open,sticky:1',
          },
          yellow: {
            %w[
              D9
            ] => 'city=revenue:30;path=a:5,b:_0,track:narrow;upgrade=cost:50,terrain:mountain;'\
              'border=edge:4,type:impassible;frame=color:red;'\
              'icon=image:1873/10_open,sticky:1',
            %w[
              D15
            ] => 'city=revenue:40,slots:2;path=a:1,b:_0,track:narrow;path=a:3,b:_0,track:narrow;'\
              'path=a:5,b:_0,track:narrow;label=B;frame=color:red;'\
              'icon=image:1873/12_open,sticky:1',
            %w[
              E4
            ] => 'city=revenue:30;path=a:0,b:_0,track:narrow;upgrade=cost:50,terrain:mountain;'\
              'border=edge:3,type:impassible;frame=color:red;'\
              'icon=image:1873/2_open,sticky:1',
            %w[
              F11
            ] => 'city=revenue:30;path=a:5,b:_0,track:narrow;upgrade=cost:50,terrain:mountain;'\
              'frame=color:red;'\
              'icon=image:1873/SM_open,sticky:1',
            %w[
              G4
            ] => 'city=revenue:30;path=a:0,b:_0,track:narrow;upgrade=cost:50,terrain:mountain;'\
              'border=edge:1,type:impassible;border=edge:3,type:impassible;frame=color:red;'\
              'icon=image:1873/14_open,sticky:1',
          },
          green: {
            %w[
              B19
            ] => 'city=revenue:60;path=a:1,b:_0,track:narrow;path=a:2,b:_0;path=a:5,b:_0;'\
              'frame=color:red;label=HQG',
            %w[
              C16
            ] => 'city=revenue:30;path=a:0,b:_0,track:narrow;path=a:2,b:_0,track:narrow;'\
              'path=a:3,b:_0,track:narrow',
            %w[
              E20
            ] => 'city=revenue:60;path=a:1,b:_0,track:narrow;path=a:0,b:_0;path=a:3,b:_0;'\
              'frame=color:red;label=HQG',
            %w[
              F5
            ] => 'city=revenue:20;city=revenue:20;path=a:1,b:_0,track:narrow;path=a:4,b:_0,track:narrow;'\
              'path=a:3,b:_1,track:narrow;path=a:5,b:_1,track:narrow;'\
              'upgrade=cost:50,terrain:mountain;border=edge:0,type:impassible',
            %w[
              F7
            ] => 'city=revenue:20;city=revenue:20;path=a:1,b:_0,track:narrow;'\
              'path=a:3,b:_1,track:narrow;upgrade=cost:50,terrain:mountain;'\
              'icon=image:1873/11_open,sticky:1',
            %w[
              G6
            ] => 'city=revenue:40;path=a:2,b:_0,track:narrow;'\
              'path=a:5,b:_0,track:narrow;frame=color:red',
            %w[
              G20
            ] => 'city=revenue:60;path=a:0,b:_0,track:narrow;path=a:2,b:_0;path=a:5,b:_0;'\
              'frame=color:red;label=HQG',
            %w[
              H13
            ] => 'city=revenue:40;path=a:2,b:_0,track:narrow;path=a:5,b:_0,track:narrow;'\
              'upgrade=cost:50,terrain:mountain;frame=color:red',
            %w[
              H17
            ] => 'city=revenue:30;path=a:0,b:_0,track:narrow;path=a:4,b:_0,track:narrow;'\
              'path=a:5,b:_0,track:narrow;upgrade=cost:100,terrain:mountain;frame=color:red',
          },
          gray: {
            %w[
              B9
            ] => 'city=slots:2,revenue:yellow_60|green_80|brown_120|gray_150;'\
              'path=a:1,b:_0;path=a:4,b:_0;path=a:0,b:_0,track:narrow;path=a:5,b:_0,track:narrow;'\
              'frame=color:red',
            %w[
              B13
            ] => 'city=slots:2,revenue:yellow_30|green_70|brown_60|gray_60;'\
              'path=a:4,b:_0,track:narrow;path=a:5,b:_0,track:narrow;'\
              'frame=color:red',
            %w[
              C4
            ] => 'city=revenue:yellow_50|green_80|brown_120|gray_150;path=a:5,b:_0,track:narrow',
            %w[
              C6
            ] => 'town=revenue:0;path=a:0,b:_0,track:narrow;'\
              'icon=image:1873/SBC6_open,sticky:1',
            %w[
              E18
            ] => 'city=revenue:30,slots:2;path=a:1,b:_0,track:narrow;'\
              'path=a:2,b:_0,track:narrow;path=a:4,b:_0,track:narrow;'\
              'icon=image:1873/PM_open,sticky:1',
            %w[
              F15
            ] => 'city=revenue:yellow_30|green_40|brown_60|gray_70;'\
              'path=a:3,b:_0,track:narrow;path=a:4,b:_0;frame=color:red;'\
              'icon=image:1873/15_open,sticky:1',
            %w[
              H9
            ] => 'city=revenue:30,slots:2;path=a:0,b:_0,track:narrow;'\
              'path=a:1,b:_0,track:narrow;path=a:4,b:_0,track:narrow;'\
              'icon=image:1873/SBH9_open,sticky:1',
            %w[
              I2
            ] => 'city=revenue:yellow_40|green_50|brown_80|gray_120;path=a:1,b:_0;'\
              'path=a:2,b:_0,track:narrow;path=a:4,b:_0;frame=color:red',
            %w[
              I4
            ] => 'city=revenue:yellow_40|green_50|brown_80|gray_120;path=a:1,b:_0;'\
              'path=a:2,b:_0,track:narrow;path=a:5,b:_0;frame=color:red',
            %w[
              I18
            ] => 'city=revenue:yellow_30|green_40|brown_60|gray_70;'\
              'path=a:2,b:_0,track:narrow;frame=color:red;'\
              'icon=image:1873/13_open,sticky:1',
            %w[
              J7
            ] => 'city=revenue:yellow_60|green_80|brown_120|gray_180;path=a:1,b:_0;'\
              'path=a:3,b:_0,track:narrow;path=a:4,b:_0;frame=color:red',
            # implicit tiles
            %w[
              C20
            ] => 'path=a:2,b:5',
            %w[
              D21
            ] => 'path=a:2,b:0',
            %w[
              F17
            ] => 'path=a:1,b:4',
            %w[
              F19
            ] => 'path=a:1,b:3;path=a:5,b:3',
            %w[
              H1
            ] => 'path=a:5,b:3,track:narrow',
            %w[
              J5
            ] => 'path=a:2,b:4',
          },
        }
      end

      def game_phases
        [
          {
            name: '1',
            train_limit: 99,
            tiles: [
              'yellow',
            ],
            operating_rounds: 1,
          },
          {
            name: '2',
            on: '2',
            train_limit: 99,
            tiles: [
              'yellow',
            ],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: 99,
            tiles: %w[
              yellow
              green
            ],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: 99,
            tiles: %w[
              yellow
              green
            ],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: 99,
            tiles: %w[
              yellow
              green
              brown
            ],
            operating_rounds: 3,
          },
          {
            name: 'D',
            on: 'D',
            train_limit: 99,
            tiles: %w[
              yellow
              green
              brown
              gray
            ],
            operating_rounds: 3,
          },
        ]
      end
    end
  end
end
