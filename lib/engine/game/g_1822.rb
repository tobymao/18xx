# frozen_string_literal: true

require_relative '../config/game/g_1822'
require_relative 'base'
require_relative 'stubs_are_restricted'

module Engine
  module Game
    class G1822 < Base
      register_colors(lnwrBlack: '#000',
                      gwrGreen: '#165016',
                      lbscrYellow: '#cccc00',
                      secrOrange: '#ff7f2a',
                      crBlue: '#5555ff',
                      mrRed: '#ff2a2a',
                      lyrPurple: '#2d0047',
                      nbrBrown: '#a05a2c',
                      swrGray: '#999999',
                      nerGreen: '#aade87',
                      black: '#000',
                      white: '#ffffff')

      load_from_json(Config::Game::G1822::JSON)

      DEV_STAGE = :prealpha

      SELL_MOVEMENT = :down_share

      GAME_LOCATION = 'Great Britain'
      GAME_RULES_URL = 'http://google.com'
      GAME_DESIGNER = 'Simon Cutforth'
      GAME_PUBLISHER = :all_aboard_games
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1822'

      HOME_TOKEN_TIMING = :operate
      MUST_BUY_TRAIN = :always
      NEXT_SR_PLAYER_ORDER = :most_cash

      SELL_AFTER = :operate

      SELL_BUY_ORDER = :sell_buy

      EVENTS_TEXT = {
        'close_concessions' =>
          ['Concessions close', 'All concessions close without compensation, major companies now float at 50%'],
      }.freeze

      STATUS_TEXT = Base::STATUS_TEXT.merge(
        'can_buy_trains' => ['Buy trains', 'Can buy trains from other corporations'],
        'can_convert_concessions' => ['Convert concessions',
                                      'Can float a major company by converting a concession'],
        'can_acquire_minor_bidbox' => ['Acquire a minor from bidbox',
                                       'Can acquire a minor from bidbox for £200, must have connection '\
                                       'to start location'],
        'can_par' => ['Majors 50% float', 'Majors companies require 50% sold to float'],
        'full_capitalisation' => ['Full capitalisation', 'Majors receives full capitalisation '\
                                  '(the remaining five shares are placed in the bank)'],
      ).freeze

      BIDDING_BOX_MINOR_COUNT = 4
      BIDDING_BOX_CONCESSION_COUNT = 3
      BIDDING_BOX_PRIVATE_COUNT = 3

      BIDDING_TOKENS = {
        '3': 6,
        '4': 5,
        '5': 4,
        '6': 3,
        '7': 3,
      }.freeze

      BIDDING_TOKENS_PER_ACTION = 3

      COMPANY_CONCESSION_PREFIX = 'C'
      COMPANY_MINOR_PREFIX = 'M'
      COMPANY_PRIVATE_PREFIX = 'P'

      DESTINATIONS = {
        'LNWR' => 'I22',
        'GWR' => 'G36',
        'LBSCR' => 'M42',
        'SECR' => 'P41',
        'CR' => 'G12',
        'MR' => 'L19',
        'LYR' => 'I22',
        'NBR' => 'H1',
        'SWR' => 'C34',
        'NER' => 'H5',
      }.freeze

      EXCHANGE_TOKENS = {
        'LNWR' => 4,
        'GWR' => 3,
        'LBSCR' => 3,
        'SECR' => 3,
        'CR' => 3,
        'MR' => 3,
        'LYR' => 3,
        'NBR' => 3,
        'SWR' => 3,
        'NER' => 3,
      }.freeze

      # These trains don't count against train limit, they also don't count as a train
      # against the mandatory train ownership. They cant the bought by another corporation.
      EXTRA_TRAINS = %w[2P P+ LP].freeze
      EXTRA_TRAIN_PULLMAN = 'P+'
      EXTRA_TRAIN_PERMANENTS = %w[2P LP].freeze

      LIMIT_TOKENS_AFTER_MERGER = 9

      MAJOR_TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }].freeze

      MINOR_START_PAR_PRICE = 50
      MINOR_BIDBOX_PRICE = 200
      MINOR_GREEN_UPGRADE = %w[yellow green].freeze

      PRIVATE_COMPANIES_ACQUISITION = {
        'P1' => { acquire: %i[major], phase: 5 },
        'P2' => { acquire: %i[major minor], phase: 2 },
        'P3' => { acquire: %i[major], phase: 2 },
        'P4' => { acquire: %i[major], phase: 2 },
        'P5' => { acquire: %i[major], phase: 3 },
        'P6' => { acquire: %i[major], phase: 3 },
        'P7' => { acquire: %i[major], phase: 3 },
        'P8' => { acquire: %i[major minor], phase: 3 },
        'P9' => { acquire: %i[major minor], phase: 3 },
        'P10' => { acquire: %i[major minor], phase: 3 },
        'P11' => { acquire: %i[major minor], phase: 2 },
        'P12' => { acquire: %i[major minor], phase: 3 },
        'P13' => { acquire: %i[major minor], phase: 5 },
        'P14' => { acquire: %i[major minor], phase: 5 },
        'P15' => { acquire: %i[major minor], phase: 2 },
        'P16' => { acquire: %i[none], phase: 0 },
        'P17' => { acquire: %i[major], phase: 2 },
        'P18' => { acquire: %i[major], phase: 5 },
      }.freeze

      PRIVATE_MAIL_CONTRACTS = %w[P6 P7].freeze
      PRIVATE_REMOVE_REVENUE = %w[P6 P7].freeze
      PRIVATE_TRAINS = %w[P1 P3 P4 P13 P14].freeze

      TOKEN_PRICE = 100

      UPGRADABLE_S_YELLOW_CITY_TILE = '57'
      UPGRADABLE_S_YELLOW_ROTATIONS = [2, 5].freeze
      UPGRADABLE_S_HEX_NAME = 'D35'
      UPGRADABLE_T_YELLOW_CITY_TILES = %w[5 6].freeze
      UPGRADABLE_T_HEX_NAMES = %w[B43 K42 M42].freeze

      UPGRADE_COST_L_TO_2 = 80

      include StubsAreRestricted

      attr_accessor :bidding_token_per_player

      def all_potential_upgrades(tile, tile_manifest: false)
        upgrades = super
        return upgrades unless tile_manifest

        upgrades |= [@green_s_tile] if self.class::UPGRADABLE_S_YELLOW_CITY_TILE == tile.name
        upgrades |= [@green_t_tile] if self.class::UPGRADABLE_T_YELLOW_CITY_TILES.include?(tile.name)
        upgrades |= [@sharp_city, @gentle_city] if self.class::UPGRADABLE_T_HEX_NAMES.include?(tile.hex.name)

        upgrades
      end

      def can_hold_above_limit?(_entity)
        true
      end

      def can_par?(corporation, parrer)
        return false if corporation.type == :minor ||
          !(@phase.status.include?('can_convert_concessions') || @phase.status.include?('can_par'))

        super
      end

      def can_run_route?(entity)
        entity.trains.any? { |t| t.name == 'L' } || super
      end

      def check_overlap(routes)
        # Tracks by e-train and normal trains
        tracks_by_type = Hash.new { |h, k| h[k] = [] }

        # Check local train not use the same token more then one time
        local_token_hex = []

        routes.each do |route|
          local_token_hex << route.head[:left].hex.id if route.train.local? && !route.connections.empty?

          route.paths.each do |path|
            a = path.a
            b = path.b

            tracks = tracks_by_type[train_type(route.train)]
            tracks << [path.hex, a.num, path.lanes[0][1]] if a.edge?
            tracks << [path.hex, b.num, path.lanes[1][1]] if b.edge?

            if b.edge? && a.town? && (nedge = a.tile.preferred_city_town_edges[a]) && nedge != b.num
              tracks << [path.hex, a, path.lanes[0][1]]
            end
            if a.edge? && b.town? && (nedge = b.tile.preferred_city_town_edges[b]) && nedge != a.num
              tracks << [path.hex, b, path.lanes[1][1]]
            end
          end
        end

        tracks_by_type.each do |_type, tracks|
          tracks.group_by(&:itself).each do |k, v|
            raise GameError, "Route cannot reuse track on #{k[0].id}" if v.size > 1
          end
        end

        local_token_hex.group_by(&:itself).each do |k, v|
          raise GameError, "Local train can only use the token on #{k[0]} once." if v.size > 1
        end
      end

      def company_bought(company, entity)
        # On acquired abilities
        # Will add more here when they are implemented
        on_acquired_train(company, entity) if self.class::PRIVATE_TRAINS.include?(company.id)
        on_aqcuired_remove_revenue(company) if self.class::PRIVATE_REMOVE_REVENUE.include?(company.id)
      end

      def compute_other_paths(routes, route)
        routes.flat_map do |r|
          next if r == route || train_type(route.train) != train_type(r.train)

          r.paths
        end
      end

      def crowded_corps
        @crowded_corps ||= corporations.select do |c|
          trains = c.trains.count { |t| !extra_train?(t) }
          trains > train_limit(c)
        end
      end

      def discountable_trains_for(corporation)
        discount_info = super

        corporation.trains.select { |t| t.name == 'L' }.each do |train|
          discount_info << [train, train, '2', self.class::UPGRADE_COST_L_TO_2]
        end
        discount_info
      end

      def entity_can_use_company?(entity, company)
        # TODO: [1822] First pass on company abilities, for now only players can use powers. Will change this later
        entity.player? && entity == company.owner
      end

      def event_close_concessions!
        @log << '-- Event: Concessions close --'
        @companies.select { |c| c.id[0] == self.class::COMPANY_CONCESSION_PREFIX && !c.closed? }.each(&:close!)
        @corporations.select { |c| !c.floated? && c.type == :major }.each do |corporation|
          corporation.par_via_exchange = nil
          corporation.float_percent = 50
        end
      end

      def format_currency(val)
        return super if (val % 1).zero?

        format('£%.1<val>f', val: val)
      end

      def tile_lays(entity)
        return self.class::MAJOR_TILE_LAYS if @phase.name.to_i >= 3 && entity.corporation? && entity.type == :major

        super
      end

      def train_help(runnable_trains)
        return [] if runnable_trains.empty?

        entity = runnable_trains.first.owner

        # L - trains
        l_trains = !runnable_trains.select { |t| t.name == 'L' }.empty?

        # Destination bonues
        destination_token = nil
        destination_token = entity.tokens.find { |t| t.used && t.type == :destination } if entity.type == :major

        # Mail contract
        mail_contracts = entity.companies.any? { |c| self.class::PRIVATE_MAIL_CONTRACTS.include?(c.id) }

        help = []
        help << "L (local) trains run in a city which has a #{entity.name} token. "\
                'They can additionally run to a single small station, but are not required to do so. '\
                'They can thus be considered 1 (+1) trains. '\
                'Only one L train may operate on each station token.' if l_trains

        help << 'When a train runs between its home station token and its destination station token it doubles the '\
                'value of its destination station. This only applies to one train per operating '\
                'turn.' if destination_token

        help << 'Mail contract(s) gives a subsidy equal to one half of the base value of the start and end stations '\
                'from one of the trains operated. Doubled values (for E trains or destination tokens) '\
                'do not count.' if mail_contracts
        help
      end

      def init_company_abilities
        @companies.each do |company|
          next unless (ability = abilities(company, :exchange))
          next unless ability.from.include?(:par)

          exchange_corporations(ability).first.par_via_exchange = company
        end

        super
      end

      def init_round
        stock_round
      end

      def must_buy_train?(entity)
        !entity.rusted_self &&
          entity.trains.none? { |t| !extra_train?(t) } &&
          !depot.depot_trains.empty?
      end

      # TODO: [1822] Make include with 1861, 1867
      def operating_order
        minors, majors = @corporations.select(&:floated?).sort.partition { |c| c.type == :minor }
        minors + majors
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::G1822::FirstTurnHousekeeping,
          Step::AcquireCompany,
          Step::DiscardTrain,
          Step::G1822::Track,
          Step::G1822::DestinationToken,
          Step::G1822::Token,
          Step::Route,
          Step::G1822::Dividend,
          Step::G1822::BuyTrain,
          Step::G1822::MinorAcquisition,
          Step::DiscardTrain,
        ], round_num: round_num)
      end

      def place_home_token(corporation)
        return if corporation.tokens.first&.used

        super

        # Special for LNWR, it gets its destination token. But wont get the bonus until home
        # and destination is connected
        return unless corporation.id == 'LNWR'

        hex = hex_by_id(self.class::DESTINATIONS[corporation.id])
        token = corporation.find_token_by_type(:destination)
        place_destination_token(corporation, hex, token)
      end

      def purchasable_companies(entity = nil)
        return [] unless entity

        @companies.select do |company|
          company.owner&.player? && entity != company.owner && !company.closed? && !abilities(company, :no_buy) &&
            acquire_private_company?(entity, company)
        end
      end

      def revenue_for(route, stops)
        revenue = if train_type(route.train) == :normal
                    super
                  else
                    entity = route.train.owner
                    stops.sum do |stop|
                      next 0 unless stop.city?

                      stop.tokened_by?(entity) ? stop.route_revenue(route.phase, route.train) : 0
                    end
                  end
        destination_bonus = destination_bonus(route.routes)
        revenue += destination_bonus[:revenue] if destination_bonus && destination_bonus[:route] == route
        revenue
      end

      def revenue_str(route)
        str = super

        destination_bonus = destination_bonus(route.routes)
        if destination_bonus && destination_bonus[:route] == route
          str += " (#{format_currency(destination_bonus[:revenue])})"
        end

        str
      end

      def routes_subsidy(routes)
        return 0 if routes.empty?

        mail_bonus = mail_contract_bonus(routes.first.train.owner, routes)
        return 0 if mail_bonus.empty?

        mail_bonus.sum do |v|
          v[:subsidy]
        end
      end

      def setup
        # Setup the bidding token per player
        @bidding_token_per_player = init_bidding_token

        # Init all the special upgrades
        @sharp_city ||= @tiles.find { |t| t.name == '5' }
        @gentle_city ||= @tiles.find { |t| t.name == '6' }
        @green_s_tile ||= @tiles.find { |t| t.name == 'X3' }
        @green_t_tile ||= @tiles.find { |t| t.name == '405' }

        # Randomize and setup the companies
        setup_companies

        # Setup the fist bidboxes
        setup_bidboxes

        # Setup exchange token abilities for all corporations
        setup_exchange_tokens

        # Setup all the destination tokens, icons and abilities
        setup_destinations
      end

      def sorted_corporations
        ipoed, others = @corporations.select { |c| c.type == :major }.partition(&:ipoed)
        ipoed.sort + others
      end

      def stock_round
        Round::G1822::Stock.new(self, [
          Step::DiscardTrain,
          Step::G1822::BuySellParShares,
        ])
      end

      def upgrades_to?(from, to, special = false)
        # Check the S hex and potential upgrades
        if self.class::UPGRADABLE_S_HEX_NAME == from.hex.name && from.color == :white
          return self.class::UPGRADABLE_S_YELLOW_CITY_TILE == to.name
        end

        if self.class::UPGRADABLE_S_HEX_NAME == from.hex.name &&
          self.class::UPGRADABLE_S_YELLOW_CITY_TILE == from.name
          return to.name == 'X3'
        end

        # Check the T hexes and potential upgrades
        if self.class::UPGRADABLE_T_HEX_NAMES.include?(from.hex.name) && from.color == :white
          return self.class::UPGRADABLE_T_YELLOW_CITY_TILES.include?(to.name)
        end

        if self.class::UPGRADABLE_T_HEX_NAMES.include?(from.hex.name) &&
          self.class::UPGRADABLE_T_YELLOW_CITY_TILES.include?(from.name)
          return to.name == '405'
        end

        super
      end

      def acquire_private_company?(entity, company)
        company_acquisition = self.class::PRIVATE_COMPANIES_ACQUISITION[company.id]
        return false unless company_acquisition

        @phase.name.to_i >= company_acquisition[:phase] && company_acquisition[:acquire].include?(entity.type)
      end

      def bidbox_minors
        @companies.select do |c|
          c.id[0] == self.class::COMPANY_MINOR_PREFIX && (!c.owner || c.owner == @bank) && !c.closed?
        end.first(self.class::BIDDING_BOX_MINOR_COUNT)
      end

      def bidbox_concessions
        @companies.select do |c|
          c.id[0] == self.class::COMPANY_CONCESSION_PREFIX && (!c.owner || c.owner == @bank) && !c.closed?
        end.first(self.class::BIDDING_BOX_CONCESSION_COUNT)
      end

      def bidbox_privates
        @companies.select do |c|
          c.id[0] == self.class::COMPANY_PRIVATE_PREFIX && (!c.owner || c.owner == @bank) && !c.closed?
        end.first(self.class::BIDDING_BOX_PRIVATE_COUNT)
      end

      def can_gain_extra_train?(entity, train)
        if train.name == self.class::EXTRA_TRAIN_PULLMAN
          return false if entity.trains.any? { |t| t.name == self.class::EXTRA_TRAIN_PULLMAN }
        elsif self.class::EXTRA_TRAIN_PERMANENTS.include?(train.name)
          return false if entity.trains.any? { |t| self.class::EXTRA_TRAIN_PERMANENTS.include?(t.name) }
        end
        true
      end

      def calculate_destination_bonus(route)
        entity = route.train.owner
        # Only majors can have a destination token
        return nil unless entity.type == :major

        # Check if the corporation have placed its destination token
        destination_token = entity.tokens.find { |t| t.used && t.type == :destination }
        return nil unless destination_token

        # First token is always the hometoken
        home_token = entity.tokens.first
        token_count = 0
        route.visited_stops.each do |stop|
          next unless stop.city?

          token_count += 1 if stop.tokens.any? { |t| t == home_token || t == destination_token }
        end

        # Both hometoken and destination token must be in the route to get the destination bonus
        return nil unless token_count == 2

        { route: route, revenue: destination_token.city.route_revenue(route.phase, route.train) }
      end

      def destination_bonus(routes)
        return nil if routes.empty?

        # If multiple routes gets destination bonus, get the biggest one. If we got E trains
        # this is bigger then normal train.
        destination_bonus = routes.map { |r| calculate_destination_bonus(r) }.compact
        destination_bonus.sort_by { |v| v[:revenue] }.reverse&.first
      end

      def exchange_tokens(entity)
        ability = entity.all_abilities.find { |a| a.type == :exchange_token }
        return 0 unless ability

        ability.count
      end

      def extra_train?(train)
        self.class::EXTRA_TRAINS.include?(train.name)
      end

      def find_corporation(company)
        corporation_id = company.id[1..-1]
        corporation_by_id(corporation_id)
      end

      def init_bidding_token
        self.class::BIDDING_TOKENS[@players.size.to_s]
      end

      def mail_contract_bonus(entity, routes)
        mail_contracts = entity.companies.count { |c| self.class::PRIVATE_MAIL_CONTRACTS.include?(c.id) }
        return [] unless mail_contracts.positive?

        mail_bonuses = routes.map do |r|
          stops = r.visited_stops
          next if stops.size < 2

          first = stops.first.route_base_revenue(r.phase, r.train) / 2
          last = stops.last.route_base_revenue(r.phase, r.train) / 2
          { route: r, subsidy: first + last }
        end.compact
        mail_bonuses.sort_by { |v| v[:subsidy] }.reverse.take(mail_contracts)
      end

      def move_exchange_token(entity)
        remove_exchange_token(entity)
        entity.tokens << Engine::Token.new(entity, price: self.class::TOKEN_PRICE)
      end

      def on_aqcuired_remove_revenue(company)
        company.revenue = 0
      end

      def on_acquired_train(company, entity)
        train = @company_trains[company.id]

        unless can_gain_extra_train?(entity, train)
          raise GameError, "Cannot gain an extra #{train.name}, already have one"
        end

        buy_train(entity, train, :free)
        @log << "#{entity.name} gains a #{train.name} train"

        # Company closes after it is flipped into a train
        company.close!
        @log << "#{company.name} closes"
      end

      def place_destination_token(entity, hex, token)
        city = hex.tile.cities.first
        city.place_token(entity, token, free: true, check_tokenable: false, cheater: 0)
        hex.tile.icons.reject! { |icon| icon.name == "#{entity.id}_destination" }

        ability = entity.all_abilities.find { |a| a.type == :destination }
        entity.remove_ability(ability)

        @graph.clear

        @log << "#{entity.name} places its destination token on #{hex.name}"
      end

      def setup_bidboxes
        # Set the owner to bank for the companies up for auction this stockround
        bidbox_minors.each do |minor|
          minor.owner = @bank
        end

        bidbox_concessions.each do |concessions|
          concessions.owner = @bank
        end

        bidbox_privates.each do |company|
          company.owner = @bank
        end
      end

      def remove_exchange_token(entity)
        ability = entity.all_abilities.find { |a| a.type == :exchange_token }
        ability.use!
        ability.description = "Exchange tokens: #{ability.count}"
      end

      def train_type(train)
        train.name == 'E' ? :etrain : :normal
      end

      private

      def find_and_remove_train_by_id(train_id, buyable: true)
        train = train_by_id(train_id)
        @depot.remove_train(train)
        train.buyable = buyable
        train
      end

      def setup_companies
        # Randomize from preset seed to get same order
        @companies.sort_by! { rand }

        minors = @companies.select { |c| c.id[0] == self.class::COMPANY_MINOR_PREFIX }
        concessions = @companies.select { |c| c.id[0] == self.class::COMPANY_CONCESSION_PREFIX }
        privates = @companies.select { |c| c.id[0] == self.class::COMPANY_PRIVATE_PREFIX }

        # Always set the P1, C1 and M24 in the first biddingbox
        m24 = minors.find { |c| c.id == 'M24' }
        minors.delete(m24)
        minors.unshift(m24)

        c1 = concessions.find { |c| c.id == 'C1' }
        concessions.delete(c1)
        concessions.unshift(c1)

        p1 = privates.find { |c| c.id == 'P1' }
        privates.delete(p1)
        privates.unshift(p1)

        # Clear and add the companies in the correct randomize order sorted by type
        @companies.clear
        @companies.concat(minors)
        @companies.concat(concessions)
        @companies.concat(privates)

        # Set the min bid on the Concessions and Minors
        @companies.each do |c|
          case c.id[0]
          when self.class::COMPANY_CONCESSION_PREFIX, self.class::COMPANY_MINOR_PREFIX
            c.min_price = c.value
          else
            c.min_price = 0
          end
          c.max_price = 10_000
        end

        # Setup company abilities
        @company_trains = {}
        @company_trains['P3'] = find_and_remove_train_by_id('2P-0', buyable: false)
        @company_trains['P4'] = find_and_remove_train_by_id('2P-1', buyable: false)
        @company_trains['P1'] = find_and_remove_train_by_id('5P-0')
        @company_trains['P13'] = find_and_remove_train_by_id('P+-0', buyable: false)
        @company_trains['P14'] = find_and_remove_train_by_id('P+-1', buyable: false)
      end

      def setup_destinations
        self.class::DESTINATIONS.each do |corp, destination|
          description = if corp == 'LNWR'
                          "Gets destination token at #{destination} when floated."
                        else
                          "Connect to #{destination} for your destination token."
                        end
          ability = Ability::Base.new(
            type: 'destination',
            description: description
          )
          corporation = corporation_by_id(corp)
          corporation.add_ability(ability)
          corporation.tokens << Engine::Token.new(corporation, logo: "/logos/1822/#{corp}_DEST.svg",
                                                               type: :destination)
          hex_by_id(destination).tile.icons << Part::Icon.new("../icons/1822/#{corp}_DEST", "#{corp}_destination")
        end
      end

      def setup_exchange_tokens
        self.class::EXCHANGE_TOKENS.each do |corp, token_count|
          ability = Ability::Base.new(
            type: 'exchange_token',
            description: "Exchange tokens: #{token_count}",
            count: token_count
          )
          corporation = corporation_by_id(corp)
          corporation.add_ability(ability)
        end
      end
    end
  end
end
