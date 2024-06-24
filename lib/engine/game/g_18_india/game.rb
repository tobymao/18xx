# frozen_string_literal: true

require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative 'corporation'
require_relative 'player'
require_relative '../base'

module Engine
  module Game
    module G18India
      class Game < Game::Base
        include_meta(G18India::Meta)
        include Entities
        include Map
        include CitiesPlusTownsRouteDistanceStr

        attr_accessor :draft_deck, :ipo_pool, :unclaimed_commodities, :gauge_change_markers, :jewlery_hex
        attr_reader :ipo_rows

        register_colors(brown: '#a05a2c',
                        white: '#000000',
                        purple: '#5a2ca0')

        BANKRUPTCY_ALLOWED = false
        BANK_CASH = 9_000
        CURRENCY_FORMAT_STR = '₹%s'
        CAPITALIZATION = :incremental

        TRACK_RESTRICTION = :city_permissive
        TILE_TYPE = :lawson

        MARKET_SHARE_LIMIT = 200 # up to 200% of GIPR may be in market

        SELL_BUY_ORDER = :sell_buy
        MUST_SELL_IN_BLOCKS = false
        SELL_MOVEMENT = :none
        POOL_SHARE_DROP = :none
        SOLD_OUT_INCREASE = false
        NEXT_SR_PLAYER_ORDER = :first_to_pass
        COMPANY_SALE_FEE = 0

        HOME_TOKEN_TIMING = :float
        MUST_BUY_TRAIN = :never

        CERT_LIMIT = {
          2 => { 10 => 37, 9 => 33, 8 => 29 },
          3 => { 10 => 23, 9 => 22, 8 => 19 },
          4 => { 10 => 18, 9 => 17, 8 => 15 },
          5 => { 10 => 15, 9 => 13, 8 => 12 },
        }.freeze

        # Modified for corporation share limit
        def cert_limit(entity = nil)
          return @cert_limit if entity.nil?
          return 3 if entity.corporation?

          @cert_limit
        end

        # Modify to only count :private type companies (exclude Warrants and Bonds)
        def num_certs(entity)
          return 0 if entity.nil?

          shares = entity.player? ? entity.shares : entity.corporate_shares
          certs = shares.sum do |s|
            s.corporation.counts_for_limit && s.counts_for_limit ? s.cert_size : 0
          end
          certs + entity.companies.count { |c| c.type == :private }
        end

        STARTING_CASH = { 2 => 1100, 3 => 733, 4 => 550, 5 => 440 }.freeze

        GAME_END_CHECK = { bank: :full_or, stock_market: :current_or }.freeze

        MARKET = [
          %w[0c 56 58 61 64p 67p 71p 76p 82p 90p 100p 112p 126 142 160
             180 205 230 255 280 300 320 340 360 380 400e 420e 440e 460e],
        ].freeze

        PHASES = [
          {
            name: 'I',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
            status: %w[gipr_may_not_operate],
          },
          {
            name: 'II',
            on: '3',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
          { name: 'III', on: '4', train_limit: 2, tiles: %i[yellow green brown gray], operating_rounds: 2 },
          {
            name: "III'",
            on: '4-2',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
            status: %w[phase_four_trains],
          },
          {
            name: 'IV',
            on: %w[3x2 3x3 4x2 4x3],
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
            status: %w[warrants_expire convert_bonds no_gauge_change gauge_change_removal],
          },
        ].freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'gipr_may_not_operate' => ['GIPR may not operate', 'GIPR may not operate operate before phase II.'],
          'phase_four_trains' => ['Phase IV trains available', 'All Phase IV trains are simultaneously available.'],
          'warrants_expire' => ['Guaranty Warrants expire', 'Guaranty Warrants immediately expire.'],
          'convert_bonds' => ['May convert Railroad Bonds', 'May convert Railroad Bonds to a GIPR share as a stock action.'],
          'no_gauge_change' => ['Gauge Change no longer placed', 'Gauge Change markers are no longer placed with new track.'],
          'gauge_change_removal' => ['Gauge Change may be removed', 'Gauge Change markers may be removed as a track action.'],
        ).freeze

        VARIABLE_CITY_HEXES = %w[A16 D3 D23 G36 K30 K40 M10 Q10 R17].freeze
        VARIABLE_CITY_NAMES = %w[KARACHI LAHORE MUMBAI KOCHI CHENNAI COLOMBO NEPAL CHINA DHAKA].freeze

        COMMODITY_NAMES = %w[OIL ORE1 COTTON SPICES GOLD OPIUM TEA1 ORE2 TEA2 RICE JEWELRY].freeze
        COMMODITY_DESTINATIONS = %w[KARACHI LAHORE MUMBAI KOCHI CHENNAI COLOMBO NEPAL CHINA HALDIA VISAKHAPATNAM].freeze

        SPICE_BONUSES = {
          'KOCHI' => 70, # SPICES => KOCHI [G36] => 70,
          'COLOMBO' => 50, # SPICES => COLOMBO [K40] => 50,
          'CHENNAI' => 50, # SPICES => CHENNAI [K30] => 50,
          'LAHORE' => 40, # SPICES => LAHORE [D3] => 40,
          'MUMBAI' => 40, # SPICES => MUMBAI [D23] => 40,
          'CHINA' => 40, # SPICES => CHINA [Q10] => 40,
          'NEPAL' => 40, # SPICES => NEPAL [M10] => 40,
          'KARACHI' => 30, # SPICES => KARACHI [A16] => 30,
          'HALDIA' => 30, # SPICES => HALDIA [P19] => 30,
          'VISAKHAPATNAM' => 30, # SPICES => VISAKHAPATNAM [M24] => 30,
        }.freeze

        COMMODITY_BONUSES = {
          'OIL' => { value: 30, commodity: 'OIL', locations: ['MUMBAI'] }, # OIL => MUMBAI [D23] + 30
          'OPIUM' => { value: 100, commodity: 'OPIUM', locations: %w[LAHORE HALDIA] }, # OPIUM => LAHORE [D3] HALDIA [P19] => 100
          'ORE1' => { value: 50, commodity: 'ORE', locations: %w[KARACHI CHENNAI] }, # ORE => KARACHI [A16] CHENNAI [K30] => 50
          'ORE2' => { value: 50, commodity: 'ORE', locations: %w[KARACHI CHENNAI] },
          'GOLD' => { value: 50, commodity: 'GOLD', locations: ['KOCHI'] }, # GOLD => KOCHI [G36] + 50
          'COTTON' => { value: 40, commodity: 'COTTON', locations: %w[KARACHI CHENNAI] }, # KARACHI [A16] CHENNAI [K30] => 40
          'TEA1' => { value: 70, commodity: 'TEA', locations: ['VISAKHAPATNAM'] }, # TEA => VISAKHAPATNAM [M24] + 70
          'TEA2' => { value: 70, commodity: 'TEA', locations: ['VISAKHAPATNAM'] },
          'RICE' => { value: 30, commodity: 'RICE', locations: %w[CHINA NEPAL] }, # RICE => CHINA [Q10] NEPAL [M10] => 30
          'JEWELRY' => { value: 20, commodity: 'JEWELRY', locations: COMMODITY_DESTINATIONS },
          'SPICES' => { value: nil, commodity: 'SPICES', locations: COMMODITY_DESTINATIONS },
        }.freeze

        ASSIGNMENT_TOKENS = {
          'P6' => '/icons/18_india/jewlery.svg',
        }.freeze

        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false },
                     { lay: :not_if_upgraded, upgrade: false }, { lay: :not_if_upgraded, upgrade: false }].freeze

        EAST_GROUP = %w[BNR DHR EIR EBR NCR TR].freeze
        WEST_GROUP = %w[BR NWR PNS SPD WR].freeze
        SOUTH_GROUP = %w[CGR KGF MR NSR SIR WIP].freeze

        def corporation_removal_groups
          [EAST_GROUP, WEST_GROUP, SOUTH_GROUP]
        end

        CERT_DEALT = { 2 => 15, 3 => 13, 4 => 11, 5 => 10 }.freeze
        CERT_KEPT = { 2 => 8, 3 => 7, 4 => 6, 5 => 5 }.freeze
        IPO_CERTS_PER_ROW = { 2 => 18, 3 => 15, 4 => 13, 5 => 12 }.freeze

        # Use overridden clases
        PLAYER_CLASS = Player
        CORPORATION_CLASS = Corporation

        def certs_per_row
          IPO_CERTS_PER_ROW[@players.size]
        end

        def deal_to_player
          CERT_DEALT[@players.size]
        end

        def certs_to_keep
          CERT_KEPT[@players.size]
        end

        def ipo_name(_entity = nil)
          'IPO Pool'
        end

        def ipo_reserved_name(_entity = nil)
          'Player Hands'
        end

        # class to serve as a shareholder for the IPO Pool
        class ShareHolderEntity
          include Engine::Entity
          include Engine::ShareHolder
          include Engine::Spender

          attr_reader :name

          def initialize(name = nil)
            @name = name
            @cash = 0
          end

          def corporation?
            true
          end
        end

        # modified to use the separate shareholder for ipo_owner
        def init_corporations(stock_market)
          @ipo_pool = ShareHolderEntity.new('IPO')

          game_corporations.map do |corporation|
            self.class::CORPORATION_CLASS.new(
              ipo_owner: @ipo_pool,
              treasury_as_holding: true,
              min_price: stock_market.par_prices.map(&:price).min,
              capitalization: self.class::CAPITALIZATION,
              **corporation.merge(corporation_opts),
            )
          end
        end

        # Include IPO Pool shares and bond shares for cache_objects
        def shares
          LOGGER.debug { "@corporations.flat_map(&:shares) => #{@corporations.flat_map(&:shares)}" }
          LOGGER.debug { "@players.flat_map(&:shares) => #{@players.flat_map(&:shares)}" }
          LOGGER.debug { "@share_pool.shares => #{@share_pool.shares}" }
          LOGGER.debug { "gipr.bond_shares => #{gipr.bond_shares}" }
          LOGGER.debug { "@ipo_pool shares => #{@ipo_pool.shares}" }
          @ipo_pool.shares + @corporations.flat_map(&:shares) + @players.flat_map(&:shares) +
            @share_pool.shares + gipr.bond_shares
        end

        def setup_preround
          # remove random corporations based on regions, One from each group is Guaranty Company
          setup_corporations_by_region!(@corporations)

          # Set IPO prices for companies in game
          assign_initial_ipo_price(@corporations)

          # Build draw and draft decks for player hand and IPO rows
          @ipo_rows = [[], [], []]
          create_decks(@corporations)

          # Create Railroad Bonds
          create_railroad_bonds
        end

        def setup
          # remove tokens reserved by companies removed from game, can't be done in preround
          remove_closed_corp_tokens(@removals)

          @selection_finished = false
          @draft_finished = false
          @last_action = nil

          @unclaimed_commodities = COMMODITY_NAMES.dup
          @jewlery_hex = nil
          @gauge_change_markers = []

          @log << "-- #{round_description('Hand Selection')} --"
          @log << "Select #{certs_to_keep} Certificates for your starting hand"
        end

        def setup_corporations_by_region!(corporations)
          corps_to_remove = []
          guaranty_corps = []

          @log << 'Setup: Select 3 corporations per region, remove others. One Guaranty company per region.'
          corporation_removal_groups.each do |group|
            randomized_group = group.dup.sort_by { rand }
            corps_to_remove += randomized_group.take(group.count - 3) # remove all but 3 items from each region group
            guaranty_corps += [randomized_group.last] # Set the last randomized company as Guaranty Company
          end

          corporations.reject! do |corporation|
            if corps_to_remove.include?(corporation.name)
              corporation.close!
              yield corporation if block_given?
              @removals << corporation
              true
            elsif guaranty_corps.include?(corporation.name)
              assign_guaranty_warrant(corporation)
              false
            else
              false
            end
          end
          @log << "Corporations removed from game: #{@removals.map(&:name).sort.join(', ')}"
          @log << "Corporations in the game: #{@corporations.map(&:name).sort.join(', ')}"
          @log << "Guaranty Companies are #{guaranty_corps.join(', ')}"
        end

        # remove reservations for corporation at intial coordinates
        def remove_closed_corp_tokens(closed_corps)
          closed_corps.each do |corporation|
            hex = hex_by_id(corporation.coordinates)
            hex.tile.cities.each do |city|
              city.tokens.select { |t| t&.corporation == corporation }.each(&:remove!)
              city.reservations.delete(corporation) if city.reserved_by?(corporation)
            end
            hex.tile.reservations.delete(corporation) if hex.tile.reserved_by?(corporation)
          end
        end

        def assign_guaranty_warrant(corporation)
          warrant = Company.new(
            sym: 'GW',
            name: 'Guaranty Warrant',
            value: 0,
            desc: "Warrant pays 5\% of share value when company doesn't pay dividend. Closes at start of Phase IV",
            type: :warrant
          )
          warrant.owner = corporation
          corporation.companies << warrant
          @companies << warrant
        end

        def assign_initial_ipo_price(corporations)
          corporations.each do |corporation|
            ipo_price = @stock_market.par_prices.find { |p| p.price == corporation.min_price }
            @stock_market.set_par(corporation, ipo_price)
            corporation.ipoed = true
            # remove marker from Marker Chart, it will be palced on chart when it Floats
            corporation.share_price.corporations.delete(corporation)
          end
        end

        def create_decks(corporations)
          draw_deck = []
          draw_deck += @companies.reject { |c| c.type == :warrant }
          @draft_deck = []

          corporations.each do |corporation|
            corporation.ipo_shares.each do |share|
              card = convert_share_to_company(share)
              case share.percent
              when 20
                # set the share as reserved when in player hands
                card.treasury.buyable = false
                @draft_deck << card
              when 0
                # exclude the 0% manager's share
              else
                draw_deck << card
              end
              @companies << card
            end
          end

          draw_deck.sort_by! { rand }

          # deal part of deck to IPO rows
          deal_deck_to_ipo(draw_deck)
          # deal part of deck to player hands
          deal_deck_to_players(draw_deck)
          # send remainder to market and add funds to corps
          deal_deck_to_market(draw_deck)
        end

        # create a placeholder 'company' for shares in IPO or Player Hands
        def convert_share_to_company(share)
          discription = "Certificate for #{share.percent}\% of #{share.corporation.full_name}."
          discription += "\nConverts to DIRECTED company and Floats." if share.percent == 20
          discription += "\nHas a Guaranty Warrant." if share.corporation.guaranty_warrant?
          Company.new(
            sym: share.id,
            name: share.corporation.name,
            value: share.price,
            desc: discription,
            type: share.percent == 20 ? :president : :share,
            color: share.corporation.color,
            text_color: share.corporation.text_color,
            # reference to share in treasury
            treasury: share
          )
        end

        def deal_deck_to_ipo(deck)
          rows = [0, 1, 2]
          rows.each do |row|
            @ipo_rows[row] = deck.pop(certs_per_row)
          end
        end

        def deal_deck_to_players(deck)
          players.each do |player|
            cards = deck.pop(deal_to_player)
            cards.each do |c|
              # set buyable as false to mark as reserved when in player hands
              c.treasury.buyable = false if c.type == :share
            end
            player.hand = cards
          end
          deck
        end

        def deal_deck_to_market(deck)
          deck.each do |card|
            case card.type
            when :share
              # Use transfer shares method to control receiver of funds
              bundle = ShareBundle.new(card.treasury)
              share_pool.transfer_shares(bundle, @share_pool, spender: @bank, receiver: bundle.corporation, price: bundle.price)
            else
              @log << "Private #{card.name} is availabe in the Market"
              card.owner = @bank
              @bank.companies.push(card)
            end
          end
        end

        # Remove unselected cards from player hands and add them to draft deck
        def prepare_draft_deck
          @players.each do |player|
            cards = player.hand.dup
            cards.each do |card|
              if card.owner == player
                card.owner = nil
              else
                @draft_deck << card
                player.hand.delete(card)
              end
            end
          end
        end

        # shows value of companies on player card when in "unsold_companies"
        def show_value_of_companies?(_entity)
          true
        end

        def create_railroad_bonds
          10.times do |n|
            bond = make_bond(n)
            bond.owner = @bank
            @companies << bond
            @bank.companies << bond
          end
        end

        def make_bond(num)
          ident = 'RB' + num.to_s
          Company.new(
            sym: ident,
            name: 'Railroad Bond',
            value: 100,
            revenue: 10,
            desc: 'May be converted to a 10% share of GIPR in Phase IV. The conversion cost is market value minus 100.',
            color: :white,
            type: :bond
          )
        end

        # When converting a Railroad Bond, there is no refund if share price < 100
        def railroad_bond_convert_cost
          if gipr_share_price <= 100
            0
          else
            gipr_share_price - 100
          end
        end

        def gipr_share_price
          return 112 unless gipr.share_price

          gipr.share_price.price
        end

        def init_round
          selection_round
        end

        def selection_round
          selection_step = G18India::Step::CertificateSelection
          Engine::Round::Draft.new(self, [selection_step], reverse_order: false)
        end

        def draft_round
          draft_step = G18India::Step::Draft
          Engine::Round::Draft.new(self, [draft_step], reverse_order: false)
        end

        def stock_round
          # Test if home token step resolves issues of placing token when company floats
          Engine::Round::Stock.new(self, [
            G18India::Step::HomeTrack, # for GIPR Home Track / Token
            Engine::Step::HomeToken,
            G18India::Step::SellOnceThenBuyCerts,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            G18India::Step::HomeTrack, # for GIPR Home Track / Token
            Engine::Step::HomeToken,
            G18India::Step::ExchangeToken, # for GIPR Exchange Tokens
            G18India::Step::Assign, # used by P6
            G18India::Step::SpecialChoose, # Used by P4
            G18India::Step::SpecialTrack, # used by P2 & P3 (track lay & track upgrade)
            Engine::Step::SpecialToken, # use for P5
            G18India::Step::Track,
            G18India::Step::Token,
            G18India::Step::Route,
            G18India::Step::Dividend,
            G18India::Step::SellBuyTrain,
            G18India::Step::CorporateSellSharesCompany,
            G18India::Step::CorporateBuySharesCompany,
          ], round_num: round_num)
        end

        def operating_order
          corps = @corporations.select(&:floated?).sort
          gipr_may_operate? ? corps : corps.reject { |c| c.name == 'GIPR' }
        end

        def next_round!
          @round =
            case @round
            when Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
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
              if @selection_finished == false
                @selection_finished = true
                @log << "-- #{round_description('Draft')} --"
                @log << 'Draft certificates to add to your hand of reserved options'
                draft_round
              else
                reorder_players(:after_last_to_act, true)
                new_stock_round
              end
            end
        end

        def show_ipo_rows?
          true
        end

        def in_ipo?(company)
          @ipo_rows.flatten.include?(company)
        end

        def ipo_row_and_index(company)
          [0, 1, 2].each do |row|
            index = @ipo_rows[row].index(company)
            return [row, index] if index
          end
          nil
        end

        def ipo_remove(row, company)
          @ipo_rows[row].delete(company)
        end

        # Add status of cert card e.g. IPO ROW
        def company_status_str(company)
          if in_ipo?(company)
            _row, index = ipo_row_and_index(company)
            return "##{index + 1}"
          elsif (company.type == :bond) && (company.owner == @bank)
            return "Bank has #{count_of_bonds} / 10 Bonds"
          elsif @round.stock?
            return unless current_entity.player?
            return "Player's Hand" if current_entity.hand.include?(company)
          end
          ''
        end

        # Use to indicate corp status, e.g. managed vs directed companies
        def status_str(corporation)
          president = corporation.owner ? corporation.owner.name : 'none'
          if corporation.presidents_share.percent == 20
            "Directed Company: #{president}"
          elsif corporation == gipr && @phase.status.include?('gipr_may_not_operate')
            "GIPR doesn't operate until Phase II"
          elsif !corporation.owner.nil?
            "Managed Company: #{president}"
          else
            "Need manager & #{corporation.percent_to_float}% to float"
          end
        end

        # Timeline information for INFO tab
        def timeline
          timeline = []

          ipo_row_1 = ipo_timeline(0)
          timeline << "IPO ROW 1: #{ipo_row_1.join(', ')}" unless ipo_row_1.empty?

          ipo_row_2 = ipo_timeline(1)
          timeline << "IPO ROW 2: #{ipo_row_2.join(', ')}" unless ipo_row_2.empty?

          ipo_row_3 = ipo_timeline(2)
          timeline << "IPO ROW 3: #{ipo_row_3.join(', ')}" unless ipo_row_3.empty?

          timeline << "Market: #{bank.companies.map(&:name).join(', ')}" unless bank.companies.empty?

          timeline << "unclaimed_commodities: #{@unclaimed_commodities.sort.join(', ')}"

          @players.each do |p|
            timeline << "#{p.name}: #{p.hand.map(&:name).sort.join(', ')}" unless p.hand.empty?
          end

          timeline
        end

        def ipo_timeline(index)
          row = @ipo_rows[index]
          row.map do |company|
            "#{company.name}#{'*' if row.index(company) < 2}"
          end
        end

        # Called by View::Game::Entities to determine if the company should be shown on entities
        # Lists unowned companies under 'The Bank' on ENTITIES tab
        def unowned_purchasable_companies(_entity)
          bank_owned_companies
        end

        # Lists buyable companies for STOCK ROUND in VIEW
        def buyable_bank_owned_companies
          bank_owned_companies
        end

        def first_bond_in_bank
          Array(bank.companies.find { |c| c.type == :bond }).compact
        end

        def count_of_bonds
          bank.companies.count { |c| c.type == :bond }
        end

        def privates_in_bank
          bank.companies.select { |c| c.type == :private }
        end

        def bank_owned_companies
          first_bond_in_bank + privates_in_bank
        end

        def top_of_ipo_rows(row = nil)
          rows = row ? [row - 1] : [0, 1, 2]
          top = []
          rows.each do |r|
            top += @ipo_rows[r].first(2)
          end
          top
        end

        def show_hidden_hand?
          true
        end

        def hand_companies_for_stock_round
          return [] unless @round.stock?
          return [] if @round.current_entity.nil? || !@round.current_entity.player?

          @round.current_entity.hand.sort_by { |item| [item.type, -item.value, item.name] }
        end

        def remove_from_hand(player, company)
          player.hand.delete(company)
          player.unsold_companies.delete(company)
        end

        # remove all proxy certs from IPO and Player Hands
        def remove_proxy_certs(corporation)
          # remove from player hands
          players.each do |player|
            player.hand.reject! { |company| company.name == corporation.name }
            player.unsold_companies.reject! { |company| company.name == corporation.name }
          end
          # remove from IPO Rows
          @ipo_rows.each { |row| row.reject! { |company| company.name == corporation.name } }
          # remove from companies
          @companies.reject! { |company| company.name == corporation.name }
        end

        # prevents transfer of president's share before proxy is bought
        def can_swap_for_presidents_share_directly_from_corporation?
          false
        end

        def open_city_hexes
          @cities.reject { |c| c.available_slots.zero? }
                 .map { |c| c.tile.hex }
                 .compact
                 .uniq
        end

        def town_to_green_city_hexes
          @hexes.map(&:tile).select do |t|
            t.towns.one? && # only single town hexes
            %i[white yellow].include?(t.color) && # only white or yellow hexes
            !%w[K38 L39].include?(t.hex.name) # L39 and K38 are not legal hexes for a Green single city tile
          end.map(&:hex)
        end

        # Home hexes for GIPR
        def home_token_locations(corporation)
          raise NotImplementedError unless corporation.name == 'GIPR'

          LOGGER.debug { " Open City Hexes #{open_city_hexes}" }
          LOGGER.debug { " Town->City Hexes #{town_to_green_city_hexes}" }
          open_city_hexes + town_to_green_city_hexes
        end

        def place_home_token(corporation)
          return super unless corporation.name == 'GIPR'
          # If a corp has laid it's first token assume it's their home token
          return if corporation.tokens.first&.used

          # slect which hex to place home token
          @log << "#{corporation.name} (#{corporation.owner.name}) must choose Open City or Town tile for home location"
          hexes = home_token_locations(corporation)

          @round.pending_tokens << {
            entity: corporation,
            hexes: hexes,
            token: corporation.find_token_by_type,
          }

          @round.clear_cache!
        end

        # Modified to place share price marker on Market Chart
        def float_corporation(corporation)
          @log << "#{corporation.name} floats. Share price marker placed at #{corporation.share_price.price}"
          corporation.share_price.corporations << corporation
        end

        # Modified to allow yellow towns to be upgraded to SINGLE slot city green tiles
        # > Also modified legal_tile_rotation in STEP::Track or STEP::Tracker
        # Modified do prevent yellow cities upgrading to SINGLE slot city green tiles
        # Allow GIPR Home Track directly to Green Single City
        def upgrades_to?(from, to, special = false, selected_company: nil)
          return true unless @round.pending_tokens.empty?
          return true if yellow_town_to_city_upgrade?(from, to)
          return false if yellow_city_upgrade_is_single_slot_green?(from, to)

          super
        end

        def gipr
          @gipr ||= @corporations.find { |corp| corp.name == 'GIPR' }
        end

        def gipr_may_operate?
          !@phase.status.include?('gipr_may_not_operate') && gipr.floated?
        end

        def convert_bond_to_gipr(entity, bond)
          entity.companies.delete(bond)
          bond.close!
          new_gipr_share = gipr.bond_shares.shift
          new_gipr_share.owner = entity
          entity.shares_by_corporation[gipr] << new_gipr_share
          gipr.share_holders[entity] += new_gipr_share.percent
          entity.spend(railroad_bond_convert_cost, @bank) if railroad_bond_convert_cost.positive? # Pay conversion cost
          @bank.spend(bond.value, gipr) # Bank pays GIPR $100
          @log << "#{entity.name} converts a Railrod Bond to a GIPR Share for #{format_currency(railroad_bond_convert_cost)}"
          @log << "The Bank pays GIPR #{format_currency(bond.value)}"
          # Check if if there is new Manager for GIPR
          check_manager_change(entity, gipr) if entity.player?
        end

        def check_manager_change(entity, corporation)
          return unless entity.percent_of(corporation) > gipr.owner.percent_of(corporation)

          @share_pool.change_president(corporation.presidents_share, corporation.owner, entity)
          corporation.owner = entity
          @log << "#{entity.name} is the new Manager of #{corporation.name}"
        end

        def gipr_exchange_tokens
          ability = gipr.all_abilities.find { |a| a.type == :exchange_token }
          return 0 unless ability

          ability.count
        end

        def gipr_has_exchange_token?
          LOGGER.debug { "gipr_may_exchange_token > #{gipr.floated?} && #{gipr_exchange_tokens.positive?}" }
          gipr.floated? && gipr_exchange_tokens.positive?
        end

        def use_gipr_exchange_token
          ability = gipr.all_abilities.find { |a| a.type == :exchange_token }
          ability.use!
          ability.description = "Exchange tokens: #{ability.count}"
        end

        def gipr_exchange_with_closing_corp(corporation)
          corporation.placed_tokens.each_with_index do |token, index|
            LOGGER.debug { "gipr_exchange > #{corporation.tokens} && index-#{index} used-#{token.used}" }
            exchange_token = Engine::Token.new(gipr, type: :exchange)
            LOGGER.debug do
              "gipr_exchange > tokenable? #{token.city.tokenable?(gipr, free: true, tokens: [exchange_token],
                                                                        cheater: true, same_hex_allowed: false)} "
            end
            next unless token.city.tokenable?(gipr, free: true, tokens: [exchange_token], cheater: true, same_hex_allowed: false)

            if index.zero?
              token.swap!(exchange_token)
              @log << "GIPR replaced home token of #{corporation.name} with exchange token."
              gipr.tokens << exchange_token
              token.remove!
              use_gipr_exchange_token
              LOGGER.debug { "gipr_exchange > gipr tokens: #{gipr.tokens} " }
            elsif token.city.tokenable?(gipr, free: true, tokens: [exchange_token], cheater: true, same_hex_allowed: false)
              @round.pending_exchange_tokens << {
                entity: gipr,
                hexes: [token.hex],
                token: token,
                exchange_token: exchange_token,
              }
            end
          end
          LOGGER.debug { "gipr_exchange > pending #{@round.pending_exchange_tokens} " }
          @round.clear_cache!
        end

        def close_corporation(corporation, quiet: false)
          return unless @round.pending_exchange_tokens.empty?

          log << "#{corporation.name} closes" if !quiet && !@round.gipr_exchanging

          # GIPR exchange Tokens
          if gipr_has_exchange_token? && !corporation.placed_tokens.empty?
            gipr_exchange_with_closing_corp(corporation)
            @round.gipr_exchanging = true
            return
          end

          # remove all corp tokens (after GIPR may exchange)
          corporation.tokens.each(&:destroy!)
          LOGGER.debug { "closing > Corp tokens: #{corporation.tokens}" }

          # move trains to open market
          corporation.trains.dup.each { |t| depot.reclaim_train(t) }
          LOGGER.debug { "closing > Corp trains: #{corporation.trains}  depot: #{depot.trains}" }

          # return privates and bonds to market
          LOGGER.debug { "closing > companies: #{corporation.companies}  bank: #{@bank.companies}" }
          corporation.companies.each do |company|
            next unless %i[private bond].include?(company.type)

            @log << "#{company.name} is returned to the Market"
            company.owner = @bank
            @bank.companies.push(company)
          end
          corporation.companies.clear
          LOGGER.debug { "closing > companies: #{corporation.companies}  bank: #{@bank.companies}" }

          # move corp owned shares to open market
          corp_owned_shares = corporation.shares_by_corporation[corporation]
          LOGGER.debug { " > corp_owned_shares: #{corp_owned_shares}  share_pool: #{@share_pool.shares_by_corporation}" }
          corp_owned_shares.each do |shares|
            next if shares.corporation == corporation

            bundle = shares.is_a?(ShareBundle) ? shares : ShareBundle.new(shares)
            @log << "A #{bundle.percent}% share of #{bundle.corporation.name} is returned to the Market"
            share_pool.transfer_shares(bundle, @share_pool)
          end
          LOGGER.debug { " > corp_owned_shares: #{corp_owned_shares}  share_pool: #{@share_pool.shares_by_corporation}" }

          # return treasury to bank
          LOGGER.debug { " > prior tresury: #{corporation.cash}  bank: #{@bank.cash}" }
          corporation.spend(corporation.cash, @bank) if corporation.cash.positive?
          LOGGER.debug { " > post tresury: #{corporation.cash}  bank: #{@bank.cash}" }

          # remove all corp shares
          corporation.share_holders.each_key do |share_holder|
            share_holder.shares_by_corporation.delete(corporation)
          end
          @share_pool.shares_by_corporation.delete(corporation)
          corporation.share_price&.corporations&.delete(corporation)

          # remove proxy companies (without compensation as share value = 0)
          remove_proxy_certs(corporation)

          # close corporation
          @corporations.delete(corporation)
          corporation.close!

          # adjust cert_limit
          LOGGER.debug { " > prior cert_limit: #{@cert_limit}" }
          @cert_limit = init_cert_limit
          LOGGER.debug { " > post cert_limit: #{@cert_limit}" }

          # move to next entity if the current entity is the closed corporation
          @round.force_next_entity! if @round.current_entity == corporation
        end

        def yellow_town_to_city_upgrade?(from, to)
          case from.name
          when '3'
            %w[12 206 205].include?(to.name)
          when '4'
            %w[206 205].include?(to.name)
          when '58'
            %w[13 12 206 205].include?(to.name)
          else
            false
          end
        end

        def yellow_city_upgrade_is_single_slot_green?(from, to)
          %w[5 6 57].include?(from.name) && %w[12 13 205 206].include?(to.name)
        end

        # test using this to control laying yellow tiles from railhead
        def legal_tile_rotation?(_entity, _hex, _tile)
          true
        end

        # source for new "corporate_buy_company" view
        def corporate_purchasable_companies(_entity = nil)
          bank_owned_companies
        end

        # source for "buy_company" view
        # NOTE: needed for "selected_company" to work, see
        # https://github.com/tobymao/18xx/blob/d73abfefcb920e884882407cee70c56b0780cccc/assets/app/view/game/round/operating.rb#L41
        def purchasable_companies(_entity = nil)
          bank_owned_companies + top_of_ipo_rows
        end

        def companies_to_payout(ignore: [])
          (@players + @corporations).flat_map do |entity|
            entity.companies.select { |c| c.revenue.positive? && !ignore.include?(c.id) }
          end
        end

        # ----- Route Modificatons for Gauge Change stops (modifed from 1848)

        # Add gauge changes to visited stops, they count as 0 revenue City stops,
        def visited_stops(route)
          gauge_changes = border_crossings(route)
          route_stops = route.connection_data.flat_map { |c| [c[:left], c[:right]] }.uniq.compact # super
          return route_stops unless gauge_changes.positive?

          LOGGER.debug { "GAME::visited_stops > gauge_changes: #{gauge_changes} route_stops: #{route_stops.inspect}" }
          add_gauge_changes_to_stops(gauge_changes, route_stops)
        end

        def add_gauge_changes_to_stops(num, route_stops)
          gauge_changes = Array.new(num) { Engine::Part::City.new('0') }
          first_stop = route_stops.first
          gauge_changes.each do |stop|
            stop.tile = first_stop.tile
            route_stops.insert(1, stop) # add the gauge change after fist element so that it's not the first or last stop
          end
          LOGGER.debug { "GAME::add_gauge_changes_to_stops > route_stops: #{route_stops.inspect}" }
          route_stops
        end

        def border_crossings(route)
          sum = route.paths.sum do |path|
            path.edges.sum do |edge|
              edge_is_a_border?(edge) ? 1 : 0
            end
          end
          # edges are double counted
          sum / 2
        end

        def edge_is_a_border?(edge)
          edge.hex.tile.borders.any? { |border| border.edge == edge.num }
        end

        def add_gauge_change_marker(hex, neighbor)
          @gauge_change_markers << Array.new([hex, neighbor].sort)
        end

        def removed_gauge_change_marker(hex, neighbor)
          @gauge_change_markers.delete([hex, neighbor].sort)
        end

        # modify to require route begin and end at city and may not visit MUMBAI or NEPAL twice.
        def check_other(route)
          visited_stops = route.visited_stops
          return if visited_stops.count < 2

          valid_route = visited_stops.first.city? && visited_stops.last.city?
          raise GameError, 'Route must begin and end at a city' unless valid_route

          visited_names = visited_stops.map { |stop| stop.tile.location_name }
          raise GameError, 'Route may not visit MUMBAI more than once' if visited_names.count('MUMBAI') > 1
          raise GameError, 'Route may not visit NEPAL more than once' if visited_names.count('NEPAL') > 1
        end

        # modify to include variable value cities and route bonus
        def revenue_for(route, stops)
          stops.sum { |stop| stop.route_revenue(route.phase, route.train) } +
            variable_city_revenue(route, stops) +
            connection_bonus(route, stops) +
            commodity_bonus(route, stops)
        end

        def revenue_str(route)
          str = route.hexes.map(&:name).join('-')
          str += ' Gauge:' + border_crossings(route).to_s if border_crossings(route).positive?
          str += ' ?+' + variable_city_revenue(route, route.stops).to_s if variable_city_revenue(route, route.stops).positive?
          str += ' R+' + connection_bonus(route, route.stops).to_s if connection_bonus(route, route.stops).positive?
          str += ' C+' + commodity_bonus(route, route.stops).to_s if commodity_bonus(route, route.stops).positive?
          str
        end

        # consider for commodity bonus and route connection bonus?
        def extra_revenue(_entity, _routes)
          0
        end

        # calculate addional revenue if non-variable city base value > 20
        def variable_city_revenue(route, stops)
          non_variable_stops = route.visited_stops.reject { |stop| stop.revenue_to_render.zero? || stop.tile.color == 'red' }
          return 0 if non_variable_stops.empty?

          max_non_variable_value = non_variable_stops.map { |e| e.revenue_to_render - 20 }.max
          stop_location_names = stops.map { |stop| stop.tile.location_name }.compact
          variable_city_stops = stop_location_names & VARIABLE_CITY_NAMES

          train_multiplier = route.train.multiplier || 1
          LOGGER.debug do
            "variable_city_revenue >> train_multiplier: #{train_multiplier}  "\
              "variable_city_stops: #{variable_city_stops}  max_non_variable_value: #{max_non_variable_value}"
          end

          variable_city_stops.count * [max_non_variable_value, 0].max * train_multiplier
        end

        def connection_bonus(route, _stops)
          visited_location_names = route.visited_stops.map { |stop| stop.tile.location_name }.compact
          return 0 if visited_location_names.count < 2

          LOGGER.debug { "connection_bonus >> visited_location_names: #{visited_location_names}" }
          # Delhi, Kochi => 100 [G8, G36]
          # Karachi, Chennai => 80 [A16, K30]
          # Lahore, Kolkata => 80 [D3, P17]
          # Nepal, Mumbai => 70 [M10, D23]
          revenue = 0
          revenue += 100 if visited_location_names.include?('DELHI') && visited_location_names.include?('KOCHI')
          revenue += 80 if visited_location_names.include?('KARACHI') && visited_location_names.include?('CHENNAI')
          revenue += 80 if visited_location_names.include?('LAHORE') && visited_location_names.include?('KOLKATA')
          revenue += 70 if visited_location_names.include?('NEPAL') && visited_location_names.include?('MUMBAI')
          revenue
        end

        def available_commodities(corporation)
          @unclaimed_commodities + corporation.commodities
        end

        # Test using Ability to display Claimed Commodities on VIEW for Corporation card
        def claim_concession(corporation, commodity)
          LOGGER.debug { "claim_concession: #{corporation.name} => #{commodity}" }
          ability = corporation.all_abilities.find { |a| a.type == :commodities }
          ability.description = ability.description + commodity + ' '
          @log << "#{corporation.name} claims the #{commodity} concession"
          case commodity
          when 'ORE'
            corporation.commodities.concat(%w[ORE1 ORE2])
            %w[ORE1 ORE2].each { |c| @unclaimed_commodities.delete(c) }
          when 'TEA'
            corporation.commodities.concat(%w[TEA1 TEA2])
            %w[TEA1 TEA2].each { |c| @unclaimed_commodities.delete(c) }
          else
            corporation.commodities << commodity
            @unclaimed_commodities.delete(commodity)
          end
          LOGGER.debug { "  claimed: #{corporation.commodities}" }
          LOGGER.debug { "  unclaimed: #{@unclaimed_commodities}" }
        end

        # NOTE: Jewlery hex may be the same as another commodity, therefore should not use/change location name for Jewlery
        def assign_jewlery_location(hex)
          @jewlery_hex = hex
        end

        def visit_jewelery(route)
          route.all_hexes.include?(@jewlery_hex) ? ['JEWELRY'] : []
        end

        def commodity_bonus(route, _stops = nil)
          visited_names = (route.all_hexes.map(&:location_name) + visit_jewelery(route)).compact
          corporation = route.train.owner
          commodity_sources = visited_names & available_commodities(corporation)
          return 0 unless commodity_sources.count.positive?

          revenue = 0
          @round.commodities_used = []
          commodity_sources.each do |source|
            bonus = COMMODITY_BONUSES[source]
            LOGGER.debug { "GAME.commodity_bonus >> bonus: #{bonus}" }
            if visited_names.intersect?(bonus['locations'])
              revenue += bonus['value'] || visited_names.map { |loc| SPICE_BONUSES[loc] || 0 }.max
              @round.commodities_used << bonus['commodity']
            end
          end
          LOGGER.debug do
            "GAME.commodity_bonus >> visited: #{visited_names}  sources: #{commodity_sources}  revenue: #{revenue}" \
              "  used: #{@round.commodities_used}"
          end
          revenue
        end

        # Sell Train to the Depot
        def sell_train(operator, train, price)
          @bank.spend(price, operator) if price.positive?
          @depot.reclaim_train(train)
        end

        def after_end_of_operating_turn(operator)
          return unless operator.corporation?

          drop_price_for_trainless_corp(operator) if operator.trains.empty?
        end

        def drop_price_for_trainless_corp(corporation)
          old_price = corporation.share_price
          @log << "#{corporation.name} is trainless"
          @stock_market.move_left(corporation)
          log_share_price(corporation, old_price)
        end

        # pay owner value of company before closing
        def company_closing_after_using_ability(company, silent = false)
          @bank.spend(company.value, company.owner) if company.value.positive?
          @log << "#{company.name} closes and #{company.owner.name} receives #{company.value} from the Bank." unless silent
        end

        # Modified to select operator if company is player owned
        def token_owner(entity)
          return @round.current_operator if entity&.company? && entity.owner&.player? && @round.operating?

          entity&.company? ? entity.owner : entity
        end

        # modified to apply P4 discount if used
        def tile_cost_with_discount(_tile, _hex, _entity, spender, cost)
          return cost unless @round.respond_to?(:terrain_discount)
          return cost if cost.zero? || @round.terrain_discount.zero?

          discount = [cost, @round.terrain_discount].min
          company = @round.discount_source
          @round.terrain_discount -= discount
          @log << "#{spender.name} receives a discount of "\
                  "#{format_currency(discount)} from #{company.name}"

          cost - discount
        end

        def after_phase_change(name)
          return unless name == 'IV'

          @companies.each do |company|
            case company.type
            when :warrant
              # close Guaranty Warrants
              @log << "#{company.name} expires for #{company.owner.name}."
              company.close!
            when :president, :share
              # remove Guaranty Warrant text on proxies
              company.desc = company.desc.delete_suffix("\nHas a Guaranty Warrant.")
            end
          end
        end

        # Modified to include Book Value (assets) of corporations
        def player_value(player)
          player.shares.sum(player.value) { |s| s.corporation.book_value_per_share * s.num_shares }
        end

        def company_header(company)
          case company.type
          when :share
            'SHARE CERTIFICATE'
          when :president
            'DIRECTOR\'s CERTIFICATE'
          when :bond
            'RAILROAD BOND'
          when :warrant
            'GUARANTY WARRANT'
          else
            super
          end
        end

        def price_movement_chart
          [
            ['Action', 'Share Price Change'],
            ['End OR without train', '1 ←'],
            ['Dividend 0 or withheld', '1 ←'],
            ['Dividend < share price', 'none'],
            ['Dividend ≥ share price', '1 →'],
            ['Dividend ≥ 2x share price', '2 →'],
            ['Dividend ≥ 3x share price', '3 →'],
            ['Dividend ≥ 4x share price', '4 →'],
          ]
        end
      end
    end
  end
end
