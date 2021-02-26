# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'step/buy_sell_par_shares'
require_relative 'step/draft'
require_relative 'step/track'
require_relative 'step/destinate'

module Engine
  module Game
    module G1873
      class Game < Game::Base
        include_meta(G1873::Meta)

        attr_reader :mine_12, :corporation_info, :minor_info, :mhe, :mine_graph, :reserved_tiles
        attr_accessor :premium, :premium_order

        register_colors(tan: '#d6a06c')

        CURRENCY_FORMAT_STR = '%dM'
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

        EBUY_PRES_SWAP = false # allow presidential swaps of other corps when ebuying
        EBUY_OTHER_VALUE = false # allow ebuying other corp trains for up to face
        HOME_TOKEN_TIMING = :float
        SELL_AFTER = :first
        SELL_BUY_ORDER = :sell_buy
        MARKET_SHARE_LIMIT = 80

        TRACK_RESTRICTION = :restrictive # FIXME: needs to be very_restrictive when implemented

        SELL_MOVEMENT = :down_share

        # there are special rules for mines, and RRs that need to complete their concession route
        TILE_LAYS = [{ lay: true, upgrade: true, cost: 0 },
                     { lay: :double_lay, upgrade: :double_lay, cost: 0 }].freeze

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
        MIN_BID_INCREMENT = 10
        MHE_START_PRICE = 120

        CONCESSION_TILES = {
          # HBE
          'B17' => { entity: 'HBE', tile: '78', exits: [0, 4], cost: 0 },
          # NWE
          'C8' => { entity: 'NWE', tile: '79', exits: [0, 3], cost: 150 },
          'D7' => { entity: 'NWE', tile: '956', exits: [0, 3], cost: 50 },
          'E6' => { entity: 'NWE', tile: '956', exits: [0, 3], cost: 50 },
          'H7' => { entity: 'NWE', tile: '78', exits: [2, 4], cost: 100 },
          'I8' => { entity: 'NWE', tile: '956', exits: [0, 3], cost: 150 },
          # WBE
          'C10' => { entity: 'WBE', tile: '78', exits: [2, 4], cost: 0 },
          'C12' => { entity: 'WBE', tile: '956', exits: [1, 4], cost: 0 },
          'C14' => { entity: 'WBE', tile: '76', exits: [1, 5], cost: 0 },
          'D15' => { entity: 'WBE', tile: '974', exits: [1, 2, 3, 5], cost: 0 },
          # SHE
          'F3' => { entity: 'SHE', tile: '956', exits: [0, 3], cost: 150 },
          'G2' => { entity: 'SHE', tile: '956', exits: [0, 3], cost: 150 },
          # KEZ
          'H3' => { entity: 'KEZ', tile: '78', exits: [3, 5], cost: 100 },
          # GHE
          'H19' => { entity: 'GHE', tile: '78', exits: [1, 3], cost: 150 },
        }.freeze

        STATE_NETWORK = %w[
         B9
         E20
         I2
        ].freeze

        DOUBLE_LAY_TILES = %w[
          77
          78
          79
          75
          76
          956
          957
          958
          959
          960
          961
          964
          965
          966
          967
          968
          969
          970
        ].freeze

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

          @mine_12 = @minors.find { |m| m.id == '12' }
          @mhe = @corporations.find { |c| c.id == 'MHE' }

          # float the MHE and move all shares into market
          @stock_market.set_par(@mhe, @stock_market.par_prices.find { |p| p.price == MHE_START_PRICE })
          @mhe.ipoed = true

          @mhe.ipo_shares.each do |share|
            @share_pool.transfer_shares(
              share.to_bundle,
              share_pool,
              spender: share_pool,
              receiver: @bank,
              price: 0
            )
          end
          @mhe.owner = @share_pool
          @mine_graph = Graph.new(self, home_as_token: true, no_blocking: true)
          @reserved_tiles = Hash.new { |h, k| h[k] = {} }
          @state_network_hexes = STATE_NETWORK.map { |h| hex_by_id(h) }
        end

        def init_graph
          Graph.new(self, skip_track: :broad)
        end

        def graph_for_entity(entity)
          entity.minor? ? @mine_graph : @graph
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
            if gc[:extended][:type] == :railway
              description = "Concession for Railway #{gc[:name]} in #{gc[:coordinates].join(', ')}. "\
               "Total concession tile cost: #{format_currency(gc[:extended][:concession_cost])}"
              name = "#{gc[:sym]} Concession"
            else
              description = "Purchase Option for Public Mining Company #{gc[:name]}"
              name = "#{gc[:sym]} Purchase Option"
            end
            Company.new(sym: gc[:sym], name: name, value: RAILWAY_MIN_BID, desc: description)
          end.compact
          mine_comps + corp_comps
        end

        def start_companies
          mine_ids = @minors.map(&:id)
          mine_comps = @companies.select { |c| mine_ids.include?(c.id) }

          corp_ids = @corporations.select do |corp|
            @corporation_info[corp][:type] == :railway && @corporation_info[corp][:concession_phase] == '1'
          end.map(&:id)
          corp_comps = @companies.select { |c| corp_ids.include?(c.id) }

          mine_comps + corp_comps
        end

        def auction_companies
          corp_ids = @corporations.select do |corp|
            next if corp == @mhe

            corp.receivership? || (railway?(corp) && @phase.available?(@corporation_info[corp][:concession_phase]))
          end.map(&:id)
          @companies.select { |c| corp_ids.include?(c.id) }
        end

        def company_header(company)
          if get_mine(company)
            'INDEPENDENT MINE'
          elsif @corporations.any? { |c| c.id == company.id && concession_pending?(c) }
            'CONCESSION'
          else
            'PURCHASE OPTION'
          end
        end

        def get_mine(company)
          @minors.find { |m| m.id == company.id }
        end

        def close_mine!(minor)
          @log << "#{minor.name} is closed"
          @minor_info[minor][:open] = false
          minor.owner = nil

          # flip token to closed side
          open_name = "#{minor.id}_open"
          closed_image = "1873/#{minor.id}_closed"
          @hexes.each do |hex|
            if (icon = hex.tile.icons.find { |i| i.name == open_name })
              hex.tile.icons[hex.tile.icons.find_index(icon)] = Part::Icon.new(closed_image, sticky: true)
            end
          end
        end

        def open_mine!(minor)
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
          @minors + @corporations
        end

        # mines that can be used to form a public mining company
        def open_private_mines
          @minors.select { |m| @players.include?(m.owner) && @minor_info[m][:open] }
        end

        # mines that can be merged into a public mining company
        def buyable_private_mines
          @minors.select { |m| !m.owner || @players.include?(m.owner) }
        end

        def corporation_available?(entity)
          return false unless entity.corporation?

          entity.ipoed || can_par?(entity, @round.active_step.current_entity)
        end

        def can_par?(corporation, player)
          return false if corporation.ipoed

          # see if player has corresponding concession (private)
          if @corporation_info[corporation][:type] == :railway
            player.companies.any? { |c| c.id == corporation.id }
          elsif !@corporation_info[corporation][:vor_harzer]
            @turn > 1
          else
            num_vh = @minors.count { |m| m.owner == player && @minor_info[m][:vor_harzer] }
            num_vh >= 1 && (@turn > 1 || @mine_12.owner == player)
          end
        end

        def form_button_text(_entity)
          'Form Public Mining Company'
        end

        def float_corporation(corporation)
          return if corporation == @mhe

          @log << "#{corporation.name} floats"

          num_ipo_shares = corporation.ipo_shares.size
          added_cash = num_ipo_shares * corporation.share_price.price

          replace_company!(corporation)

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
          return if corporation.tokens.first&.used
          return if public_mine?(corporation)
          return if corporation == @mhe

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

        # replace railway dummy concession company with a dummy purchase option company
        def replace_company!(corporation)
          return unless railway?(corporation)

          old_co = @companies.find { |c| c.id == corporation.id }
          description = "Purchase Option for Railway #{corporation_info[corporation][:name]}"
          sym = corporation_info[corporation][:sym]
          name = "#{sym} Purchase Options"
          @companies[@companies.find_index(old_co)] = Company.new(sym: sym, name: name,
                                                                  value: RAILWAY_MIN_BID, desc: description)
        end

        def independent_mine?(entity)
          entity.minor? && @corporations.none? { |c| c == entity.owner }
        end

        def public_mine?(entity)
          entity.corporation? && @corporation_info[entity][:type] == :mine
        end

        def railway?(entity)
          entity.corporation? && @corporation_info[entity][:type] == :railway
        end

        def concession_pending?(entity)
          entity.corporation? &&
            @corporation_info[entity][:type] == :railway &&
            @corporation_info[entity][:concession_pending]
        end

        def concession_incomplete?(entity)
          entity.corporation? &&
            @corporation_info[entity][:type] == :railway &&
            @corporation_info[entity][:concession_incomplete]
        end

        def concession_route_done?(entity)
          return true unless concession_incomplete?(entity)

          concession_hexes(entity).all? do |h|
            info = CONCESSION_TILES[h]
            (hex_by_id(h).tile.exits & info[:exits]).size == info[:exits].size
          end
        end

        def concession_hexes(entity)
          CONCESSION_TILES.keys.select { |h| CONCESSION_TILES[h][:entity] == entity.name }
        end

        def concession_complete!(entity)
          return unless concession_incomplete?(entity)

          @corporation_info[entity][:concession_incomplete] = false
          @log << "#{entity.name} has a complete concession route"
        end

        def concession_unpend!(entity)
          return unless concession_pending?(entity)

          @corporation_info[entity][:concession_pending] = false
          @log << "#{entity.name} has completed its concession requirements"
        end

        def advance_concession_phase!(entity)
          return unless concession_pending?(entity) && !(info = @corporation_info[entity])[:advanced]

          info[:concession_phase] = (info[:concession_phase].to_i - 1).to_s
          info[:advanced] = true
        end

        def connected_mine?(entity)
          entity.minor? && @minor_info[entity][:connected]
        end

        def init_round
          new_premium_round
        end

        def new_premium_round
          @log << '-- Start Auction Round --'
          G1873::Round::Auction.new(self, [
            G1873::Step::Premium,
          ])
        end

        # reorder based on premium passing order
        def reorder_players_start
          @players = @premium_order
          @log << "#{@players.first.name} has priority deal"
        end

        # reorder based on cash
        def reorder_players
          @players.sort_by!(&:cash).reverse!
          @log << "#{@players.first.name} has priority deal"
        end

        def new_start_auction_round
          G1873::Round::Auction.new(self, [
            G1873::Step::Draft,
          ])
        end

        # FIXME
        def new_auction_round
          @log << "-- #{round_description('Auction')} --"
          G1873::Round::Auction.new(self, [
            G1873::Step::ConcessionAuction,
          ])
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            G1873::Step::Form,
            G1873::Step::BuySellParShares,
          ])
        end

        # FIXME
        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            G1873::Step::Track,
            G1873::Step::Destinate,
            # Engine::Step::Token,
            # Engine::Step::Route,
            # Engine::Step::Dividend,
            # Engine::Step::BuyTrain,
          ], round_num: round_num)
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Auction
              if @premium_auction
                @premium_auction = false
                init_round_finished
                reorder_players_start
                new_start_auction_round
              else
                new_stock_round
              end
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              stock_round_finished
              reorder_players
              new_operating_round
            when Engine::Round::Operating
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

        def stock_round_finished
          @players.each do |p|
            p.companies.each do |c|
              c.owner = nil
              p.companies.delete(c)
              @log << "#{p.name} forfeits #{c.name}"
            end
          end
        end

        def operating_order
          open_private_mines + @corporations.select(&:floated?).sort
        end

        def concession_hex(hex)
          CONCESSION_TILES[hex.id]
        end

        # concession route in this hex
        def reserve_tile!(hex, tile)
          return false unless (ch = concession_hex(hex))

          # look for an upgrade to the tile being laid that has the exits
          # needed by the concession route
          res_tile = @tiles.find do |t|
            exits_match?(t.exits, tile.exits, ch[:exits]) &&
              upgrades_to?(tile, t) &&
              t.cities.size == tile.cities.size
          end

          return false unless res_tile

          add_tile_reservation!(hex, res_tile)
          res_tile
        end

        # see if exits_a contain exits_b and exits_c under some rotation
        def exits_match?(exits_a, exits_b, exits_c)
          6.times do |rot|
            rot_exits = rotate_exits(exits_a, rot)
            return true if (rot_exits & exits_b).size == exits_b.size && (rot_exits & exits_c).size == exits_c.size
          end
          false
        end

        def rotate_exits(exits, rot)
          exits.map { |e| (e + rot) % 6 }
        end

        def add_tile_reservation!(hex, tile)
          ch = concession_hex(hex)

          @log << "Reserving tile ##{tile.name} for #{ch[:entity]} concession route"

          # if there already is a reserved tile for this hex, make the old one available again
          @tiles << @reserved_tiles[hex.id][:tile] unless @reserved_tiles[hex.id].empty?

          @reserved_tiles[hex.id] = { tile: tile, entity: ch[:entity] }
          @tiles.delete(tile)
        end

        # If tile is in reservation hex and it completes the route there,
        # free the reservation
        # If it was a different tile that was reserved, put the reserved
        # tile back into the tile list
        def free_tile_reservation!(hex, tile)
          return if @reserved_tiles[hex.id].empty?

          puts 'found a reservation to free'

          ch = concession_hex(hex)
          return unless (ch[:exits] & tile.exits).size != ch[:exits].size

          @tiles << @reserved_tiles[hex.id][:tile] if @reserved_tiles[hex.id][:tile] != tile
          @reserved_tiles.delete(hex.id)
        end

        def double_lay?(tile)
          DOUBLE_LAY_TILES.include?(tile.name)
        end

        def upgrades_to?(from, to, special = false)
          # correct color progression?
          if !(reserved_tiles[from.hex.id] && reserved_tiles[from.hex.id][:tile] == to) &&
            (Engine::Tile::COLORS.index(to.color) != (Engine::Tile::COLORS.index(from.color) + 1))
            return false
          end

          # honors pre-existing track?
          return false unless from.paths_are_subset_of?(to.paths)

          # If special ability then remaining checks is not applicable
          return true if special

          # correct label?
          return false if from.label != to.label

          # old tile doesn't have a lock icon and it's not yet phase 3
          return false if !@phase.tiles.include?(:green) && from.icons.any? { |i| i.name == 'lock' }

          # honors existing town/city counts?
          # 1873: towns always upgrade to cities
          # 1873: single yellow cities can upgrate to single city or OO,
          #       except B-label tile is one city to one city
          # 1873: framed tiles can only upgrade to framed tiles
          return false if from.city_towns.empty? && !to.city_towns.empty?
          return false if !from.towns.empty? && from.towns.size != to.cities.size
          return false if !from.cities.empty? && to.cities.empty?
          return false if from.label.to_s == 'B' && from.cities.size != to.cities.size
          return false if (from.frame && !to.frame) || (!from.frame && to.frame)

          true
        end

        def check_mine_connected?(entity)
          return false unless entity.minor?
          return true if @minor_info[entity][:connected]

          @state_network_hexes.any? { |h| @mine_graph.reachable_hexes(entity)[h] }
        end

        def connect_mine!(entity)
          return unless entity.minor?

          old = @minor_info[entity][:connected]
          @minor_info[entity][:connected] = true
          @log << "Mine #{entity.name} is now connected to state railway network" unless old
        end

        # FIXME: take care of compulsory train
        def must_buy_train?(_entity)
          false
        end

        def sellable_bundles(player, corporation)
          return [] unless @round.active_step&.respond_to?(:can_sell?)

          bundles = bundles_for_corporation(player, corporation)
          if !corporation.operated? && corporation != @mhe
            sale_price = @stock_market.find_share_price(corporation, :left)
            bundles.each { |b| b.share_price = sale_price.price }
          end
          bundles.select { |bundle| @round.active_step.can_sell?(player, bundle) }
        end

        # rubocop:disable Lint/UnusedMethodArgument
        def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil)
          corporation = bundle.corporation
          price = corporation.share_price.price

          @share_pool.sell_shares(bundle, allow_president_change: pres_change_ok?(corporation), swap: swap)
          if corporation == @mhe
            bundle.num_shares.times do
              @stock_market.move_down(corporation)
            end unless @mhe.trains.any? { |t| t.name != '5T' }
          elsif corporation.operated?
            bundle.num_shares.times { @stock_market.move_down(corporation) }
          end
          log_share_price(corporation, price)
        end
        # rubocop:enable Lint/UnusedMethodArgument

        def pres_change_ok?(corporation)
          return false if corporation == @mhe

          public_mine?(corporation) || corporation.operated?
        end

        def get_machine(mine)
          mine.trains.find { |t| t.name.include? 'M' }
        end

        def get_switcher(mine)
          mine.trains.find { |t| t.name.include? 'S' }
        end

        def machine_size(mine)
          get_machine(mine)&.distance || 1
        end

        def switcher_size(mine)
          get_switcher(mine)&.distance
        end

        def maintenance_costs(_corp)
          0
        end

        def mine_revenue(corp)
          if corp.minor?
            m_revs = @minor_info[corp][:machine_revenue]
            s_revs = @minor_info[corp][:switcher_revenue]
            m_rev = m_revs[machine_size(corp) - 1]
            s_rev = switcher_size(corp) ? s_revs[switcher_size(corp) - 1] : 0
            @minor_info[corp][:connected] ? m_rev + s_rev : m_revs.first
          elsif public_mine?(corp)
            corporate_card_minors(corp).sum { |m| mine_revenue(m) } || 0
          else
            0
          end
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

        def corporation_view(corporation)
          if corporation.minor?
            'independent_mine'
          elsif public_mine?(corporation)
            'public_mine'
          end
        end

        def status_str(corporation)
          return if corporation == @mhe

          str = "Maintenance: #{format_currency(maintenance_costs(corporation))}"
          str += ' (Closed)' if corporation.minor? && !@minor_info[corporation][:open]
          str
        end

        def corporate_card_minors(corporation)
          @minors.select { |m| m.owner == corporation }
        end

        def player_card_minors(player)
          @minors.select { |m| m.owner == player }
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
            '78' => 'unlimited',
            '79' => 'unlimited',
            '75' => 4,
            '76' => 'unlimited',
            '956' => 'unlimited',
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
                connected: false,
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
                connected: false,
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
                connected: false,
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
                connected: false,
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
                connected: false,
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
                connected: false,
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
                connected: false,
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
                connected: false,
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
                connected: false,
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
                connected: false,
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
                connected: false,
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
                connected: false,
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
                connected: false,
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
                connected: false,
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
                vor_harzer: false,
                machine_revenue: [90, 120, 150, 180, 210],
                switcher_revenue: [60, 70, 80, 90],
                connected: true,
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
                type: :railway,
                concession_phase: '1',
                concession_routes: [%w[B19 B17 C16 D15]],
                concession_cost: 0,
                concession_pending: true,
                concession_incomplete: true,
                extra_tokens: 4,
                advanced: true,
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
                type: :railway,
                concession_phase: '1',
                concession_routes: [%w[G20 H19 G17 I18]],
                concession_cost: 150,
                concession_pending: true,
                concession_incomplete: true,
                extra_tokens: 3,
                advanced: true,
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
                type: :railway,
                concession_phase: '3',
                concession_routes: [%w[B9 C8 D7 E6 F5 G6], %w[G6 H7 H9 I8 J7]],
                concession_cost: 500,
                concession_pending: true,
                concession_incomplete: true,
                extra_tokens: 3,
                advanced: false,
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
                type: :railway,
                concession_phase: '3',
                concession_routes: [%w[E4 F3 G2 H1 I2]],
                concession_cost: 300,
                concession_pending: true,
                concession_incomplete: true,
                extra_tokens: 2,
                advanced: false,
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
                type: :railway,
                concession_phase: '3',
                concession_routes: [%w[G4 H3 I4]],
                concession_cost: 100,
                concession_pending: true,
                concession_incomplete: true,
                extra_tokens: 2,
                advanced: false,
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
                type: :railway,
                concession_phase: '4',
                concession_routes: [%w[B9 C10 C12 C14 D15]],
                concession_cost: 0,
                concession_pending: true,
                concession_incomplete: true,
                extra_tokens: 2,
                advanced: false,
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
                type: :railway,
                concession_phase: '4',
                concession_routes: [],
                concession_cost: 0,
                concession_pending: false,
                concession_incomplete: true,
                extra_tokens: 2,
                advanced: true,
              },
            },
            {
              sym: 'MHE',
              name: 'Magdeburg-Halberstädter Eisenbahn',
              logo: '1873/MHE',
              float_percent: 0,
              shares: [10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
              tokens: [],
              max_ownership_percent: 100,
              color: '#C0C0C0',
              text_color: 'black',
              extended: {
                type: :external,
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
                type: :mine,
                vor_harzer: false,
                slots: 2,
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
                type: :mine,
                vor_harzer: true,
                slots: 2,
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
                type: :mine,
                vor_harzer: false,
                slots: 2,
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
                type: :mine,
                vor_harzer: false,
                slots: 2,
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
                type: :mine,
                vor_harzer: false,
                slots: 2,
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
                'border=edge:4,type:impassible;frame=color:purple;'\
                'icon=image:1873/10_open,sticky:1',
              %w[
                D15
              ] => 'city=revenue:40,slots:2;path=a:1,b:_0,track:narrow;path=a:3,b:_0,track:narrow;'\
                'path=a:5,b:_0,track:narrow;label=B;frame=color:purple;'\
                'icon=image:1873/12_open,sticky:1',
              %w[
                E4
              ] => 'city=revenue:30;path=a:0,b:_0,track:narrow;upgrade=cost:50,terrain:mountain;'\
                'border=edge:3,type:impassible;frame=color:purple;'\
                'icon=image:1873/2_open,sticky:1',
              %w[
                F11
              ] => 'city=revenue:30;path=a:5,b:_0,track:narrow;upgrade=cost:50,terrain:mountain;'\
                'frame=color:purple;'\
                'icon=image:1873/SM_open,sticky:1',
              %w[
                G4
              ] => 'city=revenue:30;path=a:0,b:_0,track:narrow;upgrade=cost:50,terrain:mountain;'\
                'border=edge:1,type:impassible;border=edge:3,type:impassible;frame=color:purple;'\
                'icon=image:1873/14_open,sticky:1',
            },
            green: {
              %w[
                B19
              ] => 'city=revenue:60;path=a:1,b:_0,track:narrow;path=a:2,b:_0;path=a:5,b:_0;'\
                'frame=color:purple;label=HQG',
              %w[
                C16
              ] => 'city=revenue:30;path=a:0,b:_0,track:narrow;path=a:2,b:_0,track:narrow;'\
                'path=a:3,b:_0,track:narrow',
              %w[
                E20
              ] => 'city=revenue:60;path=a:1,b:_0,track:narrow;path=a:0,b:_0;path=a:3,b:_0;'\
                'frame=color:purple;label=HQG',
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
                'path=a:5,b:_0,track:narrow;frame=color:purple',
              %w[
                G20
              ] => 'city=revenue:60;path=a:0,b:_0,track:narrow;path=a:2,b:_0;path=a:5,b:_0;'\
                'frame=color:purple;label=HQG',
              %w[
                H13
              ] => 'city=revenue:40;path=a:2,b:_0,track:narrow;path=a:5,b:_0,track:narrow;'\
                'upgrade=cost:50,terrain:mountain;frame=color:purple',
              %w[
                H17
              ] => 'city=revenue:30;path=a:0,b:_0,track:narrow;path=a:4,b:_0,track:narrow;'\
                'path=a:5,b:_0,track:narrow;upgrade=cost:100,terrain:mountain;frame=color:purple',
            },
            gray: {
              %w[
                B9
              ] => 'city=slots:2,revenue:yellow_60|green_80|brown_120|gray_150;'\
                'path=a:1,b:_0;path=a:4,b:_0;path=a:0,b:_0,track:narrow;path=a:5,b:_0,track:narrow;'\
                'frame=color:purple',
              %w[
                B13
              ] => 'city=slots:2,revenue:yellow_30|green_70|brown_60|gray_60;'\
                'path=a:4,b:_0,track:narrow;path=a:5,b:_0,track:narrow;'\
                'frame=color:purple',
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
                'path=a:3,b:_0,track:narrow;path=a:4,b:_0;frame=color:purple;'\
                'icon=image:1873/15_open,sticky:1',
              %w[
                H9
              ] => 'city=revenue:30,slots:2;path=a:0,b:_0,track:narrow;'\
                'path=a:1,b:_0,track:narrow;path=a:4,b:_0,track:narrow;'\
                'icon=image:1873/SBH9_open,sticky:1',
              %w[
                I2
              ] => 'city=revenue:yellow_40|green_50|brown_80|gray_120;path=a:1,b:_0;'\
                'path=a:2,b:_0,track:narrow;path=a:4,b:_0;frame=color:purple',
              %w[
                I4
              ] => 'city=revenue:yellow_40|green_50|brown_80|gray_120;path=a:1,b:_0;'\
                'path=a:2,b:_0,track:narrow;path=a:5,b:_0;frame=color:purple',
              %w[
                I18
              ] => 'city=revenue:yellow_30|green_40|brown_60|gray_70;'\
                'path=a:2,b:_0,track:narrow;frame=color:purple;'\
                'icon=image:1873/13_open,sticky:1',
              %w[
                J7
              ] => 'city=revenue:yellow_60|green_80|brown_120|gray_180;path=a:1,b:_0;'\
                'path=a:3,b:_0,track:narrow;path=a:4,b:_0;frame=color:purple',
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
end
