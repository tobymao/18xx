# frozen_string_literal: true

require_relative '../base'
require_relative 'meta'
require_relative 'map'
require_relative 'entities'

module Engine
  module Game
    module G1894
      class Game < Game::Base
        include_meta(G1894::Meta)
        include G1894::Map
        include G1894::Entities

        attr_accessor :skip_track_and_token

        CURRENCY_FORMAT_STR = '%s F'

        BANK_CASH = 99_999

        CERT_LIMIT = { 3 => 18, 4 => 14 }.freeze

        STARTING_CASH = { 3 => 570, 4 => 480 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        MARKET = [
          %w[90 99 109 115 124 132 141 151 180 215 260 310 375 450e],
          %w[82 95p 100 106 113 121 130 139 165 200 240 285 345 415],
          %w[75 82 89 95 103 111 120 130 155 185 225 270 320],
          %w[69 75 81 87 93 100p 108 116 140 170 200 235],
          %w[64 69 74 80p 85 91 97 111 130 155 185],
          %w[59o 64 68 71 76 81 90 101 120 140],
          %w[50o 56o 62 66 70 75 83 93],
          %w[40o 50o 55o 60 64 67p 75],
          %w[30o 40o 50o 55o 60],
          %w[20o 30o 40o 50o 55o],
          %w[10o 20o 30o 40o 50o],
        ].freeze

        def price_movement_chart
          [
            ['Action', 'Share Price Change'],
            ['Dividend 0 or withheld', '1 ←'],
            ['Dividend paid', '1 →'],
            ['N shares sold', 'N ↓'],
            ['Corporation sold out at end of SR', '1 ↑'],
            ['Corporation sold out at end of SR and president + treasury at least 80%', '1 additional ↑'],
            ['Corporation sold out at end of SR and the stock price in gray area', '1 additional ↑'],
          ]
        end

        PHASES = [{ name: 'Yellow', train_limit: 4, tiles: [:yellow], operating_rounds: 1 },
                  {
                    name: 'Green',
                    on: '3',
                    train_limit: 4,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                    status: ['can_buy_companies'],
                  },
                  {
                    name: 'Blue',
                    on: '4',
                    train_limit: 3,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                    status: ['can_buy_companies'],
                  },
                  {
                    name: 'Brown',
                    on: '5+1',
                    train_limit: 3,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                    status: ['can_buy_companies'],
                  },
                  {
                    name: 'Red',
                    on: '6',
                    train_limit: 3,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: 'Gray',
                    on: '7',
                    train_limit: 3,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: 'Purple',
                    on: 'D',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  }].freeze

        TRAINS = [{ name: '2', distance: 2, price: 80, rusts_on: '4', num: 7 },
                  {
                    name: '3',
                    distance: 3,
                    price: 120,
                    rusts_on: '5+1',
                    num: 5,
                    discount: { '2' => 40 },
                  },
                  {
                    name: '4',
                    distance: 4,
                    price: 300,
                    rusts_on: '7',
                    num: 4,
                    discount: { '3' => 60 },
                  },
                  {
                    name: '5+1',
                    distance: [{ 'nodes' => ['town'], 'pay' => 1, 'visit' => 1 },
                               { 'nodes' => %w[city offboard town], 'pay' => 5, 'visit' => 5 }],
                    price: 400,
                    rusts_on: 'D',
                    num: 5,
                    events: [{ 'type' => 'late_corporations_available' }],
                    discount: { '4' => 150 },
                  },
                  {
                    name: '6',
                    distance: 6,
                    price: 600,
                    num: 2,
                    events: [{ 'type' => 'close_companies' }],
                    discount: { '5+1' => 200 },
                  },
                  {
                    name: '7',
                    distance: 7,
                    price: 700,
                    num: 3,
                    discount: { '6' => 300 },
                  },
                  {
                    name: 'D',
                    distance: 999,
                    price: 800,
                    num: 22,
                    events: [{ 'type' => 'last_or_set_triggered' }],
                    discount: { '5+1' => 200, '6' => 300, '7' => 350 },
                  }].freeze

        LAYOUT = :pointy

        MULTIPLE_BUY_TYPES = %i[unlimited].freeze

        MUST_BID_INCREMENT_MULTIPLE = true
        MIN_BID_INCREMENT = 5

        TILE_RESERVATION_BLOCKS_OTHERS = :never

        GAME_END_CHECK = {
          bankrupt: :immediate,
          stock_market: :immediate,
          final_phase: :one_more_full_or_set,
        }.freeze

        SELL_BUY_ORDER = :sell_buy_sell

        NEXT_SR_PLAYER_ORDER = :first_to_pass

        TRACK_RESTRICTION = :permissive

        DISCARDED_TRAINS = :remove

        MARKET_SHARE_LIMIT = 50 # percent

        MARKET_TEXT = Base::MARKET_TEXT.merge(par: 'Par',
                                              unlimited: 'Corporation shares can be held above 60% and ' \
                                                         'President may buy two at a time and ' \
                                                         'additional move up if sold out and don\'t count '\
                                                         'towards the cert limit.')

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(par: :red,
                                                            unlimited: :gray)

        IPO_RESERVED_NAME = 'Treasury'

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'late_corporations_available' => ['Late corporations available', 'Late corporations can be opened'],
          'last_or_set_triggered' => ['The next OR set will be the last one',
                                      'The next OR set will be the last one. '\
                                      'Regular green cities may not be upgraded to brown. '\
                                      'Track and token actions are skipped in the last OR set'],
        ).freeze

        LONDON_HEX = 'A10'
        LONDON_BONUS_FERRY_SUPPLY_HEX = 'A12'
        FERRY_MARKER_ICON = 'ferry'
        FERRY_MARKER_COST = 80
        LS_FERRY_MARKER_COST = 40

        PARIS_HEX = 'G6'
        CENTRE_BOURGOGNE_HEX = 'I2'
        LUXEMBOURG_HEX = 'I18'
        SQ_HEX = 'G10'
        BRUXELLES_HEX = 'F15'
        LILLE_HEX = 'D11'
        NETHERLANDS_HEX = 'C18'
        GREAT_BRITAIN_HEX = 'A4'
        FRENCH_LATE_CORPORATIONS_HOME_HEXES = %w[B3 B9 B11 D3 D9 D11 E2 E6 E10 G4 G6 G10 H9 I10].freeze
        BELGIAN_LATE_CORPORATIONS_HOME_HEXES = %w[C14 D15 D17 E16 F15 G14 G18 H17].freeze

        NON_NETHERLANDS_OFFBOARDS = [CENTRE_BOURGOGNE_HEX, LUXEMBOURG_HEX, GREAT_BRITAIN_HEX].freeze

        GREEN_CITY_TILES = %w[14 15 619].freeze
        GREEN_CITY_14_TILE = '14'
        BROWN_CITY_14_UPGRADE_TILES = %w[X16 X17 X18].freeze
        GREEN_CITY_15_TILE = '15'
        BROWN_CITY_15_UPGRADE_TILES = %w[X19 X20 X21].freeze
        GREEN_CITY_619_TILE = '619'
        BROWN_CITY_619_UPGRADE_TILES = %w[X22 X23 X24].freeze
        BROWN_CITY_TILES = %w[X16 X17 X18 X19 X20 X21 X22 X23 X24].freeze
        PARIS_TILES = %w[X1 X4 X5 X9 X10 X11 X12].freeze

        FRENCH_REGULAR_CORPORATIONS = %w[PLM Ouest Nord Est CFOR].freeze
        BELGIAN_REGULAR_CORPORATIONS = %w[AG Belge].freeze
        REGULAR_CORPORATIONS = FRENCH_REGULAR_CORPORATIONS + BELGIAN_REGULAR_CORPORATIONS
        FRENCH_LATE_CORPORATIONS = %w[LF].freeze
        BELGIAN_LATE_CORPORATIONS = %w[LB].freeze

        def stock_round
          G1894::Round::Stock.new(self, [
            G1894::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::Assign,
            Engine::Step::BuyCompany,
            G1894::Step::SpecialBuy,
            Engine::Step::HomeToken,
            G1894::Step::RedeemShares,
            G1894::Step::Track,
            G1894::Step::Token,
            G1894::Step::Route,
            G1894::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1894::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
            G1894::Step::UpdateTokens,
          ], round_num: round_num)
        end

        def plm
          corporation_by_id('PLM')
        end

        def ouest
          corporation_by_id('Ouest')
        end

        def nord
          corporation_by_id('Nord')
        end

        def est
          corporation_by_id('Est')
        end

        def cfor
          corporation_by_id('CFOR')
        end

        def french_starting_corporation
          corporation_by_id(@french_starting_corporation_id)
        end

        def sqg
          company_by_id('SQG')
        end

        def ls
          company_by_id('LS')
        end

        def starting_corporation_ids
          ['Belge', french_starting_corporation.id]
        end

        def setup
          @late_corporations, @corporations = @corporations.partition do |c|
            %w[LB LF].include?(c.id)
          end

          @last_or_set_triggered = false
          @skip_track_and_token = false

          @log << "-- Setting game up for #{@players.size} players --"

          @ferry_marker_ability =
            Engine::Ability::Description.new(type: 'description', description: 'Ferry marker',
                                             desc_detail: 'May access London (A10)')
          block_london

          paris_tiles = @all_tiles.select { |t| PARIS_TILES.include?(t.name) }
          paris_tiles.each { |t| t.add_reservation!(plm, 0) }

          @french_starting_corporation_id = FRENCH_REGULAR_CORPORATIONS.sort_by { rand }.take(1).first
          french_starting_corporation.add_ability(
            Engine::Ability::Description.new(type: 'description', description: 'May not redeem shares')
          )
          @log << "-- The French major shareholding corporation is the #{french_starting_corporation.id} --"
          remove_extra_french_major_shareholding_companies

          belgian_starting_corporation = corporation_by_id('Belge')

          remove_random_teleport_company
          teleport_company = @companies.find { |c| c.value == 50 && !c.closed? }
          @log << "-- The teleport company is #{teleport_company.name} --"

          @players.each do |player|
            share_pool.transfer_shares(french_starting_corporation.ipo_shares.last.to_bundle, player)
            share_pool.transfer_shares(belgian_starting_corporation.ipo_shares.last.to_bundle, player)
          end

          return unless @players.size == 3

          share_pool.transfer_shares(french_starting_corporation.ipo_shares.last.to_bundle, share_pool)
          share_pool.transfer_shares(belgian_starting_corporation.ipo_shares.last.to_bundle, share_pool)
        end

        def after_buy_company(player, company, price)
          # Nord share that comes with NMinorS transfered this way so the presidency doesn't change when the Nord is
          # the random French corporation and a player buys MNinorS
          if company.id == 'NMinorS'
            share_pool.transfer_shares(nord.ipo_shares.last.to_bundle, player, allow_president_change: false)
            @log << "#{player.name} receives a 10% share of Nord"
          end

          super
        end

        def init_round_finished
          @players.rotate!(@round.entity_index)
        end

        def init_stock_market
          StockMarket.new(self.class::MARKET, [:unlimited],
                          multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
        end

        def par_prices
          stock_market.par_prices.reject { |p| p.price == 100 }
        end

        def ipo_reserved_name(_entity = nil)
          'Treasury'
        end

        def next_round!
          @skip_track_and_token ||= (@last_or_set_triggered && (@round.instance_of? G1894::Round::Stock))

          super
        end

        def place_home_token(corporation)
          return if corporation.tokens.first&.used == true

          if [ouest, nord, cfor].include?(corporation)
            corporation.coordinates.each do |coordinate|
              hex = hex_by_id(coordinate)
              tile = hex&.tile
              if tile.color != :brown
                # Don't take the token that's alerady pending
                token = corporation.tokens.find { |t| !t.used && !@round.pending_tokens.find { |p_t| p_t[:token] == t } }
                tile.cities.first.place_token(corporation, token, free: true)
              else
                place_home_token_brown_tile(corporation, hex, tile)
              end
            end
            corporation.coordinates = [corporation.coordinates.first]
          else
            hex = hex_by_id(corporation.coordinates)
            tile = hex&.tile

            if tile.color == :brown
              place_home_token_brown_tile(corporation, hex, tile)
            else
              super
            end
          end

          # track actions are skipped in the final OR set, so graph must be reset here to take the home token into account
          @graph.clear if @skip_track_and_token
        end

        def place_home_token_brown_tile(corporation, hex, tile)
          city = tile.cities.find { |c| c.reserved_by?(corporation) }
          if city
            city.place_token(corporation, corporation.next_token, free: true)
          else
            @log << "#{corporation.name} must choose city for home token in #{hex.id}"
            @round.pending_tokens << {
              entity: corporation,
              hexes: [hex],
              token: corporation.next_token,
            }
          end
        end

        def event_late_corporations_available!
          @log << "-- Event: #{EVENTS_TEXT['late_corporations_available'][0]} --"
          @corporations.concat(@late_corporations)
          @late_corporations = []
        end

        def event_last_or_set_triggered!
          @log << "-- Event: #{EVENTS_TEXT['last_or_set_triggered'][0]} --"
          @last_or_set_triggered = true
        end

        TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: true, upgrade: :not_if_upgraded, cannot_reuse_same_hex: true },
        ].freeze

        def can_hold_above_corp_limit?(_entity)
          true
        end

        def action_processed(action)
          super

          case action
          when Action::PlaceToken
            # Mark the corporation that has London bonus
            if action.city.hex.id == LONDON_BONUS_FERRY_SUPPLY_HEX
              action.entity.owner.add_ability(
                Engine::Ability::Description.new(type: 'description', description: 'London bonus',
                                                 desc_detail: 'The value of London (A10) is increased,'\
                                                              ' for this corporation only,'\
                                                              ' by the largest non-London, non-Luxembourg revenue on the route.')
              )
              return
            end

            # If only one city tokenable, the reservation goes there
            tile = hex_by_id(action.city.hex.id).tile

            return unless BROWN_CITY_TILES.include?(tile.name)

            reservation = tile.reservations.first

            return unless reservation

            corporation = reservation.corporation

            if !tile.cities.first.tokenable?(corporation)
              tile.cities[1].add_reservation!(corporation)
            elsif !tile.cities[1].tokenable?(corporation)
              tile.cities.first.add_reservation!(corporation)
            else
              return
            end

            tile.reservations = []
          when Action::LayTile
            tile = hex_by_id(action.hex.id).tile

            if BROWN_CITY_TILES.include?(tile.name)
              # The city splits into two cities, so the reservation has to be for the whole hex
              reservation = tile.cities.first.reservations.first
              if reservation
                tile.cities.first.remove_all_reservations!
                tile.add_reservation!(reservation.corporation, nil, false)
              end

              # Clear all routes as they could be affected by the cities getting disjointed
              graph.clear_graph_for_all
            end

            return if action.hex.id != SQ_HEX || tile.color == :yellow

            case tile.color
            when :green
              sqg.revenue = 70
            when :brown
              sqg.revenue = 100
            end
            @log << "#{sqg.name}'s revenue increased to #{sqg.revenue}"
          end
        end

        def issuable_shares(entity)
          # If the corporation has more redeemed shares than are left in IPO
          return [] unless entity.num_ipo_reserved_shares > entity.num_ipo_shares - entity.num_ipo_reserved_shares

          bundle = Engine::ShareBundle.new(entity.reserved_shares)
          bundle.share_price = 100

          [bundle]
        end

        def redeemable_shares(entity)
          max_bundle_size = @round.round_num == 1 ? 2 : 1

          bundles_for_corporation(share_pool, entity)
            .reject { |bundle| bundle.shares.size > max_bundle_size || entity.cash < bundle.price }
        end

        def late_corporation_possible_home_hexes(corporation)
          possible_home_hexes = if FRENCH_LATE_CORPORATIONS.include?(corporation.name)
                                  FRENCH_LATE_CORPORATIONS_HOME_HEXES
                                else
                                  BELGIAN_LATE_CORPORATIONS_HOME_HEXES
                                end

          possible_home_hexes = possible_home_hexes.map { |coord| hex_by_id(coord) }.select do |hex|
            hex.tile.reservations.none? && hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) }
          end

          possible_home_hexes_without_track = possible_home_hexes.select { |h| h.tile.color == :white }
          possible_home_hexes = possible_home_hexes_without_track unless possible_home_hexes_without_track.none?

          raise GameError, 'No possible home location' if possible_home_hexes.nil?

          possible_home_hexes.map { |h| "#{location_name(h.name)} (#{h.id})" }
        end

        def late_corporation_home_hex(corporation, coordinates)
          corporation.coordinates = coordinates
          tile = hex_by_id(coordinates).tile

          return tile.add_reservation!(corporation, 1) if coordinates == PARIS_HEX

          return tile.add_reservation!(corporation, 0) if tile.color != :brown

          return tile.add_reservation!(corporation, 0) if [BRUXELLES_HEX, LILLE_HEX].include?(coordinates)

          # Tile is brown, non-Bruxelles, non-Lille
          if tile.cities.first.tokenable?(corporation) && !tile.cities[1].tokenable?(corporation)
            tile.add_reservation!(corporation, 0)
          elsif !tile.cities.first.tokenable?(corporation) && tile.cities[1].tokenable?(corporation)
            tile.add_reservation!(corporation, 1)
          else
            tile.add_reservation!(corporation, nil, false)
          end
        end

        def upgrades_to?(from, to, _special = false, selected_company: nil)
          return false if GREEN_CITY_TILES.include?(from.name) && @phase.current[:name] == 'Purple'

          return BROWN_CITY_14_UPGRADE_TILES.include?(to.name) if from.hex.tile.name == GREEN_CITY_14_TILE
          return BROWN_CITY_15_UPGRADE_TILES.include?(to.name) if from.hex.tile.name == GREEN_CITY_15_TILE
          return BROWN_CITY_619_UPGRADE_TILES.include?(to.name) if from.hex.tile.name == GREEN_CITY_619_TILE

          super
        end

        def save_tokens(tokens)
          @saved_tokens = tokens
          save_tokens_hex(nil) if tokens.nil? || tokens.empty?
        end

        def saved_tokens
          return [] if @saved_tokens.nil?

          @saved_tokens.sort_by { |t| operating_order.index(t[:entity]) }
        end

        def save_tokens_hex(hex)
          @saved_tokens_hex = hex
        end

        attr_reader :saved_tokens_hex

        def check_distance(route, _visits)
          if route.connection_hexes.flatten.include?(LONDON_HEX) && !ferry_marker?(current_entity)
            raise GameError, 'Cannot run to London without a Ferry marker'
          end

          raise GameError, 'Train visits Paris more than once' if route.hexes.count { |h| h.id == PARIS_HEX } > 1

          super
        end

        def revenue_for(route, stops)
          revenue = super
          revenue += luxembourg_value(route.corporation, stops)
          revenue += london_bonus(route.corporation, stops)
          revenue += netherlands_bonus(route.corporation, stops)

          revenue
        end

        def netherlands_bonus(_corporation, stops)
          return 0 unless stops.any? { |s| s.hex.id == NETHERLANDS_HEX }

          return 0 unless stops.any? { |s| NON_NETHERLANDS_OFFBOARDS.include?(s.hex.id) }

          100
        end

        def london_bonus(corporation, stops)
          london_bonus_city = hex_by_id(LONDON_BONUS_FERRY_SUPPLY_HEX).tile.cities.first

          return 0 if !london_bonus_city.tokened_by?(corporation) || stops.none? { |s| s.hex.id == LONDON_HEX }

          get_route_max_value(corporation, stops, ignore_london: true)
        end

        def luxembourg_value(corporation, stops)
          return 0 unless stops.any? { |s| s.hex.id == LUXEMBOURG_HEX }

          get_route_max_value(corporation, stops)
        end

        def get_route_max_value(_corporation, stops, ignore_london: false)
          revenues = stops.map { |s| get_current_revenue(s.revenue) }

          if ignore_london
            london_revenue = get_current_revenue(hex_by_id(LONDON_HEX).tile.cities.first.revenue)
            revenues.delete_at(revenues.index(london_revenue) || revenues.length)
          end

          revenues.max
        end

        def get_current_revenue(revenue)
          phase.tiles.reverse_each { |color| return (revenue[color]) if revenue[color] }

          0
        end

        def ferry_marker_available?
          hex_by_id(LONDON_BONUS_FERRY_SUPPLY_HEX).tile.icons.any? { |icon| icon.name == FERRY_MARKER_ICON }
        end

        def ferry_marker?(entity)
          return false unless entity.corporation?

          !ferry_markers(entity).empty?
        end

        def ferry_markers(entity)
          entity.all_abilities.select { |ability| ability.description == @ferry_marker_ability.description }
        end

        def connected_to_london?(entity)
          graph.reachable_hexes(entity).include?(hex_by_id(LONDON_HEX))
        end

        def get_ferry_marker_cost(entity)
          ls.owner == entity ? LS_FERRY_MARKER_COST : FERRY_MARKER_COST
        end

        def can_buy_ferry_marker?(entity)
          return false unless entity.corporation?

          ferry_marker_available? &&
            !ferry_marker?(entity) &&
            buying_power(entity) >= get_ferry_marker_cost(entity) &&
            connected_to_london?(entity)
        end

        def buy_ferry_marker(entity)
          return unless can_buy_ferry_marker?(entity)

          cost = get_ferry_marker_cost(entity)

          entity.spend(cost, @bank)
          entity.add_ability(@ferry_marker_ability.dup)
          @log << "#{entity.name} buys a ferry marker for $#{cost}"

          tile_icons = hex_by_id(LONDON_BONUS_FERRY_SUPPLY_HEX).tile.icons
          tile_icons.delete_at(tile_icons.find_index { |icon| icon.name == FERRY_MARKER_ICON })

          graph.clear
        end

        def block_london
          london = hex_by_id(LONDON_HEX).tile.cities.first
          london.instance_variable_set(:@game, self)

          def london.blocks?(corporation)
            !@game.ferry_marker?(corporation)
          end
        end

        def remove_random_teleport_company
          teleports = companies.find_all { |c| c.value == 50 }
          company = teleports.sort_by { rand }.take(1).first
          company.close!
          @round.steps.find { |s| s.is_a?(Engine::Step::WaterfallAuction) }.companies.delete(company)
        end

        def remove_extra_french_major_shareholding_companies
          major_shareholdings = companies.find_all { |c| c.value == 180 }

          major_shareholdings.each do |company|
            close_ability = company.abilities.find { |a| a.type == :close }

            next if close_ability.corporation == french_starting_corporation.id

            company.close!
            @round.steps.find { |s| s.is_a?(Engine::Step::WaterfallAuction) }.companies.delete(company)
          end
        end
      end
    end
  end
end
