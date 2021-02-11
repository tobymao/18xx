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

      STATUS_TEXT = Base::STATUS_TEXT.merge(
        'can_buy_trains' => ['Can buy trains', 'Can buy trains from other corporations'],
        'can_convert_concessions' => ['Can convert concessions', 'Can float a major company by converting a concession']
      ).freeze

      BIDDING_BOX_MINOR_COUNT = 4
      BIDDING_BOX_CONCESSION_COUNT = 3
      BIDDING_BOX_PRIVATE_COUNT = 3

      BIDDING_TOKENS = {
        "3": 6,
        "4": 5,
        "5": 4,
        "6": 3,
        "7": 3,
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

      MAJOR_TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }].freeze

      MINOR_START_PAR_PRICE = 50

      UPGRADABLE_S_YELLOW_CITY_TILE = '57'
      UPGRADABLE_S_YELLOW_CITY_TILE_ROTATIONS = [2, 5].freeze
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

      def can_par?(corporation, parrer)
        return false if corporation.type == :minor || !@phase.status.include?('can_convert_concessions')

        super
      end

      def can_run_route?(entity)
        entity.trains.any? { |t| t.name == 'L' } || super
      end

      def check_overlap(routes)
        super

        # Check local train not use the same token more then one time
        local_token_hex = []
        routes.each do |route|
          local_token_hex << route.head[:left].hex.id if route.train.local? && !route.connections.empty?
        end

        local_token_hex.group_by(&:itself).each do |k, v|
          raise GameError, "Local train can only use the token on #{k[0]} once." if v.size > 1
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

      def format_currency(val)
        return super if (val % 1).zero?

        format('£%.1<val>f', val: val)
      end

      def tile_lays(entity)
        return self.class::MAJOR_TILE_LAYS if @phase.name.to_i >= 3 && entity.corporation? && entity.type == :major

        super
      end

      def train_help(runnable_trains)
        return [] if (l_trains = runnable_trains.select { |t| t.name == 'L' }).empty?

        corporation = l_trains.first.owner
        ["L (local) trains run in a city which has a #{corporation.name} token.",
         'They can additionally run to a single small station, but are not required to do so. '\
         'They can thus be considered 1 (+1) trains.',
         'Only one L train may operate on each station token.']
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

      # TODO: [1822] Make include with 1861, 1867
      def operating_order
        minors, majors = @corporations.select(&:floated?).sort.partition { |c| c.type == :minor }
        minors + majors
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::G1822::FirstTurnHousekeeping,
          Step::BuyCompany,
          Step::G1822::Track,
          Step::G1822::DestinationToken,
          Step::G1822::Token,
          Step::Route,
          Step::G1822::Dividend,
          Step::DiscardTrain,
          Step::G1822::BuyTrain,
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

      def init_bidding_token
        self.class::BIDDING_TOKENS[@players.size.to_s]
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

      private

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
      end

      def setup_destinations
        self.class::DESTINATIONS.each do |corp, destination|
          ability = Ability::Base.new(
            type: 'destination',
            description: "Connect to #{destination} for your destination token."
          )
          corporation = corporation_by_id(corp)
          corporation.add_ability(ability)
          corporation.tokens << Engine::Token.new(corporation, logo: "/logos/1822/#{corp}_DEST.svg",
                                                               type: :destination)
          hex_by_id(destination).tile.icons << Part::Icon.new("../icons/1822/#{corp}_DEST", "#{corp}_destination")
        end
      end
    end
  end
end
