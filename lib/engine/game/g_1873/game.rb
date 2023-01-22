# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'step/buy_sell_par_shares'
require_relative 'step/draft'
require_relative 'step/track'
require_relative 'step/destinate'
require_relative 'step/token'
require_relative 'step/reassign_switcher'
require_relative 'step/route'
require_relative 'step/dividend'
require_relative 'step/buy_mine'
require_relative 'step/buy_train'
require_relative 'step/convert'

module Engine
  module Game
    module G1873
      class Game < Game::Base
        include_meta(G1873::Meta)

        attr_reader :mine_12, :corporation_info, :diesel_graph, :hw, :minor_info, :mhe, :mine_graph, :nwe, :qlb,
                    :reserved_tiles, :subtrains
        attr_accessor :premium, :premium_order, :premium_winner, :reimbursed_hexes

        CURRENCY_FORMAT_STR = '%s ℳ'
        BANK_CASH = 100_000
        CERT_LIMIT = {
          2 => 999,
          3 => 999,
          4 => 999,
          5 => 999,
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
        MARKET_SHARE_LIMIT = 100
        SOLD_OUT_INCREASE = false
        MUST_BID_INCREMENT_MULTIPLE = true

        TRACK_RESTRICTION = :restrictive

        SELL_MOVEMENT = :down_share

        # there are special rules for mines, and RRs that need to complete their concession route
        TILE_LAYS = [{ lay: true, upgrade: true, cost: 0 },
                     { lay: :double_lay, upgrade: :double_lay, cost: 0 }].freeze

        GAME_END_CHECK = { stock_market: :current_or, custom: :one_more_full_or_set }.freeze

        GAME_END_REASONS_TEXT = Base::GAME_END_REASONS_TEXT.merge(
          custom: 'Phase 5 is entered'
        )

        RAILWAY_MIN_BID = 100
        MIN_BID_INCREMENT = 10
        MHE_START_PRICE = 120
        HW_BONUS = 50
        TOKEN_PRICE = 100
        STOP_REVENUE = 10
        DIESEL_STOP_REVENUE = 10

        DIESEL_POOL_HIGHWATER = 40
        DIESEL_POOL_LOWWATER = 20

        DIESEL_PRE_PHASE = '5'
        DIESEL_PURCHASE_ON = '5a'

        MAINTENANCE_BY_PHASE = {
          '1' => {},
          '2' => {},
          '3' => {
            '1M' => 50,
            '1T' => 50,
          },
          '4' => {
            '1M' => 100,
            '1T' => 100,
            '2M' => 50,
            '2S' => 20,
            '2T' => 100,
          },
          '5' => {
            '1M' => 100,
            '1T' => 100,
            '2M' => 50,
            '2S' => 20,
            '2T' => 100,
          },
          'D' => {
            '1M' => 150,
            '1T' => 150,
            '2M' => 100,
            '2S' => 50,
            '2T' => 150,
            '3M' => 50,
            '3S' => 30,
            '3T' => 150,
          },
        }.freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'remove_locks' => ['Unlock WBE Hexes', 'Tiles may be placed on WBE concession route'],
        ).freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'HBE_GHE_active' => ['HBE GHE available',
                               'HBE and GHE concessions become active'],
          'NWE_SHE_KEZ_may' => ['NWE SHE KEZ ?',
                                'NWE, SHE and KEZ concessions may be activated'],
          'NWE_SHE_KEZ_active' => ['NWE SHE KEZ available, WBE ?',
                                   'NWE, SHE and KEZ concessions become active; WBE may be activated'],
          'WBE_QLB_active' => ['WBE QLB available',
                               'WBE and QLB concessions become active'],
          'maintenance_level_1' => ['Level 1 Maintenance',
                                    '1M, 1T: 50 ℳ'],
          'maintenance_level_2' => ['Level 2 Maintenance',
                                    '1M, 1T, 2T: 100 ℳ | 2M: 50 ℳ | 2S: 20 ℳ'],
          'maintenance_level_3' => ['Level 3 Maintenance',
                                    '1M, 1T, 2T, 3T: 150 ℳ | 2M: 100 ℳ | 2S: 50 ℳ | 3M: 50 ℳ | 3S: 30 ℳ'],
          'end_of_game_trigger' => ['End of game triggered',
                                    'Game will end after 2nd full set of ORs after this'],
        ).freeze

        # tiles to be laid to complete concession
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
          'D15' => { entity: 'WBE', tile: '974', exits: [1, 2], cost: 0 }, # any of [1,3,5]and 2 will work
          # SHE
          'F3' => { entity: 'SHE', tile: '956', exits: [0, 3], cost: 150 },
          'G2' => { entity: 'SHE', tile: '956', exits: [0, 3], cost: 150 },
          # KEZ
          'H3' => { entity: 'KEZ', tile: '78', exits: [3, 5], cost: 100 },
          # GHE
          'H19' => { entity: 'GHE', tile: '78', exits: [1, 3], cost: 150 },
        }.freeze

        # exits on portions of concession routes without starting tokens
        CONCESSION_ROUTE_EXITS = {
          # HBE
          'B17' => [0, 4],
          'C16' => [0, 3], # preprinted tile
          # NWE
          'C8' => [0, 3],
          'D7' => [0, 3],
          'E6' => [0, 3],
          'F5' => [3, 5], # preprinted tile
          'H7' => [2, 4],
          'H9' => [0, 1], # preprinted tile
          'I8' => [0, 3],
          # WBE
          'C10' => [2, 4],
          'C12' => [1, 4],
          'C14' => [1, 5],
          # SHE
          'F3' => [0, 3],
          'G2' => [0, 3],
          # KEZ
          'H3' => [3, 5],
          # GHE
          'H17' => [4, 5], # preprinted tile
          'H19' => [1, 3],
        }.freeze

        FACTORY_INFO = {
          'B13' => { name: 'ZW', revenue: 70 },
          'C6' => { name: 'SB', revenue: 60 },
          'E18' => { name: 'PM', revenue: 40 },
          'F11' => { name: 'SM', revenue: 50 },
          'H9' => { name: 'SB', revenue: 50 },
        }.freeze

        STATE_NETWORK = %w[
         B9
         E20
         I2
        ].freeze

        LEGAL_75_DBL_UPGRADES = %w[914 964 967 968].freeze
        LEGAL_76_DBL_UPGRADES = %w[914 963 965 966 967 969].freeze
        LEGAL_956_DBL_UPGRADES = %w[968 969 970].freeze

        DOUBLE_LAY_TILES = %w[
          77
          78
          79
          75
          76
          914
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

        SWITCHER_PRICES = {
          2 => 50,
          3 => 100,
          4 => 150,
          5 => 200,
        }.freeze

        def location_name(coord)
          @location_names ||= game_location_names

          @location_names[coord]
        end

        def setup
          @premium = nil
          @premium_order = nil
          @premium_auction = true
          @premium_winner = nil
          @switcher_index = 0
          @machine_index = trains.size
          @next_switcher = nil

          @reimbursed_hexes = Hash.new { |h, k| h[k] = 0 }

          @subtrains = Hash.new { |h, k| h[k] = [] }
          @subtrain_index = {}
          game_trains.each { |gt| @subtrain_index[gt[:name]] = gt[:num] }
          @supertrains = {}

          @minor_info = load_minor_extended
          @corporation_info = load_corporation_extended

          @concession_route_corporations = {}
          @corporations.select { |c| concession_incomplete?(c) }.each do |rr|
            concession_routes(rr).flatten.each { |h| @concession_route_corporations[h] = rr }
          end

          @mine_12 = @minors.find { |m| m.id == '12' }
          @hw = @corporations.find { |c| c.id == 'HW' }
          @mhe = @corporations.find { |c| c.id == 'MHE' }
          @nwe = @corporations.find { |c| c.id == 'NWE' }
          @qlb = @corporations.find { |c| c.id == 'QLB' }
          @qlb_dummy_train = Train.new(name: '1T', distance: 1, price: 0, index: 2, no_local: true)

          init_diesel_pool

          # float the MHE and move all shares into market and give it a 1T
          @stock_market.set_par(@mhe, @stock_market.par_prices.find { |p| p.price == MHE_START_PRICE })
          @mhe.ipoed = true

          @mhe.ipo_shares.each do |share|
            @share_pool.transfer_shares(
              share.to_bundle,
              share_pool,
              spender: share_pool,
              receiver: @bank,
              price: 0,
              allow_president_change: false
            )
          end
          @mhe.owner = @share_pool
          buy_train(@mhe, @depot.trains.first, :free)
          @mhe.trains.first.buyable = false

          @mine_graph = Graph.new(self, home_as_token: true, no_blocking: true)

          # can only trace paths from concession route cities for diesel runs
          @diesel_graph = Graph.new(self, skip_track: :broad, check_tokens: true)

          @reserved_tiles = Hash.new { |h, k| h[k] = {} }
          @state_network_hexes = STATE_NETWORK.map { |h| hex_by_id(h) }
        end

        # used for laying tokens and running routes
        def init_graph
          Graph.new(self, skip_track: :broad)
        end

        # select graph for laying track
        def graph_for_entity(entity)
          entity.minor? ? @mine_graph : @graph
        end

        def load_minor_extended
          game_minors.to_h do |gm|
            minor = @minors.find { |m| m.name == gm[:sym] }
            [minor, gm[:extended]]
          end
        end

        def load_corporation_extended
          game_corporations.to_h do |cm|
            corp = @corporations.find { |m| m.name == cm[:sym] }
            [corp, cm[:extended]]
          end
        end

        # create "dummy" companies based on minors and railways
        def init_companies(_players)
          mine_comps = game_minors.map do |gm|
            description = "Mine in #{gm[:coordinates]}. Machine revenue: "\
                          "#{gm[:extended][:machine_revenue].join('/')}. Switcher revenue: "\
                          "#{gm[:extended][:switcher_revenue].join('/')}"
            revenue = "#{format_currency(gm[:extended][:machine_revenue].first)} - "\
                      "#{format_currency(gm[:extended][:machine_revenue].last + gm[:extended][:switcher_revenue].last)}"

            Company.new(sym: gm[:sym], name: "#{gm[:sym]} #{gm[:name]}", value: gm[:extended][:value],
                        revenue: revenue, desc: description)
          end
          corp_comps = game_corporations.map do |gc|
            next if gc[:sym] == 'MHE'

            if gc[:extended][:type] == :railway
              description = "Concession for Railway #{gc[:name]} in #{gc[:coordinates].join(', ')}. "\
                            "Total concession tile cost: #{format_currency(gc[:extended][:concession_cost])}"
              name = "#{gc[:sym]} Concession"
            else
              description = "Purchase Option for Public Mining Company #{gc[:name]}"
              name = "#{gc[:sym]} Purchase Option"
            end
            Company.new(sym: gc[:sym], name: name, value: RAILWAY_MIN_BID, revenue: 'NA', desc: description)
          end.compact
          mine_comps + corp_comps
        end

        def init_diesel_pool
          @diesel_pool = {}
          proto_train = @depot.trains.find { |t| diesel?(t) }
          DIESEL_POOL_HIGHWATER.times do
            create_pool_diesel(proto_train)
          end
          update_cache(:trains)
        end

        def create_pool_diesel(proto)
          new_train = Train.new(name: proto.name, distance: proto.distance, price: proto.price,
                                index: @subtrain_index[proto.name], no_local: true, reserved: true)
          new_train.owner = nil
          @depot.trains << new_train
          @diesel_pool[new_train] = { assigned: false, used: false }
          @subtrain_index[proto.name] += 1
        end

        def use_pool_diesel(train, entity)
          return unless @diesel_pool[train] # might not be from pool

          s_train = entity.trains.find { |t| diesel?(t) }
          @diesel_pool[train][:used] = true
          @diesel_pool[train][:allocated] = true
          @supertrains[train] = s_train
          @subtrains[s_train] << train
          @subtrains[s_train].uniq!

          num_available = @diesel_pool.values.count { |v| !v[:used] }
          return unless num_available < DIESEL_POOL_LOWWATER

          (DIESEL_POOL_HIGHWATER - num_available).times do
            create_pool_diesel(s_train)
          end
          update_cache(:trains)
        end

        def allocate_pool_diesel(train)
          s_train = @supertrains[train] || train

          new_train = @diesel_pool.keys.sort_by(&:id).find { |t| !@diesel_pool[t][:allocated] }
          @diesel_pool[new_train][:allocated] = true
          @supertrains[new_train] = s_train
          @subtrains[s_train] << new_train
          @subtrains[s_train].uniq!
          new_train
        end

        def unallocate_pool_diesel(entity, train)
          s_train = entity.trains.find { |t| diesel?(t) }
          return unless s_train
          return if train == s_train
          return unless @subtrains[s_train].include?(train)
          return unless @subtrains[s_train].size > 1 # always leave one allocated per supertrain
          return if @subtrains[s_train][0] == train # always leave the first
          return unless @diesel_pool[train]
          return unless @diesel_pool[train][:allocated]

          @diesel_pool[train][:allocated] = false
          @diesel_pool[train][:used] = false
          @subtrains[s_train].delete(train)
          @supertrains.delete(train)
        end

        def free_pool_diesels(entity)
          s_train = entity.trains.find { |t| diesel?(t) }
          return unless s_train
          return if @subtrains[s_train].one? # always leave one allocated per supertrain

          @subtrains[s_train].dup.each do |sub|
            next if !@diesel_pool[sub][:allocated] || @diesel_pool[sub][:used] || @subtrains[s_train].size <= 1

            @diesel_pool[sub][:allocated] = false
            @subtrains[s_train].delete(sub)
            @supertrains.delete(sub)
          end
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

            corp.receivership? || (railway?(corp) &&
                                   @phase.available?(@corporation_info[corp][:concession_phase]) &&
                                   !corp.ipoed)
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

        def company_revenue_str(company)
          company.revenue
        end

        def skip_token?(_graph, corporation, city)
          # diesel graph
          return false if corporation.coordinates.include?(city.hex.id) # never skip home tokens
          return true unless concession_routes(corporation).flatten.include?(city.hex.id)

          exits = CONCESSION_ROUTE_EXITS[city.hex.id]
          (city.exits & exits).size != exits.size # don't skip villages on concession route
        end

        def update_tokens(corporation, routes)
          return unless railway?(corporation)

          visited_tokens = {}

          routes.each do |route|
            route.hexes.each do |hex|
              hex.tile.stops.each do |node|
                next unless node.city?
                next unless route.node_signatures.include?(node.signature)

                node.tokens.each do |token|
                  next if !token || token.corporation != corporation

                  visited_tokens[token] = true
                end
              end
            end
          end

          route_hexes = (concession_routes(corporation).flatten + corporation.coordinates).uniq
          corporation.placed_tokens.each do |token|
            token.status = if visited_tokens[token] || route_hexes.include?(token.city.hex.id)
                             nil
                           else
                             :flipped
                           end
          end
        end

        def convert!(corporation)
          shares = @_shares.values.select { |share| share.corporation == corporation }

          corporation.share_holders.clear

          case corporation.total_shares
          when 2
            shares.each do |share|
              share.percent = 20
              corporation.share_holders[share.owner] += share.percent
            end
            new_shares = Array.new(3) { |i| Share.new(corporation, percent: 20, index: i + 2) }
            @corporation_info[corporation][:slots] = 4 if public_mine?(corporation)
            @log << "#{corporation.name} converts to a 5 share corporation"
          when 5
            shares.each do |share|
              share.percent = 10
              corporation.share_holders[share.owner] += share.percent
            end
            new_shares = Array.new(5) { |i| Share.new(corporation, percent: 10, index: i + 5) }
            @corporation_info[corporation][:slots] = 5 if public_mine?(corporation)
            increase_tokens!(corporation) if railway?(corporation)
            @log << "#{corporation.name} converts to a 10 share corporation"
          else
            raise GameError, 'Cannot convert 10 share corporation'
          end

          new_shares.each do |share|
            add_new_share(share)
          end
        end

        def add_new_share(share)
          owner = share.owner
          corporation = share.corporation
          corporation.share_holders[owner] += share.percent if owner
          owner.shares_by_corporation[corporation] << share
          @_shares[share.id] = share
        end

        def increase_tokens!(corporation)
          num_new_tokens = @corporation_info[corporation][:extra_tokens]
          new_tokens = Array.new(num_new_tokens) { |_i| Token.new(corporation, price: TOKEN_PRICE) }
          corporation.tokens.concat(new_tokens)
          @log << "#{corporation.name} receives #{num_new_tokens} more tokens"
        end

        def buy_train(operator, train, price = nil)
          old_owner = train.owner

          operator.spend(price || train.price, train_operator(train)) if price != :free
          remove_train(train)
          train.owner = operator
          operator.trains << train
          @crowded_corps = nil

          close_companies_on_event!(operator, 'bought_train')

          return unless old_owner == @depot

          add_switcher! if train_is_switcher?(train)
          add_subtrains!(train) if railway?(operator)
        end

        def mhe_buy_train
          return if !last_or_in_round || @mhe.trains.first.distance >= 5

          scrap_train(@mhe.trains.first)
          train = @depot.upcoming.first
          @log << "MHE buys a #{train.name} from bank"
          buy_train(@mhe, train, :free)
          phase.buying_train!(@mhe, train)
        end

        def scrap_train(train)
          return unless train

          @log << "#{train.owner.name} scraps #{train.name}"
          remove_train(train)
          train.owner = nil
        end

        def train_is_switcher?(train)
          train.name.include?('S')
        end

        def train_is_machine?(train)
          train.name.include?('M')
        end

        def train_is_train?(train)
          train.name.include?('T')
        end

        def add_subtrains!(train)
          return use_pool_diesel(allocate_pool_diesel(train), train_owner(train)) if diesel?(train)
          return unless train_is_train?(train)

          train = @supertrains[train] || train
          count = train.distance > 5 ? 1 : train.distance # only one diesel

          count.times do |idx|
            create_duplicate_train!(train, @subtrain_index[train.name] + idx)
          end
          @subtrain_index[train.name] += count
          update_cache(:trains)
        end

        def create_duplicate_train!(train, index)
          new_train = Train.new(name: train.name, distance: train.distance, price: train.price,
                                index: index, no_local: true, reserved: true)
          new_train.owner = nil
          @subtrains[train] << new_train
          @supertrains[new_train] = train
          @depot.trains << new_train
          new_train
        end

        # can't buy last train from railway (last 2+ train from NWE)
        def can_sell_train?(train)
          owner = train.owner
          return true unless railway?(owner)
          return true if owner == @qlb
          return true unless train_is_train?(train)

          if owner == @nwe && train.distance < 2
            true # nwe will always have a train besides a 1T
          elsif owner == @nwe
            owner.trains.count { |t| train_is_train?(t) && t.distance > 1 } > 1
          else
            owner.trains.count { |t| train_is_train?(t) } > 1
          end
        end

        def switcher_level
          @phase.name == 'D' ? 5 : @phase.name.delete('a').to_i
        end

        def switcher_price
          SWITCHER_PRICES[switcher_level]
        end

        # switchers don't come from the depot, they are made up on the fly
        def new_switcher
          return unless (level = switcher_level) > 1

          switcher = Train.new(name: "#{level}S", distance: level, price: switcher_price,
                               index: @switcher_index, reserved: true)
          switcher.owner = @depot
          @depot.trains << switcher # needed for train_by_id
          update_cache(:trains)
          switcher
        end

        def next_switcher
          delete_switcher if @next_switcher&.distance != switcher_level

          @next_switcher ||= new_switcher
        end

        def add_switcher!
          @switcher_index = @next_switcher.index + 1
          @next_switcher = nil
        end

        def delete_switcher
          return unless @next_switcher

          @depot.trains.delete(@next_switcher)
          @next_switcher = nil
        end

        # Return an array of N machines that match the original passed in (including the original)
        # These don't need to be added to the depot since they will never be referenced by an action
        def replicate_machines(train, count)
          t_array = [train]
          (count - 1).times do |_i|
            new_train = Train.new(name: train.name, distance: train.distance, price: train.price,
                                  index: @machine_index, reserved: true)
            @machine_index += 1
            t_array << new_train
          end
          t_array
        end

        def get_mine(company)
          @minors.find { |m| m.id == company.id }
        end

        def close_mine!(minor)
          @log << "#{minor.name} is closed"

          # any machines/switchers are trashed
          minor.trains.dup.each { |t| scrap_train(t) }

          if minor.owner && minor.cash.positive?
            @log << "#{minor.name} transfers #{format_currency(minor.cash)} to #{minor.owner.name}"
            minor.spend(minor.cash, minor.owner)
          end
          @minor_info[minor][:open] = false
          minor.owner = nil

          # flip token to closed side
          closed_image = "1873/#{minor.id}_closed"
          tile = hex_by_id(minor.coordinates).tile
          return unless (icon = tile.icons.find(&:large))

          tile.icons[tile.icons.find_index(icon)] =
            Part::Icon.new(closed_image, nil, true, nil, tile.preprinted, large: true, owner: nil)
        end

        # also used for ownership change
        def open_mine!(minor)
          @log << "#{minor.name} is opened" unless @minor_info[minor][:open]
          @minor_info[minor][:open] = true

          # flip token to open side
          open_image = "1873/#{minor.id}_open"
          tile = hex_by_id(minor.coordinates).tile
          return unless (icon = tile.icons.find(&:large))

          tile.icons[tile.icons.find_index(icon)] =
            Part::Icon.new(open_image, nil, true, nil, tile.preprinted, large: true, owner: minor.owner)
        end

        def insolvent!(entity)
          @log << "#{entity.name} is now Insolvent and will be recapitalized"
          deferred_president_change(entity) if concession_pending?(entity)

          # All stock in players' hands is returned to pool w/no compensation
          entity.player_share_holders.keys.each do |sh|
            next if sh.shares_of(entity).empty?

            bundle = ShareBundle.new(sh.shares_of(entity))
            @share_pool.transfer_shares(
              bundle,
              share_pool,
              spender: @bank,
              receiver: sh,
              price: 0
            )
            @log << "All shares of #{entity.name} held by #{sh.name} is forfeited to share pool"
          end
          entity.owner = @share_pool

          # Any shares in IPO are sold to pool at current price
          sell_ipo_shares(entity)

          r_cost = reorg_costs(entity)
          @log << "Reorganization cost = #{format_currency(r_cost)}" if r_cost.positive?

          # if there is insuffient cash to pay for reorg, up convert and sell shares to pool
          # repeat if needed
          while entity.cash < r_cost && entity.total_shares < 10
            convert!(entity)
            sell_ipo_shares(entity)
          end

          # free money! bank pays for reorg costs if corp can't
          # includes bonus price boost
          if (diff = r_cost - entity.cash).positive?
            @bank.spend(diff, entity)
            @log << "Bank pays #{format_currency(diff)} to #{entity.name}"
            old_price = entity.share_price
            if diff > old_price.price
              [(diff / old_price.price).to_i, 3].min.times { @stock_market.move_up(entity) }
              log_share_price(entity, old_price)
            end
          end

          # toss any trains that have maintenance costs
          if railway?(entity)
            entity.trains.dup.each { |t| scrap_train(t) if train_maintenance(t.name).positive? }
          else
            public_mine_mines(entity).each do |mine|
              mine.trains.dup.each do |t|
                scrap_train(t) if train_maintenance(t.name).positive?
              end
            end
          end

          # buy required trains
          if railway?(entity) && r_cost.positive?
            # railways need to buy next train
            buy_reorg_train(entity, 'T')
          elsif r_cost.positive?
            # public mines need to buy next one or two machines
            buy_reorg_machines(entity)
          end

          @log << "#{entity.name} has been recapitalized and reorganized and is in receivership"

          # finally, take care of any pending concession
          concession_unpend!(entity)
        end

        def sell_ipo_shares(entity)
          return if entity.ipo_shares.empty?

          @log << "#{entity.ipo_shares.size} IPO share(s) of #{entity.name} are transferred to share pool"
          entity.ipo_shares.each do |share|
            @share_pool.transfer_shares(
              share.to_bundle,
              share_pool,
              spender: @bank,
              receiver: entity
            )
          end
        end

        def reorg_costs(entity)
          if concession_pending?(entity)
            # RR that couldn't buy a train to run concession routes
            @depot.upcoming.first.variants.values.find { |v| v[:name].include?('T') }[:price]
          elsif railway?(entity)
            # it was a RR that couldn't afford maintenance costs
            return 0 if entity == @qlb # QLB never has to own a train
            return 0 if entity.trains.any? { |t| train_is_train?(t) && train_maintenance(t.name).zero? }

            @depot.upcoming.first.variants.values.find { |v| v[:name].include?('T') }[:price]
          else
            # it was a Public Mine that couldn't afford maintenance costs
            num_obsolete = public_mine_mines(entity)
              .count { |m| train_maintenance(machine(m)&.name || '1M').positive? }
            return 0 if num_obsolete.zero?

            cost = 0
            depot_idx = 0
            while num_obsolete.positive?
              num_obsolete -= @depot.upcoming[depot_idx].distance
              cost += @depot.upcoming[depot_idx].variants.values.find { |v| v[:name].include?('M') }[:price]
              depot_idx += 1
            end
            cost
          end
        end

        def buy_reorg_train(entity, type)
          train = @depot.upcoming.first
          variant = train.variants.values.find { |v| v[:name].include?(type) }
          price = variant[:price]
          train.variant = variant[:name]
          @log << "#{entity.name} buys a #{train.name} train for #{format_currency(price)} from depot"
          buy_train(entity, train, price)
          phase.buying_train!(entity, train)
          train
        end

        def buy_reorg_machines(entity)
          submines = public_mine_mines(entity)
          num_empty = submines.count { |m| !machine(m) }
          while num_empty.positive?
            new_machine = buy_reorg_train(entity, 'M')
            entity.trains.delete(new_machine) # PMCs don't own trains directly

            # fill empty slots first, then ones with smaller machines
            num_smaller = submines.count { |m| machine(m) && machine_size(m) < new_machine.distance }
            if num_empty >= new_machine.distance
              num_to_fill = new_machine.distance
              num_extra = 0
            elsif num_smaller >= (new_machine.distance - num_empty)
              num_to_fill = new_machine.distance
              num_extra = num_to_fill - num_empty
            else
              num_to_fill = num_empty + num_smaller
              num_extra = num_smaller
            end

            mine_trains = replicate_machines(new_machine, num_to_fill)
            [num_empty, num_to_fill].min.times do
              add_train_to_slot(entity, submines.find_index { |m| !machine(m) }, mine_trains.shift)
              num_empty -= 1
            end
            num_extra.times do
              replace_slot = submines.find_index { |m| machine_size(m) < new_machine.distance }
              add_train_to_slot(entity, replace_slot, mine_trains.shift) if replace_slot
            end
          end
        end

        def all_corporations
          @minors + @corporations
        end

        # mines that open and in players hands
        def open_private_mines
          @minors.select { |m| m.owner && @players.include?(m.owner) && mine_open?(m) }
        end

        # mines that can be merged to form a public mining company
        def mergeable_private_mines(entity)
          if entity == @hw
            @minors.select { |m| m.owner && @players.include?(m.owner) && @minor_info[m][:vor_harzer] }
          else
            @minors.select { |m| m.owner && @players.include?(m.owner) }
          end
        end

        # mines that can be bought by a public mining company
        def buyable_private_mines(entity)
          if entity == @hw
            @minors.select { |m| (!m.owner || @players.include?(m.owner)) && @minor_info[m][:vor_harzer] }
          else
            @minors.select { |m| !m.owner || @players.include?(m.owner) }
          end
        end

        def corporation_available?(entity)
          return false unless entity.corporation?
          return true if entity == @mhe
          return can_restart?(entity, @round.active_step.current_entity) if entity.receivership?

          entity.ipoed || can_par?(entity, @round.active_step.current_entity)
        end

        def can_restart?(corporation, player)
          return true if corporation == @mhe
          return false unless corporation.receivership?

          # see if player has corresponding purchase option (private) for corp
          player.companies.any? { |c| c.id == corporation.id }
        end

        def can_par?(corporation, player)
          return false if corporation.ipoed

          # see if player has corresponding concession (private) for RR
          if railway?(corporation)
            player.companies.any? { |c| c.id == corporation.id }
          elsif !@corporation_info[corporation][:vor_harzer]
            # if not vor-harzer, player must own at least one mine, and there must be one other available
            @turn > 1 && @minors.any? { |m| m.owner == player } && @minors.count(&:owner) > 1
          else
            num_total_vh = @minors.count { |m| m.owner && @minor_info[m][:vor_harzer] }
            num_player_vh = @minors.count { |m| m.owner == player && @minor_info[m][:vor_harzer] }
            num_total_vh >= 2 && num_player_vh >= 1 && (@turn > 1 || @mine_12.owner == player)
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
          return unless added_cash.positive?

          corporation.ipo_shares.each do |share|
            @share_pool.transfer_shares(
                share.to_bundle,
                share_pool,
                spender: share_pool,
                receiver: @bank,
                price: 0,
                allow_president_change: pres_change_ok?(corporation)
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
          description = "Purchase Option for Railway #{corporation.full_name}"
          sym = corporation.id
          name = "#{sym} Purchase Option"
          @companies.delete(old_co)
          @companies << Company.new(sym: sym, name: name, value: RAILWAY_MIN_BID, desc: description)
          update_cache(:companies)
        end

        def independent_mine?(entity)
          entity&.minor? && @corporations.none? { |c| c == entity.owner }
        end

        def public_mine?(entity)
          entity&.corporation? && @corporation_info[entity][:type] == :mine
        end

        def any_mine?(entity)
          entity&.minor? || (entity&.corporation? && @corporation_info[entity][:type] == :mine)
        end

        def railway?(entity)
          entity&.corporation? && @corporation_info[entity][:type] == :railway
        end

        # determine if a token lay is blocked by the need to keep a slot open
        # for a pending concession
        def concession_blocks?(city)
          hex = city.hex
          return false unless (exits = CONCESSION_ROUTE_EXITS[hex.id])
          return false unless concession_incomplete?(@concession_route_corporations[hex.id])
          # take care of OO tile. Only care about city along concession route
          return false if (city.exits & exits).empty?

          # if there is a reserved tile that has a city with the same connections
          # and with more slots than this tile, it doesn't block
          unless @reserved_tiles[hex.id].empty?
            r_city = @reserved_tiles[hex.id][:tile].cities.find { |c| !(c.exits & exits).empty? }
            return false if r_city && r_city.slots > city.slots
          end

          # must be two slots available for another RR to put a token here
          (city.slots - city.tokens.count { |c| c }) < 2
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

          # FIXME: need to check paths, not exits?
          concession_tile_hexes(entity).all? do |hex|
            info = CONCESSION_TILES[hex.id]
            (hex.tile.exits & info[:exits]).size == info[:exits].size
          end
        end

        def concession_tile_hexes(entity)
          CONCESSION_TILES.keys.select { |h| CONCESSION_TILES[h][:entity] == entity.name }.map { |h| hex_by_id(h) }
        end

        def concession_routes(entity)
          return unless railway?(entity)

          @corporation_info[entity][:concession_routes]
        end

        def concession_complete!(entity)
          return unless concession_incomplete?(entity)

          @corporation_info[entity][:concession_incomplete] = false
          @log << "#{entity.name} has a complete concession route"
        end

        def concession_unpend!(corporation)
          return unless concession_pending?(corporation)

          @corporation_info[corporation][:concession_pending] = false
          @log << "#{corporation.name} has completed its concession requirements"

          deferred_president_change(corporation)
        end

        # change president if needed
        def deferred_president_change(corporation)
          previous_president = corporation.owner
          max_shares = corporation.player_share_holders.values.max
          majority_share_holders = corporation.player_share_holders.select { |_, p| p == max_shares }.keys
          return if majority_share_holders.any? { |player| player == previous_president }

          president = majority_share_holders
            .select { |p| p.percent_of(corporation) >= corporation.presidents_percent }
            .min_by { |p| @share_pool.distance(previous_president, p) }
          return unless president

          corporation.owner = president
          @log << "#{president.name} becomes the president of #{corporation.name}"

          presidents_share = previous_president.shares_of(corporation).find(&:president)

          # swap shares so new president has president share
          @share_pool.change_president(presidents_share, previous_president, president)
        end

        def advance_concession_phase!(entity)
          return if !concession_pending?(entity) || (info = @corporation_info[entity])[:advanced]

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
          @players.sort_by! { |p| -p.cash }
          @log << '-- New player order: --'
          @players.each.with_index do |p, idx|
            pd = idx.zero? ? ' - Priority Deal -' : ''
            @log << "#{p.name}#{pd} (#{format_currency(p.cash)})"
          end
        end

        def new_start_auction_round
          G1873::Round::Auction.new(self, [
            G1873::Step::Draft,
          ])
        end

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

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            G1873::Step::Track,
            G1873::Step::Destinate,
            G1873::Step::Token,
            G1873::Step::ReassignSwitcher,
            G1873::Step::Route,
            G1873::Step::Dividend,
            G1873::Step::BuyMine,
            G1873::Step::BuyTrain,
            G1873::Step::Convert,
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
              if @phase.name == DIESEL_PRE_PHASE
                @phase.next!
                @depot.depot_trains(clear: true)
                @log << '-- Diesels now available --'
              end
              new_operating_round
            when Engine::Round::Operating
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
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

        def custom_end_game_reached?
          @phase.name == '5a' || @phase.name == 'D'
        end

        def last_or_in_round
          @round.round_num == @operating_rounds
        end

        def stock_round_finished
          @players.each do |p|
            p.companies.dup.each do |c|
              c.owner = nil
              p.companies.delete(c)
              @log << "#{p.name} forfeits #{c.name}"
            end
          end
        end

        def event_remove_locks!
          @hexes.each do |hex|
            if (icon = hex.tile.icons.find { |i| i.name == 'lock' })
              hex.tile.icons.delete(icon)
            end
          end
          @log << 'WBE concession hexes unlocked'
        end

        def operating_order
          open_private_mines + normal_corporations.select(&:floated?).sort + [@mhe]
        end

        def normal_corporations
          @corporations.reject { |c| @corporation_info[c][:type] == :external }
        end

        def concession_tile(hex)
          CONCESSION_TILES[hex.id]
        end

        # concession route in this hex
        def reserve_tile!(entity, hex, tile)
          return false unless (ch = concession_tile(hex))

          # look for an upgrade to the tile being laid that has the exits
          # needed by the concession route
          res_tile = @tiles.find do |t|
            next if t.name == tile.name

            tile_has_path_any_rotation?(entity, hex, tile, t, ch[:exits])
          end

          return false unless res_tile

          add_tile_reservation!(hex, res_tile)
          res_tile
        end

        # see if tile matches exits under some rotation
        def tile_has_path_any_rotation?(entity, hex, orig_tile, new_tile, exits)
          Engine::Tile::ALL_EDGES.each do |rot|
            new_tile.rotate!(rot)

            # only look at rotations where orig_tile and new_tile are compatible
            next unless legal_reservation_rotation?(entity, hex, orig_tile, new_tile)
            next unless upgrades_to?(orig_tile, new_tile)

            return true if tile_has_path?(new_tile, exits)
          end
          false
        end

        # see if new_tile has same paths as rotated orig_tile
        # - new exits don't run into illegal tiles/borders
        # - new exits are a superset of original tile
        # - new paths are a superset of original tile
        #
        # mostly the same as legal_rotation? in Tracker, but it doesn't reference graph
        def legal_reservation_rotation?(entity, hex, old_tile, new_tile)
          old_paths = old_tile.paths
          old_exits = old_tile.exits

          new_paths = new_tile.paths
          new_exits = new_tile.exits

          rval = new_exits.all? { |edge| hex.neighbors[edge] } &&
            (new_exits & old_exits).size == old_exits.size &&
            old_paths.all? { |path| new_paths.any? { |p| path <= p } }

          # ICK - remove ASAP
          rval_test = new_exits.all? { |edge| hex.neighbors[edge] } &&
            !(new_exits & hex_neighbors(entity, hex)).empty? &&
            old_paths.all? { |path| new_paths.any? { |p| path <= p } }

          raise GameError, 'Logic error. Please file a bug report.' if rval && !rval_test

          rval
        end

        def hex_neighbors(entity, hex)
          graph_for_entity(entity).connected_hexes(entity)[hex]
        end

        # determine if tile has direct or indirect path between given exits
        # Note: this assumes no intra-node paths or junctions (valid for 1873)
        def tile_has_path?(tile, exits)
          tile.paths.each do |path|
            if path.exits.size == 2
              # Case 1: simple path from edge to edge
              return true if (path.exits - exits).empty?
            elsif exits.include?(path.exits.first)
              # Case 2: path from edge to node => follow paths out of node
              target_exit = exits.find { |x| x != path.exits.first }
              node = path.nodes.first
              node.paths.each do |node_path|
                next if node_path == path

                return true if node_path.exits.first == target_exit
              end
            end
          end
          false
        end

        def rotate_exits(exits, rot)
          exits.map { |e| (e + rot) % 6 }
        end

        def add_tile_reservation!(hex, tile)
          ch = concession_tile(hex)

          @log << "Reserving tile ##{tile.name} for #{ch[:entity]} concession route in hex #{hex.id}"

          # if there already is a reserved tile for this hex, make the old one available again
          unless @reserved_tiles[hex.id].empty?
            @log << "Freeing reserved tile ##{@reserved_tiles[hex.id][:tile].name}"
            @tiles << @reserved_tiles[hex.id][:tile]
          end

          @reserved_tiles[hex.id] = { tile: tile, entity: ch[:entity] }
          @tiles.delete(tile)
        end

        # If tile is in reservation hex and it completes the route there,
        # free the reservation
        # If it was a different tile that was reserved, put the reserved
        # tile back into the tile list
        def free_tile_reservation!(hex, tile)
          return if @reserved_tiles[hex.id].empty?

          ch = concession_tile(hex)
          # FIXME: need to check paths, not exits?
          return unless (ch[:exits] & tile.exits).size == ch[:exits].size

          @log << "Freeing reserved tile ##{tile.name}"

          @tiles << @reserved_tiles[hex.id][:tile] if @reserved_tiles[hex.id][:tile] != tile
          @reserved_tiles.delete(hex.id)
        end

        def double_lay?(tile)
          DOUBLE_LAY_TILES.include?(tile.name)
        end

        def legal_doubletown_upgrade?(from, to)
          return true unless from.color == :yellow
          return true unless to.cities.size == 2

          # these are the only legal single city yellow to double city green upgrades
          (from.name == '75' && LEGAL_75_DBL_UPGRADES.include?(to.name)) ||
            (from.name == '76' && LEGAL_76_DBL_UPGRADES.include?(to.name)) ||
            (from.name == '956' && LEGAL_956_DBL_UPGRADES.include?(to.name))
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
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
          return false if !@phase.tiles.include?(:green) && from.icons.any? { |i| i.name.to_s == 'lock' }

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
          return false unless legal_doubletown_upgrade?(from, to)

          true
        end

        def check_mine_connected?(entity)
          return false unless entity.minor?
          return true if connected_mine?(entity)

          @state_network_hexes.any? { |h| @mine_graph.reachable_hexes(entity)[h] }
        end

        def connect_mine!(entity)
          return unless entity.minor?

          @log << "Mine #{entity.name} is now connected to state railway network" unless connected_mine?(entity)
          @minor_info[entity][:connected] = true
        end

        def must_buy_train?(entity)
          concession_pending?(entity)
        end

        def sellable_bundles(player, corporation)
          return [] unless @round.active_step.respond_to?(:can_sell?)

          bundles = bundles_for_corporation(player, corporation)
          if !corporation.operated? && corporation != @mhe
            sale_price = @stock_market.find_share_price(corporation, :left)
            bundles.each { |b| b.share_price = sale_price.price }
          end
          bundles.select { |bundle| @round.active_step.can_sell?(player, bundle) }
        end

        def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil)
          corporation = bundle.corporation
          old_price = corporation.share_price

          @share_pool.sell_shares(bundle, allow_president_change: pres_change_ok?(corporation), swap: swap)
          if corporation == @mhe
            unless @mhe.trains.any? { |t| t.name == '5T' }
              bundle.num_shares.times do
                @stock_market.move_down(corporation)
              end
            end
          elsif corporation.operated?
            bundle.num_shares.times { @stock_market.move_down(corporation) }
          else
            # force it last
            @stock_market.move_up(corporation)
            @stock_market.move_down(corporation)
          end
          log_share_price(corporation, old_price)
        end

        def pres_change_ok?(corporation)
          return false if corporation == @mhe

          !concession_pending?(corporation)
        end

        def machine(mine)
          mine.trains.find { |t| train_is_machine?(t) }
        end

        def machine_size(mine)
          machine(mine)&.distance || 1
        end

        def switcher(mine)
          mine.trains.find { |t| train_is_switcher?(t) }
        end

        def switcher_size(mine)
          switcher(mine)&.distance
        end

        def mhe_income
          @mhe.trains.first.distance * 100
        end

        def mine_open?(entity)
          entity.minor? && @minor_info[entity][:open]
        end

        def mine_face_value(entity)
          return 0 unless entity.minor?

          @minor_info[entity][:value]
        end

        def any_slot_available?(entity)
          return false unless public_mine?(entity)

          @corporation_info[entity][:slots] > @corporation_info[entity][:mines].size
        end

        def public_mine_slots(entity)
          return 0 unless public_mine?(entity)

          @corporation_info[entity][:slots]
        end

        def public_mine_mines(entity)
          return [] unless public_mine?(entity)

          @corporation_info[entity][:mines]
        end

        def add_train_to_slot(entity, slot, train)
          mine = public_mine_mines(entity)[slot]
          if train_is_machine?(train) && (old_machine = machine(mine))
            scrap_train(old_machine)
          elsif train_is_switcher?(train) && (old_switcher = switcher(mine))
            scrap_train(old_switcher)
          end
          train.owner = mine
          mine.trains << train
          @log << "Adding #{train.name} to slot #{slot} of #{entity.name} (Mine #{mine.name})"
        end

        def get_slot(entity, sub)
          return unless public_mine?(entity)

          public_mine_mines(entity).find_index(sub)
        end

        def swap_switchers(entity, slots)
          mine_a = public_mine_mines(entity)[slots.first]
          mine_b = public_mine_mines(entity)[slots.last]

          train_a = switcher(mine_a)
          train_b = switcher(mine_b)

          raise GameError, 'No switchers in either mine' if !train_a && !train_b

          half_swap(train_a, mine_a, mine_b) if train_a
          half_swap(train_b, mine_b, mine_a) if train_b

          @log << if train_a && train_b
                    "#{entity.name} swaps #{train_a.name} from #{mine_a.name} with #{train_b.name}"\
                      "from #{mine_b.name}"
                  elsif train_a
                    "#{entity.name} moves #{train_a.name} from #{mine_a.name} to #{mine_b.name}"
                  else
                    "#{entity.name} move #{train_b.name} from #{mine_b.name} to #{mine_a.name}"
                  end
        end

        # 0 -> 1
        def half_swap(train, mine0, mine1)
          train.owner = mine1
          mine0.trains.delete(train)
          mine1.trains << train
        end

        def add_mine(entity, mine)
          mine.owner = entity
          mine.spend(mine.cash, entity) if mine.cash.positive?
          @corporation_info[entity][:mines] << mine
        end

        def train_maintenance(train_name)
          MAINTENANCE_BY_PHASE[@phase.name.delete('a')][train_name] || 0
        end

        def minor_maintenance_costs(entity)
          (machine_size(entity) > 1 ? 0 : train_maintenance('1M')) + # virtual 1M for machine-less mines
            entity.trains.sum { |t| train_maintenance(t.name) }
        end

        def maintenance_costs(entity)
          if entity.minor?
            minor_maintenance_costs(entity)
          elsif public_mine?(entity)
            public_mine_mines(entity).sum { |m| minor_maintenance_costs(m) }
          elsif railway?(entity)
            entity.trains.sum { |t| train_maintenance(t.name) }
          else
            0
          end
        end

        def calculate_mine_revenue(mine, m_size, s_size)
          m_revs = @minor_info[mine][:machine_revenue]
          m_rev = m_revs[m_size - 1]
          s_rev = s_size ? @minor_info[mine][:switcher_revenue][s_size - 2] : 0
          connected_mine?(mine) ? m_rev + s_rev : m_revs.first
        end

        def mine_revenue(entity)
          if entity.minor?
            calculate_mine_revenue(entity, machine_size(entity), switcher_size(entity))
          elsif public_mine?(entity)
            rev = public_mine_mines(entity).sum { |m| mine_revenue(m) } || 0
            rev += HW_BONUS if entity.name == 'HW'
            rev
          else
            0
          end
        end

        # update round structure with fake route for mines (both independent and public)
        # update maintenance costs
        def update_mine_revenue(round, entity)
          revenue = mine_revenue(entity)
          @routes = []
          @routes << Engine::Route.new(
            self,
            phase,
            nil,
            connection_hexes: [],
            hexes: [],
            revenue: mine_revenue(entity),
            revenue_str: '',
            routes: @routes
          )
          round.routes = @routes
          @log << "#{entity.name} produces #{format_currency(revenue)} revenue"
          maintenance = maintenance_costs(entity)
          round.maintenance = maintenance
          @log << "#{entity.name} owes #{format_currency(maintenance)} for maintenance" if maintenance.positive?
        end

        # one NT train is really N trains, so we use the subtrains we created earlier
        def route_trains(entity)
          entity.runnable_trains.map { |t| @subtrains[t] }.flatten
        end

        def train_name(train)
          train = @supertrains[train] || train
          owner = train_owner(train)
          train_idx = owner.trains.find_index(train)
          if diesel?(train)
            train.name
          elsif train_idx < 26
            "#{train.name}#{('a'.ord + train_idx).chr}"
          else
            # unlikely that someone will have more than 26 trains...
            "#{train.name}-#{train_idx}"
          end
        end

        ##########################################
        # start of route methods
        #
        def compute_stops(route)
          route.visited_stops
        end

        def check_connected(route, corporation)
          # special case: don't check on concession route(s)
          con_route = @corporation_info[train_owner(route.train)][:concession_routes].any? do |c_r|
            (route.connection_hexes.flatten & c_r).size == c_r.size
          end

          super unless con_route
        end

        def check_distance(route, visits)
          train = route.train

          # no real "distance" for 1873 routes, instead might as well use visits for checks:
          # check that route begins and ends with termini
          corporation = train_owner(route.train)
          if (!terminus?(visits.first, corporation) || !terminus?(visits.last, corporation)) && !diesel?(train)
            raise GameError, 'Route must begin and end with token or non-tokened out open mine or factory'
          end
          if (!d_terminus?(visits.first, corporation) || !d_terminus?(visits.last, corporation)) && diesel?(train)
            raise GameError, 'Route must begin and end with token'
          end

          # check that route doesn't pass through a "town" (framed hex)
          return unless visits.size > 2

          visits[1..-2].each do |node|
            raise GameError, 'Route cannot pass through a town' if node.tile.frame
          end
        end

        # a node is a legal terminus if:
        # it is a city with the corp's token
        # it is a town with a factory
        # it is a city that is not tokened-out with a factory or open mine
        def terminus?(node, corporation)
          (node.city? && node.tokened_by?(corporation)) ||
          (node.town? && FACTORY_INFO[node.hex.id]) ||
          (node.city? && !node.blocks?(corporation) &&
           (((mine = find_mine_in_hex(node.hex)) && mine_open?(mine)) || FACTORY_INFO[node.hex.id]))
        end

        # a node is a legal diesel terminus if:
        # it is a city with the corp's token
        def d_terminus?(node, corporation)
          node.city? && node.tokened_by?(corporation)
        end

        def find_mine_in_hex(hex)
          @minors.find { |m| m.coordinates == hex.id }
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

        def train_type(train)
          train.name.include?('D') ? :passenger : :mining
        end

        def diesel?(train)
          train.name.include?('D')
        end

        def entity_has_diesel?(entity)
          railway?(entity) && entity.trains.any? { |t| diesel?(t) }
        end

        # needed to keep diesel routes separate from the rest
        def compute_other_paths(routes, route)
          routes
            .reject { |r| r == route }
            .select { |r| train_type(route.train) == train_type(r.train) }
            .flat_map(&:paths)
        end

        def check_other(route)
          # make sure a single route doesn't visit cities in a given hex twice
          check_hex_reentry(route)

          return if route.routes.empty?

          # make sure routes from same supertrain intersect
          super_routes = route.routes.reject do |r|
            r.chains.empty? ||
              @supertrains[route.train] != @supertrains[r.train]
          end
          check_intersection(@supertrains[route.train], super_routes)

          check_diesel_nodes(route) if diesel?(route.train)

          # make sure concession route is run by normal trains and also by the diesel if there is one
          type_routes = route.routes.group_by { |r| train_type(r.train) }
          owner = train_owner(route.train)

          if train_type(route.train) == :mining && !concession_route_run?(owner, type_routes[:mining])
            raise GameError, 'Concession route not run by one non-diesel train'
          end
          return if train_type(route.train) == :mining || concession_route_run?(owner, type_routes[:passenger])

          raise GameError, 'Concession route not run by diesel train'
        end

        # all routes from one supertrain must intersect each other (borrowed from 1860)
        def check_intersection(supertrain, routes)
          owner = supertrain.owner

          # build a map of which routes intersect with each route
          intersects = Hash.new { |h, k| h[k] = [] }
          routes.each_with_index do |r, ir|
            routes.each_with_index do |s, is|
              next if ir == is

              # cannot intersect at a tokened-out city
              intersects[ir] << is if (untokened_stops(owner, r.visited_stops) & untokened_stops(owner, s.visited_stops)).any?
            end
            intersects[ir].uniq!
          end

          # starting with the first route, make sure every route can be visited
          visited = {}
          visit_route(0, intersects, visited)

          return unless visited.size != routes.size

          raise GameError, "All routes using train #{train_name(supertrain)} must intersect with each other"
        end

        def untokened_stops(entity, visits)
          visits.reject { |v| v.blocks?(entity) }
        end

        def visit_route(ridx, intersects, visited)
          return if visited[ridx]

          visited[ridx] = true
          intersects[ridx].each { |i| visit_route(i, intersects, visited) }
        end

        def check_hex_reentry(route)
          return if diesel?(route.train)

          visited_hexes = route.visited_stops.map(&:hex)
          return if visited_hexes == visited_hexes.uniq

          raise GameError, 'Route cannot visit a hex with a town or village more than once'
        end

        def check_diesel_nodes(route)
          entity = train_owner(route.train)
          return unless route.visited_stops.any? { |n| !node_connected_to_concession_route?(entity, n) }

          raise GameError, 'Diesel route has to directly or indirectly connect to concession route'
        end

        def node_connected_to_concession_route?(entity, node)
          concession_tile_hexes(entity).include?(node.hex) || diesel_graph.connected_nodes(entity)[node]
        end

        def concession_route_run?(entity, routes)
          return true if entity == @qlb
          return false unless routes

          @corporation_info[entity][:concession_routes].all? do |con_route|
            routes.any? do |r|
              ((route_hexes = r.connection_hexes.flatten.uniq) & con_route).size == con_route.size &&
                route_hexes.size == con_route.size
            end
          end
        end

        def concession_route?(corporation, route)
          return false unless corporation
          return false unless @corporation_info[corporation][:concession_routes]
          return false unless route

          route_hexes = route.connection_hexes.flatten.uniq

          @corporation_info[corporation][:concession_routes].any? do |con_route|
            (route_hexes & con_route).size == con_route.size && route_hexes.size == con_route.size
          end
        end

        def revenue_for(route, stops)
          return diesel_revenue(route, stops) if diesel?(route.train)

          owner = train_owner(route.train)
          stops.sum do |stop|
            next 0 if stop.city? && stop.blocks?(owner)

            stop_total = 0
            first = !stop_on_other_route?(route, stop)
            if stop.city? && first
              stop_total += stop.tokened_by?(owner) ? stop.route_revenue(route.phase, route.train) : STOP_REVENUE
            end

            if (mine = find_mine_in_hex(stop.hex)) && mine_open?(mine) && highest_train_at_stop?(route, stop)
              stop_total += @minor_info[mine][:multiplier] * route.train.distance
            end

            stop_total += FACTORY_INFO[stop.hex.id][:revenue] if FACTORY_INFO[stop.hex.id] && first

            stop_total
          end
        end

        def stop_on_other_route?(this_route, stop)
          t_type = train_type(this_route.train)
          this_route.routes.select { |r| t_type == train_type(r.train) }.each do |r|
            return false if r == this_route

            return true if r.visited_stops.map(&:hex).include?(stop.hex)
          end
          false
        end

        # actually, first highest train on route
        def highest_train_at_stop?(this_route, stop)
          max = 0
          max_route = nil
          this_route.routes.each do |r|
            if r.visited_stops.map(&:hex).include?(stop.hex) && !diesel?(r.train) && r.train.distance > max
              max = r.train.distance
              max_route = r
            end
          end
          max_route == this_route
        end

        def diesel_revenue(route, stops)
          stops.sum do |stop|
            if stop.city? && !stop_on_other_route?(route, stop) && !stop.blocks?(train_owner(route.train))
              DIESEL_STOP_REVENUE
            else
              0
            end
          end
        end

        #  subtrain owner is actually supertrain owner
        def train_owner(train)
          (@supertrains[train] || train)&.owner
        end

        # 1. subtrain owner is actually supertrain owner
        # 2. need to use PMC if submine
        #    don't want to make PMC direct owner of submine trains
        #    - this makes PMC train mananagement easy
        def train_operator(train)
          owner = (@supertrains[train] || train).owner
          return owner if !owner&.minor? || !public_mine?(owner&.owner)

          owner.owner
        end

        def qlb_bonus
          hex = hex_by_id(@qlb.coordinates.first)
          hex.tile.cities.first.route_revenue(@phase, @qlb_dummy_train)
        end

        # needed to deal with unallocated diesels being referenced by Route serialization
        def city_tokened_by?(city, entity)
          !entity || city.tokened_by?(entity)
        end

        def revenue_str(route)
          str = super
          concession_route?(route.corporation, route) ? "#{str} (concession)" : str
        end

        def adjustable_train_list?(entity)
          entity.trains.any? { |t| diesel?(t) }
        end

        def adjustable_train_label(_entity)
          'Diesel'
        end

        # add diesel to end
        def add_route_train(entity, _routes)
          diesel = entity.trains.find { |t| diesel?(t) }
          return unless diesel

          allocate_pool_diesel(diesel)
        end

        def delete_route_train(entity, route)
          train = route.train
          return unless diesel?(train)
          return if entity.trains.include?(route.train)

          unallocate_pool_diesel(entity, train)
        end
        #
        # end of route methods
        ##########################################

        def price_movement_chart
          [
            ['Dividend', 'Share Price Change'],
            ['0', '1 ←'],
            ['> 0', 'none'],
            ['≥ stock value', '1 →'],
            ['≥ 2× stock value', '2 →'],
            ['≥ 3× stock value', '3 →'],
          ]
        end

        def ipo_name(entity = nil)
          !entity || entity&.ipoed ? 'Treasury' : 'IPO'
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
          str += ' (Closed)' if corporation.minor? && !mine_open?(corporation)
          str
        end

        def corporate_card_minors(corporation)
          public_mine_mines(corporation)
        end

        def player_value(player)
          player.value +
            @minors.select { |m| m.owner == player }.sum { |m| mine_face_value(m) }
        end

        def player_card_minors(player)
          @minors.select { |m| m.owner == player }
        end

        def show_game_cert_limit?
          false
        end

        def value_for_dumpable(player, corporation)
          max_bundle = bundles_for_corporation(player, corporation)
            .select { |bundle| dumpable?(bundle, player) && @share_pool&.fit_in_bank?(bundle) }
            .max_by(&:price)
          max_bundle&.price || 0
        end

        def dumpable?(bundle, entity)
          corporation = bundle.corporation

          return true unless corporation.owner == entity
          return true if corporation == @mhe
          return true if corporation.share_holders[entity] - bundle.percent >= 20 # selling above pres
          return false if concession_pending?(corporation)

          sh = corporation.player_share_holders(corporate: true)
          (sh.reject { |k, _| k == entity }.values.max || 0) >= 20
        end

        def game_location_names
          {
            'B9' => 'Wernigerode',
            'B13' => 'Derenburg',
            'B19' => 'Halberstadt',
            'C4' => 'Brocken',
            'C6' => 'Knaupsholz',
            'C12' => 'Benzingerode',
            'C14' => 'Heimburg',
            'C16' => 'Langenstein',
            'D5' => 'Schierke',
            'D7' => 'Drei Annen Hohne',
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
            '77' => 'unlimited',
            '78' => 'unlimited',
            '79' => 'unlimited',
            '75' => 'unlimited',
            '76' => 'unlimited',
            '956' => 'unlimited',
            '957' => 2,
            '958' => 2,
            '959' => 1,
            '960' => 2,
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
            '914' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:20;city=revenue:20;path=a:1,b:_0,track:narrow;'\
                        'path=a:_0,b:2,track:narrow;path=a:3,b:_1,track:narrow;path=a:_1,b:5,track:narrow',
            },
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
            '990' => 1,
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
              240p
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
              name: 'Königshütte (V-H)',
              logo: '1873/1',
              simple_logo: '1873/1.alt',
              tokens: [],
              coordinates: 'E8',
              color: '#772500',
              extended: {
                value: 110,
                vor_harzer: true,
                machine_revenue: [40, 50, 60, 70, 80],
                switcher_revenue: [30, 40, 50, 60],
                multiplier: 10,
                connected: false,
                open: true,
              },
            },
            {
              sym: '2',
              name: 'Wurmberg',
              logo: '1873/2',
              simple_logo: '1873/2.alt',
              tokens: [],
              coordinates: 'E4',
              color: 'black',
              extended: {
                value: 120,
                vor_harzer: false,
                machine_revenue: [40, 60, 80, 100, 120],
                switcher_revenue: [20, 30, 40, 50],
                multiplier: 20,
                connected: false,
                open: true,
              },
            },
            {
              sym: '3',
              name: 'Silberhütte',
              logo: '1873/3',
              simple_logo: '1873/3.alt',
              tokens: [],
              coordinates: 'I16',
              color: 'black',
              extended: {
                value: 130,
                vor_harzer: false,
                machine_revenue: [40, 60, 80, 100, 120],
                switcher_revenue: [20, 30, 40, 50],
                multiplier: 20,
                connected: false,
                open: true,
              },
            },
            {
              sym: '4',
              name: 'Hüttenrode (V-H)',
              logo: '1873/4',
              simple_logo: '1873/4.alt',
              tokens: [],
              coordinates: 'D11',
              color: '#772500',
              extended: {
                value: 140,
                vor_harzer: true,
                machine_revenue: [40, 60, 80, 100, 120],
                switcher_revenue: [20, 30, 40, 50],
                multiplier: 20,
                connected: false,
                open: true,
              },
            },
            {
              sym: '5',
              name: 'Braunesumpf (V-H)',
              logo: '1873/5',
              simple_logo: '1873/5.alt',
              tokens: [],
              coordinates: 'D13',
              color: '#772500',
              extended: {
                value: 150,
                vor_harzer: true,
                machine_revenue: [50, 60, 70, 80, 90],
                switcher_revenue: [40, 50, 60, 70],
                multiplier: 10,
                connected: false,
                open: true,
              },
            },
            {
              sym: '6',
              name: 'Rübeland (V-H)',
              logo: '1873/6',
              simple_logo: '1873/6.alt',
              tokens: [],
              coordinates: 'E10',
              color: '#772500',
              extended: {
                value: 160,
                vor_harzer: true,
                machine_revenue: [50, 70, 90, 110, 130],
                switcher_revenue: [30, 40, 50, 60],
                multiplier: 20,
                connected: false,
                open: true,
              },
            },
            {
              sym: '7',
              name: 'Lindenberg',
              logo: '1873/7',
              simple_logo: '1873/7.alt',
              tokens: [],
              coordinates: 'I14',
              color: 'black',
              extended: {
                value: 170,
                vor_harzer: false,
                machine_revenue: [50, 80, 110, 140, 170],
                switcher_revenue: [20, 30, 40, 50],
                multiplier: 30,
                connected: false,
                open: true,
              },
            },
            {
              sym: '8',
              name: 'Netzkater',
              logo: '1873/8',
              simple_logo: '1873/8.alt',
              tokens: [],
              coordinates: 'I8',
              color: 'black',
              extended: {
                value: 180,
                vor_harzer: false,
                machine_revenue: [60, 80, 100, 120, 140],
                switcher_revenue: [40, 50, 60, 70],
                multiplier: 20,
                connected: false,
                open: true,
              },
            },
            {
              sym: '9',
              name: 'Wieda',
              logo: '1873/9',
              simple_logo: '1873/9.alt',
              tokens: [],
              coordinates: 'G2',
              color: 'black',
              extended: {
                value: 190,
                vor_harzer: false,
                machine_revenue: [60, 90, 120, 150, 180],
                switcher_revenue: [30, 40, 50, 60],
                multiplier: 30,
                connected: false,
                open: true,
              },
            },
            {
              sym: '10',
              name: 'Elbingerode (V-H)',
              logo: '1873/10',
              simple_logo: '1873/10.alt',
              tokens: [],
              coordinates: 'D9',
              color: '#772500',
              extended: {
                value: 200,
                vor_harzer: true,
                machine_revenue: [60, 90, 120, 150, 180],
                switcher_revenue: [30, 40, 50, 60],
                multiplier: 30,
                connected: false,
                open: true,
              },
            },
            {
              sym: '11',
              name: 'Tanne (V-H)',
              logo: '1873/11',
              simple_logo: '1873/11.alt',
              tokens: [],
              coordinates: 'F7',
              color: '#772500',
              extended: {
                value: 220,
                vor_harzer: true,
                machine_revenue: [70, 90, 110, 130, 150],
                switcher_revenue: [50, 60, 70, 80],
                multiplier: 20,
                connected: false,
                open: true,
              },
            },
            {
              sym: '12',
              name: 'Blankenburg (V-H)',
              logo: '1873/12',
              simple_logo: '1873/12.alt',
              tokens: [],
              coordinates: 'D15',
              color: '#772500',
              extended: {
                value: 240,
                vor_harzer: true,
                machine_revenue: [70, 90, 110, 130, 150],
                switcher_revenue: [50, 60, 70, 80],
                multiplier: 20,
                connected: false,
                open: true,
              },
            },
            {
              sym: '13',
              name: 'Harzgerode',
              logo: '1873/13',
              simple_logo: '1873/13.alt',
              tokens: [],
              coordinates: 'I18',
              color: 'black',
              extended: {
                value: 260,
                vor_harzer: false,
                machine_revenue: [70, 100, 130, 160, 190],
                switcher_revenue: [40, 50, 60, 70],
                multiplier: 30,
                connected: false,
                open: true,
              },
            },
            {
              sym: '14',
              name: 'Zorge (V-H)',
              logo: '1873/14',
              simple_logo: '1873/14.alt',
              tokens: [],
              coordinates: 'G4',
              color: '#772500',
              extended: {
                value: 280,
                vor_harzer: true,
                machine_revenue: [90, 110, 130, 150, 170],
                switcher_revenue: [70, 80, 90, 100],
                multiplier: 20,
                connected: false,
                open: true,
              },
            },
            {
              sym: '15',
              name: 'Thale',
              logo: '1873/15',
              simple_logo: '1873/15.alt',
              tokens: [],
              coordinates: 'F15',
              color: 'black',
              extended: {
                value: 300,
                vor_harzer: false,
                machine_revenue: [90, 120, 150, 180, 210],
                switcher_revenue: [60, 70, 80, 90],
                multiplier: 30,
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
              simple_logo: '1873/HBE.alt',
              float_percent: 60,
              always_market_price: true,
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
              simple_logo: '1873/GHE.alt',
              float_percent: 60,
              always_market_price: true,
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
                concession_routes: [%w[G20 H19 H17 I18]],
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
              simple_logo: '1873/NWE.alt',
              float_percent: 60,
              always_market_price: true,
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
              simple_logo: '1873/SHE.alt',
              float_percent: 60,
              always_market_price: true,
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
              simple_logo: '1873/KEZ.alt',
              float_percent: 60,
              always_market_price: true,
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
              simple_logo: '1873/WBE.alt',
              float_percent: 60,
              always_market_price: true,
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
              color: '#959490',
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
              simple_logo: '1873/QLB.alt',
              float_percent: 60,
              always_market_price: true,
              shares: [20, 20, 20, 20, 20],
              max_ownership_percent: 100,
              coordinates: ['E20'],
              city: 0,
              tokens: [
                0,
                100,
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
                concession_pending: true,
                concession_incomplete: false,
                extra_tokens: 2,
                advanced: true,
              },
            },
            {
              sym: 'MHE',
              name: 'Magdeburg-Halberstädter Eisenbahn',
              logo: '1873/MHE',
              simple_logo: '1873/MHE.alt',
              float_percent: 0,
              always_market_price: true,
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
              simple_logo: '1873/U.alt',
              float_percent: 80,
              always_market_price: true,
              shares: [50, 50],
              tokens: [],
              max_ownership_percent: 100,
              color: '#950822',
              text_color: 'white',
              extended: {
                type: :mine,
                vor_harzer: false,
                slots: 2,
                mines: [],
              },
            },
            {
              sym: 'HW',
              name: 'Harzer Werke',
              logo: '1873/HW',
              simple_logo: '1873/HW.alt',
              float_percent: 80,
              always_market_price: true,
              shares: [50, 50],
              tokens: [],
              max_ownership_percent: 100,
              color: '#772500',
              text_color: 'white',
              extended: {
                type: :mine,
                vor_harzer: true,
                slots: 2,
                mines: [],
              },
            },
            {
              sym: 'CO',
              name: 'Concordia',
              logo: '1873/CO',
              simple_logo: '1873/CO.alt',
              float_percent: 80,
              always_market_price: true,
              shares: [50, 50],
              tokens: [],
              max_ownership_percent: 100,
              color: '#16CE91',
              text_color: 'white',
              extended: {
                type: :mine,
                vor_harzer: false,
                slots: 2,
                mines: [],
              },
            },
            {
              sym: 'SN',
              name: 'Schachtbau',
              logo: '1873/SN',
              simple_logo: '1873/SN.alt',
              float_percent: 80,
              always_market_price: true,
              shares: [50, 50],
              tokens: [],
              max_ownership_percent: 100,
              color: '#F7848D',
              text_color: 'black',
              extended: {
                type: :mine,
                vor_harzer: false,
                slots: 2,
                mines: [],
              },
            },
            {
              sym: 'MO',
              name: 'Montania',
              logo: '1873/MO',
              simple_logo: '1873/MO.alt',
              float_percent: 80,
              always_market_price: true,
              shares: [50, 50],
              tokens: [],
              max_ownership_percent: 100,
              color: '#448A28',
              text_color: 'black',
              extended: {
                type: :mine,
                vor_harzer: false,
                slots: 2,
                mines: [],
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
              num: 2,
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
              events: [{ 'type' => 'remove_locks' }],
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
              available_on: DIESEL_PURCHASE_ON,
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
                   'border=edge:2,type:impassable;'\
                   'icon=image:1873/8_open,sticky:1,large:1',
              %w[
                H7
              ] => 'upgrade=cost:100,terrain:mountain;icon=image:1873/NWE,sticky:1;'\
                   'border=edge:5,type:impassable',
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
                   'border=edge:4,type:impassable;border=edge:5,type:impassable;'\
                   'icon=image:1873/9_open,sticky:1,large:1',
              %w[
                F3
              ] => 'town=revenue:0;upgrade=cost:150,terrain:mountain;icon=image:1873/SHE,sticky:1',
              # KEZ concession route
              %w[
                H3
              ] => 'upgrade=cost:100,terrain:mountain;icon=image:1873/KEZ,sticky:1;'\
                   'border=edge:2,type:impassable',
              # WBE concession route
              %w[
                C10
              ] => 'border=edge:5,type:impassable;'\
                   'icon=image:1873/lock;'\
                   'icon=image:1873/WBE,sticky:1',
              %w[
                C12
              ] => 'town=revenue:0;border=edge:0,type:impassable;border=edge:5,type:impassable;'\
                   'icon=image:1873/lock;'\
                   'icon=image:1873/WBE,sticky:1',
              %w[
                C14
              ] => 'town=revenue:0;border=edge:0,type:impassable;'\
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
              ] => 'upgrade=cost:100,terrain:mountain;border=edge:1,type:impassable',
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
              ] => 'town=revenue:0;upgrade=cost:150,terrain:mountain;border=edge:0,type:impassable',
              %w[
                D11
              ] => 'town=revenue:0;upgrade=cost:100,terrain:mountain;border=edge:1,type:impassable;'\
                   'border=edge:2,type:impassable;border=edge:3,type:impassable;'\
                   'icon=image:1873/4_open,sticky:1,large:1',
              %w[
                D13
              ] => 'town=revenue:0;upgrade=cost:150,terrain:mountain;'\
                   'border=edge:2,type:impassable;border=edge:3,type:impassable;'\
                   'icon=image:1873/5_open,sticky:1,large:1',
              %w[
                D17
              ] => 'town=revenue:0;',
              %w[
                E8
              ] => 'town=revenue:0;upgrade=cost:100,terrain:mountain;border=edge:4,type:impassable;'\
                   'icon=image:1873/1_open,sticky:1,large:1',
              %w[
                E10
              ] => 'town=revenue:0;upgrade=cost:100,terrain:mountain;border=edge:1,type:impassable;'\
                   'border=edge:4,type:impassable;'\
                   'icon=image:1873/6_open,sticky:1,large:1',
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
                   'icon=image:1873/7_open,sticky:1,large:1',
              %w[
                I16
              ] => 'town=revenue:0;upgrade=cost:100,terrain:mountain;'\
                   'icon=image:1873/3_open,sticky:1,large:1',
            },
            yellow: {
              %w[
                D9
              ] => 'city=revenue:30;path=a:5,b:_0,track:narrow;upgrade=cost:50,terrain:mountain;'\
                   'border=edge:4,type:impassable;frame=color:#800080;'\
                   'icon=image:1873/10_open,sticky:1,large:1',
              %w[
                D15
              ] => 'city=revenue:40,slots:2;path=a:1,b:_0,track:narrow;path=a:3,b:_0,track:narrow;'\
                   'path=a:5,b:_0,track:narrow;label=B;frame=color:#800080;'\
                   'icon=image:1873/12_open,sticky:1,large:1',
              %w[
                E4
              ] => 'city=revenue:30;path=a:0,b:_0,track:narrow;upgrade=cost:50,terrain:mountain;'\
                   'border=edge:3,type:impassable;frame=color:#800080;'\
                   'icon=image:1873/2_open,sticky:1,large:1',
              %w[
                F11
              ] => 'city=revenue:30;path=a:5,b:_0,track:narrow;upgrade=cost:50,terrain:mountain;'\
                   'frame=color:#800080;'\
                   'icon=image:1873/SM_open,sticky:1,large:1',
              %w[
                G4
              ] => 'city=revenue:30;path=a:0,b:_0,track:narrow;upgrade=cost:50,terrain:mountain;'\
                   'border=edge:1,type:impassable;border=edge:3,type:impassable;frame=color:#800080;'\
                   'icon=image:1873/14_open,sticky:1,large:1',
            },
            green: {
              %w[
                B19
              ] => 'city=revenue:60;path=a:1,b:_0,track:narrow;path=a:2,b:_0;path=a:5,b:_0;'\
                   'frame=color:#800080;label=HQG',
              %w[
                C16
              ] => 'city=revenue:30;path=a:0,b:_0,track:narrow;path=a:2,b:_0,track:narrow;'\
                   'path=a:3,b:_0,track:narrow',
              %w[
                E20
              ] => 'city=revenue:60;path=a:1,b:_0,track:narrow;path=a:0,b:_0;path=a:3,b:_0;'\
                   'frame=color:#800080;label=HQG',
              %w[
                F5
              ] => 'city=revenue:20;city=revenue:20;path=a:1,b:_0,track:narrow;path=a:4,b:_0,track:narrow;'\
                   'path=a:3,b:_1,track:narrow;path=a:5,b:_1,track:narrow;'\
                   'upgrade=cost:50,terrain:mountain;border=edge:0,type:impassable',
              %w[
                F7
              ] => 'city=revenue:20;city=revenue:20;path=a:1,b:_0,track:narrow;'\
                   'path=a:3,b:_1,track:narrow;upgrade=cost:50,terrain:mountain;'\
                   'icon=image:1873/11_open,sticky:1,large:1',
              %w[
                G6
              ] => 'city=revenue:40;path=a:2,b:_0,track:narrow;upgrade=cost:100,terrain:mountain;'\
                   'path=a:5,b:_0,track:narrow;frame=color:#800080',
              %w[
                G20
              ] => 'city=revenue:60;path=a:0,b:_0,track:narrow;path=a:2,b:_0;path=a:5,b:_0;'\
                   'frame=color:#800080;label=HQG',
              %w[
                H13
              ] => 'city=revenue:40;path=a:2,b:_0,track:narrow;path=a:5,b:_0,track:narrow;'\
                   'upgrade=cost:50,terrain:mountain;frame=color:#800080',
              %w[
                H17
              ] => 'city=revenue:30;path=a:0,b:_0,track:narrow;path=a:4,b:_0,track:narrow;'\
                   'path=a:5,b:_0,track:narrow;upgrade=cost:100,terrain:mountain',
            },
            gray: {
              %w[
                A18
              ] => 'path=a:5,b:2,terminal:1',
              %w[
                B9
              ] => 'city=slots:2,revenue:yellow_60|green_80|brown_120|gray_150;'\
                   'path=a:1,b:_0;path=a:4,b:_0;path=a:0,b:_0,track:narrow;path=a:5,b:_0,track:narrow;'\
                   'frame=color:#800080',
              %w[
                B13
              ] => 'city=slots:2,revenue:yellow_30|green_70|brown_60|gray_60;'\
                   'path=a:4,b:_0,track:narrow;path=a:5,b:_0,track:narrow;'\
                   'frame=color:#800080;icon=image:1873/ZW_open,sticky:1,large:1',
              %w[
                C4
              ] => 'city=revenue:yellow_50|green_80|brown_120|gray_150;path=a:5,b:_0,track:narrow',
              %w[
                C6
              ] => 'town=revenue:0;path=a:0,b:_0,track:narrow;'\
                   'icon=image:1873/SBC6_open,sticky:1,large:1',
              %w[
                E18
              ] => 'city=revenue:30,slots:2;path=a:1,b:_0,track:narrow;'\
                   'path=a:2,b:_0,track:narrow;path=a:4,b:_0,track:narrow;'\
                   'icon=image:1873/PM_open,sticky:1,large:1',
              %w[
                F15
              ] => 'city=revenue:yellow_30|green_40|brown_60|gray_70;'\
                   'path=a:3,b:_0,track:narrow;path=a:4,b:_0;frame=color:#800080;'\
                   'icon=image:1873/15_open,sticky:1,large:1',
              %w[
                H9
              ] => 'city=revenue:30,slots:2;path=a:0,b:_0,track:narrow;'\
                   'path=a:1,b:_0,track:narrow;path=a:4,b:_0,track:narrow;'\
                   'icon=image:1873/SBH9_open,sticky:1,large:1',
              %w[
                H21
              ] => 'path=a:2,b:5,terminal:1',
              %w[
                I2
              ] => 'city=revenue:yellow_40|green_50|brown_80|gray_120;path=a:1,b:_0;'\
                   'path=a:2,b:_0,track:narrow;path=a:4,b:_0;frame=color:#800080',
              %w[
                I4
              ] => 'city=revenue:yellow_40|green_50|brown_80|gray_120;path=a:1,b:_0;'\
                   'path=a:2,b:_0,track:narrow;path=a:5,b:_0;frame=color:#800080',
              %w[
                I18
              ] => 'city=revenue:yellow_30|green_40|brown_60|gray_70;'\
                   'path=a:2,b:_0,track:narrow;frame=color:#800080;'\
                   'icon=image:1873/13_open,sticky:1,large:1',
              %w[
                J7
              ] => 'city=revenue:yellow_60|green_80|brown_120|gray_180;path=a:1,b:_0;'\
                   'path=a:3,b:_0,track:narrow;path=a:4,b:_0;frame=color:#800080',
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
              tiles: %i[
                yellow
              ],
              operating_rounds: 1,
              status: ['HBE_GHE_active'],
            },
            {
              name: '2',
              on: '2T',
              train_limit: 99,
              tiles: %i[
                yellow
              ],
              operating_rounds: 1,
              status: ['NWE_SHE_KEZ_may'],
            },
            {
              name: '3',
              on: '3T',
              train_limit: 99,
              tiles: %i[
                yellow
                green
              ],
              operating_rounds: 2,
              status: %w[NWE_SHE_KEZ_active maintenance_level_1],
            },
            {
              name: '4',
              on: '4T',
              train_limit: 99,
              tiles: %i[
                yellow
                green
              ],
              operating_rounds: 2,
              status: %w[WBE_QLB_active maintenance_level_2],
            },
            {
              name: '5',
              on: '5T',
              train_limit: 99,
              tiles: %i[
                yellow
                green
                brown
              ],
              operating_rounds: 3,
              status: %w[end_of_game_trigger maintenance_level_2],
            },
            {
              name: '5a',
              train_limit: 99,
              tiles: %i[
                yellow
                green
                brown
              ],
              operating_rounds: 3,
              status: ['maintenance_level_2'],
            },
            {
              name: 'D',
              on: 'D',
              train_limit: 99,
              tiles: %i[
                yellow
                green
                brown
                gray
              ],
              operating_rounds: 3,
              status: ['maintenance_level_3'],
            },
          ]
        end

        def available_programmed_actions
          super + [
            Action::ProgramHarzbahnDraftPass,
            Action::ProgramIndependentMines,
          ]
        end
      end
    end
  end
end
