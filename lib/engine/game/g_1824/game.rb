# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'corporation'
require_relative 'depot'
require_relative 'entities'
require_relative 'map'
require_relative 'minor'
require_relative 'trains'

module Engine
  module Game
    module G1824
      class Game < Game::Base
        include_meta(G1824::Meta)
        include G1824::Entities
        include G1824::Map
        include G1824::Trains

        attr_accessor :two_train_bought, :forced_mountain_railway_exchange

        register_colors(
          gray70: '#B3B3B3',
          gray50: '#7F7F7F'
        )

        CURRENCY_FORMAT_STR = '%sG'

        BANK_CASH = 12_000

        CERT_LIMIT = { 2 => 14, 3 => 21, 4 => 16, 5 => 13, 6 => 11 }.freeze

        STARTING_CASH = { 2 => 680, 3 => 820, 4 => 680, 5 => 560, 6 => 460 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        MARKET = [
          %w[100
             110
             120
             130
             140
             155
             170
             190
             210
             235
             260
             290
             320
             350],
          %w[90
             100
             110
             120
             130
             145
             160
             180
             200
             225
             250
             280
             310
             340],
          %w[80
             90
             100p
             110
             120
             135
             150
             170
             190
             215
             240
             270
             300
             330],
          %w[70 80 90p 100 110 125 140 160 180 200 220],
          %w[60 70 80p 90 100 115 130 150 170],
          %w[50 60 70p 80 90 105 120],
          %w[40 50 60p 70 80],
        ].freeze

        PHASES = [
          {
            name: '2',
            on: '2',
            train_limit: { PreStaatsbahn: 2, Coal: 2, Regional: 4 },
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: { PreStaatsbahn: 2, Coal: 2, Regional: 4 },
            tiles: %i[yellow green],
            status: %w[can_buy_trains
                       may_exchange_coal_railways
                       may_exchange_mountain_railways],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: { PreStaatsbahn: 2, Coal: 2, Regional: 3 },
            tiles: %i[yellow green],
            status: %w[can_buy_trains may_exchange_coal_railways],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: { PreStaatsbahn: 2, Regional: 3, Staatsbahn: 4 },
            tiles: %i[yellow green brown],
            status: ['can_buy_trains'],
            operating_rounds: 3,
          },
          {
            name: '6',
            on: '6',
            train_limit: { Regional: 2, Staatsbahn: 3 },
            tiles: %i[yellow green brown],
            status: ['can_buy_trains'],
            operating_rounds: 3,
          },
          {
            name: '8',
            on: '8',
            train_limit: { Regional: 2, Staatsbahn: 3 },
            tiles: %i[yellow green brown gray],
            status: ['can_buy_trains'],
            operating_rounds: 3,
          },
          {
            name: '10',
            on: '10',
            train_limit: { Regional: 2, Staatsbahn: 3 },
            tiles: %i[yellow green brown gray],
            status: ['can_buy_trains'],
            operating_rounds: 3,
          },
        ].freeze

        GAME_END_CHECK = { bank: :full_or }.freeze

        # Move down one step for a whole block, not per share
        SELL_MOVEMENT = :down_block

        # Cannot sell until operated
        SELL_AFTER = :operate

        # Sell zero or more, then Buy zero or one
        SELL_BUY_ORDER = :sell_buy

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'close_mountain_railways' => ['Mountain railways closed', 'Any still open Montain railways are exchanged'],
          'sd_formation' => ['SD formation', 'The Suedbahn is founded at the end of the OR'],
          'close_coal_railways' => ['Coal railways closed', 'Any still open Coal railways are exchanged'],
          'ug_formation' => ['UG formation', 'The Ungarische Staatsbahn is founded at the end of the OR'],
          'kk_formation' => ['k&k formation', 'k&k Staatsbahn is founded at the end of the OR']
        ).freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'can_buy_trains' => ['Can Buy trains', 'Can buy trains from other corporations'],
          'may_exchange_coal_railways' => ['Coal Railway exchange', 'May exchange Coal Railways during SR'],
          'may_exchange_mountain_railways' => ['Mountain Railway exchange', 'May exchange Mountain Railways during SR']
        ).freeze

        CERT_LIMIT_CISLEITHANIA = { 2 => 14, 3 => 16 }.freeze

        BANK_CASH_CISLEITHANIA = { 2 => 4000, 3 => 9000 }.freeze

        CASH_CISLEITHANIA = { 2 => 830, 3 => 700 }.freeze

        MOUNTAIN_RAILWAY_NAMES = {
          1 => 'Semmeringbahn',
          2 => 'Kastbahn',
          3 => 'Brennerbahn',
          4 => 'Arlbergbahn',
          5 => 'Karawankenbahn',
          6 => 'Wocheinerbahn',
        }.freeze

        MINE_HEX_NAMES = %w[C6 A12 A22 H25].freeze
        MINE_HEX_NAMES_CISLEITHANIA = %w[C6 A12 A22 H25].freeze

        def init_optional_rules(optional_rules)
          opt_rules = super

          # 2 player variant always use the Cisleithania map
          opt_rules << :cisleithania if two_player? && !opt_rules.include?(:cisleithania)

          # Good Time variant is not applicable if Cisleithania is used
          opt_rules -= [:goods_time] if opt_rules.include?(:cisleithania)

          opt_rules
        end

        def init_bank
          return super unless option_cisleithania

          Engine::Bank.new(BANK_CASH_CISLEITHANIA[@players.size], log: @log)
        end

        def init_starting_cash(players, bank)
          return super unless option_cisleithania

          players.each do |player|
            bank.spend(CASH_CISLEITHANIA[@players.size], player)
          end
        end

        def game_cert_limit
          return CERT_LIMIT_CISLEITHANIA if option_cisleithania

          CERT_LIMIT
        end

        def init_train_handler
          trains = if two_player?
                     self.class::TRAINS_2_PLAYER
                   elsif @players.size == 3 && option_cisleithania
                     self.class::TRAINS_3_PLAYER_CISLETHANIA
                   else
                     self.class::TRAINS_STANDARD
                   end
          trains = trains.flat_map do |train|
            Array.new((train[:num] || num_trains(train))) do |index|
              Train.new(**train, index: index)
            end
          end

          G1824::Depot.new(trains, self)
        end

        def init_corporations(stock_market)
          corporations = CORPORATIONS.dup

          corporations.map! do |corporation|
            G1824::Corporation.new(
              min_price: stock_market.par_prices.map(&:price).min,
              capitalization: self.class::CAPITALIZATION,
              **corporation.merge(corporation_opts),
            )
          end

          if option_cisleithania
            # Some corporations need to be removed, but they need to exists (for implementation reasons)
            # So set them as closed and removed so that they do not appear
            # Affected: Coal Railway C4 (SPB), Regional Railway BH and SB, and possibly UG
            corporations.each do |c|
              if %w[SB BH].include?(c.name) || (two_player? && c.name == 'UG')
                c.close!
                c.removed = true
              end
            end
          end

          corporations
        end

        def init_minors
          minors = MINORS.dup

          if option_cisleithania
            if two_player?
              # Remove Pre-Staatsbahn U1 and U2, and minor SPB
              minors.reject! { |m| %w[U1 U2 SPB].include?(m[:sym]) }
            else
              # Remove Pre-Staatsbahn U2, minor SPB, and move home location for U1
              minors.reject! { |m| %w[U2 SPB].include?(m[:sym]) }
              minors.map! do |m|
                next m unless m['sym'] == 'U1'

                m['coordinates'] = 'G12'
                m['city'] = 0
                m
              end
            end
          end

          minors.map { |minor| G1824::Minor.new(**minor) }
        end

        def init_companies(players)
          companies = COMPANIES.dup

          mountain_railway_count =
            case players.size
            when 2
              2
            when 3
              option_cisleithania ? 3 : 4
            when 4, 5
              6
            when 6
              4
            end
          mountain_railway_count.times { |index| companies << mountain_railway_definition(index) }

          if option_cisleithania
            # Remove Pre-Staatsbahn U2 and possibly U1
            p2 = players.size == 2
            companies.reject! { |m| m['sym'] == 'U2' || (p2 && m['sym'] == 'U1') }
          end

          companies.map { |company| Company.new(**company) }
        end

        def init_tiles
          tiles = TILES.dup

          if option_goods_time
            # Goods Time increase count for some town related tiles
            tiles['3'] += 3
            tiles['4'] += 3
            tiles['56'] += 1
            tiles['58'] += 3
            tiles['87'] += 2
            tiles['630'] += 1
            tiles['631'] += 1

            # New tile for Goods Time variant
            tiles['204'] = 3
          end

          tiles.flat_map do |name, val|
            init_tile(name, val)
          end
        end

        def option_cisleithania
          two_player? || @optional_rules&.include?(:cisleithania)
        end

        def option_goods_time
          @optional_rules&.include?(:goods_time)
        end

        def location_name(coord)
          return super unless option_cisleithania

          unless @location_names
            @location_names = LOCATION_NAMES.dup
            @location_names['F25'] = 'Kronstadt'
            @location_names['G12'] = 'Budapest'
            @location_names['I10'] = 'Bosnien'
          end
          @location_names[coord]
        end

        def optional_hexes
          option_cisleithania ? cisleithania_map : base_map
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::DiscardTrain,
            Engine::Step::HomeToken,
            G1824::Step::ForcedMountainRailwayExchange,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G1824::Step::Dividend,
            G1824::Step::BuyTrain,
          ], round_num: round_num)
        end

        def init_round
          @log << '-- First Stock Round --'
          @log << 'Player order is reversed during the first turn'
          G1824::Round::FirstStock.new(self, [
            G1824::Step::BuySellParSharesFirstSr,
          ])
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1824::Step::BuySellParExchangeShares,
          ])
        end

        def or_set_finished
          depot.export!
        end

        def coal_c1
          @c1 ||= minor_by_id('EPP')
        end

        def coal_c2
          @c2 ||= minor_by_id('EOD')
        end

        def coal_c3
          @c3 ||= minor_by_id('MLB')
        end

        def coal_c4
          @c4 ||= minor_by_id('SPB')
        end

        def regional_bk
          @bk ||= corporation_by_id('BK')
        end

        def regional_ms
          @ms ||= corporation_by_id('MS')
        end

        def regional_cl
          @cl ||= corporation_by_id('CL')
        end

        def regional_sb
          @sb ||= corporation_by_id('SB')
        end

        def state_sd
          @sd ||= corporation_by_id('SD')
        end

        def state_ug
          @ug ||= corporation_by_id('UG')
        end

        def state_kk
          @kk ||= corporation_by_id('KK')
        end

        def setup
          @two_train_bought = false
          @forced_mountain_railway_exchange = []

          @companies.each do |c|
            c.owner = @bank
            @bank.companies << c
          end

          @minors.each do |minor|
            hex = hex_by_id(minor.coordinates)
            hex.tile.cities[minor.city].place_token(minor, minor.next_token)
          end

          # Reserve the presidency share to have it as exchange for associated coal railway
          @corporations.each do |c|
            next if !regional?(c) && !staatsbahn?(c)
            next if c.id == 'BH'

            c.shares.find(&:president).buyable = false
            c.floatable = false
          end
        end

        def timeline
          @timeline ||= ['At the end of each OR set, the cheapest train in bank is exported.'].freeze
        end

        def status_str(entity)
          if coal_railway?(entity)
            'Coal Railway - may only own g trains'
          elsif pre_staatsbahn?(entity)
            'Pre-Staatsbahn'
          elsif staatsbahn?(entity)
            'Staatsbahn'
          elsif regional?(entity)
            str = 'Regional Railway'
            if (coal = associated_coal_railway(entity)) && !coal.closed?
              str += " - Presidency reserved (#{coal.name})"
            end
            str
          end
        end

        def can_par?(corporation, parrer)
          super && buyable?(corporation) && !reserved_regional(corporation)
        end

        def g_train?(train)
          train.name.end_with?('g')
        end

        def mountain_railway?(entity)
          entity.company? && entity.sym.start_with?('B')
        end

        def mountain_railway_exchangable?
          @phase.status.include?('may_exchange_mountain_railways')
        end

        def coal_railway?(entity)
          return entity.type == :Coal if entity.minor?

          entity.company? && associated_regional_railway(entity)
        end

        def coal_railway_exchangable?
          @phase.status.include?('may_exchange_coal_railways')
        end

        def pre_staatsbahn?(entity)
          entity.minor? && entity.type == :PreStaatsbahn
        end

        def regional?(entity)
          entity.corporation? && entity.type == :Regional
        end

        def staatsbahn?(entity)
          entity.corporation? && entity.type == :Staatsbahn
        end

        def reserved_regional(entity)
          return false unless regional?(entity)

          president_share = entity.shares.find(&:president)
          president_share && !president_share.buyable
        end

        def buyable?(entity)
          return true unless entity.corporation?

          entity.all_abilities.none? { |a| a.type == :no_buy }
        end

        def corporation_available?(entity)
          buyable?(entity)
        end

        def entity_can_use_company?(_entity, _company)
          # Return false here so that Exchange abilities does not appear in GUI
          false
        end

        def sorted_corporations
          sorted_corporations = super
          return sorted_corporations unless @turn == 1

          # Remove unbuyable stuff in SR 1 to reduce information
          sorted_corporations.select { |c| buyable?(c) }
        end

        def associated_regional_railway(coal_railway)
          key = coal_railway.minor? ? coal_railway.name : coal_railway.id
          case key
          when 'EPP'
            regional_bk
          when 'EOD'
            regional_ms
          when 'MLB'
            regional_cl
          when 'SPB'
            regional_sb
          end
        end

        def associated_coal_railway(regional_railway)
          case regional_railway.name
          when 'BK'
            coal_c1
          when 'MS'
            coal_c2
          when 'CL'
            coal_c3
          when 'SB'
            coal_c4
          end
        end

        def associated_state_railway(prestate_railway)
          case prestate_railway.id
          when 'S1', 'S2', 'S3'
            state_sd
          when 'U1', 'U2'
            state_ug
          when 'K1', 'K2'
            state_kk
          end
        end

        def revenue_for(route, stops)
          # Ensure only g-trains visit mines, and that g-trains visit exactly one mine
          mine_visits = route.hexes.count { |h| mine_hex?(h) }

          raise GameError, 'Exactly one mine need to be visited' if g_train?(route.train) && mine_visits != 1
          raise GameError, 'Only g-trains may visit mines' if !g_train?(route.train) && mine_visits.positive?

          # TODO: Implement Bekowina bonus if Cislethania map used

          super
        end

        def revenue_str(route)
          # TODO: Implement Bukowina bonus if Cislethania map used

          super
        end

        def mine_revenue(routes)
          routes.sum { |r| r.stops.sum { |stop| mine_hex?(stop.hex) ? stop.route_revenue(r.phase, r.train) : 0 } }
        end

        def float_str(entity)
          return super if !entity.corporation || entity.floatable

          case entity.id
          when 'BK', 'MS', 'CL', 'SB'
            needed = entity.percent_to_float
            needed.positive? ? "#{entity.percent_to_float}% (including exchange) to float" : 'Exchange to float'
          when 'UG'
            'U1 exchange floats'
          when 'KK'
            'K1 exchange floats'
          when 'SD'
            'S1 exchange floats'
          else
            'Not floatable'
          end
        end

        def all_corporations
          @corporations.reject(&:removed)
        end

        def event_close_mountain_railways!
          @log << '-- Any remaining Mountain Railways are either exchanged or discarded'
          # If this list contains any companies it will trigger an interrupt exchange/pass step
          @forced_mountain_railway_exchange = @companies.select { |c| mountain_railway?(c) && !c.closed? }
        end

        def event_close_coal_railways!
          @log << '-- Exchange any remaining Coal Railway'
          @companies.select { |c| coal_railway?(c) }.reject(&:closed?).each do |coal_railway_company|
            exchange_coal_railway(coal_railway_company)
          end
        end

        def event_sd_formation!
          @log << 'SD formation not yet implemented'
        end

        def event_ug_formation!
          @log << 'UG formation not yet implemented'
        end

        def event_kk_formation!
          @log << 'KK formation not yet implemented'
        end

        def exchange_coal_railway(company)
          player = company.owner
          minor = minor_by_id(company.id)
          regional = associated_regional_railway(company)

          @log << "#{player.name} receives presidency of #{regional.name} in exchange for #{minor.name}"
          company.close!

          # Transfer Coal Railway cash and trains to Regional. Remove CR token.
          if minor.cash.positive?
            @log << "#{regional.name} receives the #{minor.name} treasury of #{format_currency(minor.cash)}"
            minor.spend(minor.cash, regional)
          end
          unless minor.trains.empty?
            transferred = transfer(:trains, minor, regional)
            @log << "#{regional.name} receives the trains: #{transferred.map(&:name).join(', ')}"
          end
          minor.tokens.first.remove!
          minor.close!

          # Handle Regional presidency, possibly transfering to another player in case they own more in the regional
          presidency_share = regional.shares.find(&:president)
          presidency_share.buyable = true
          regional.floatable = true
          @share_pool.transfer_shares(
            presidency_share.to_bundle,
            player,
            allow_president_change: false,
            price: 0
          )

          # Give presidency to majority owner (with minor owner priority if that player is one of them)
          max_shares = @share_pool.presidency_check_shares(regional).values.max
          majority_share_holders = @share_pool.presidency_check_shares(regional).select { |_, p| p == max_shares }.keys
          if !majority_share_holders.find { |owner| owner == player }
            # FIXME: Handle the case where multiple share the presidency criteria
            new_president = majority_share_holders.first
            @share_pool.change_president(presidency_share, player, new_president, player)
            regional.owner = new_president
            @log << "#{new_president.name} becomes president of #{regional.name} as majority owner"
          else
            regional.owner = player
          end

          float_corporation(regional) if regional.floated?
          regional
        end

        def float_corporation(corporation)
          @log << "#{corporation.name} floats"

          return if corporation.capitalization == :incremental

          floating_capital = case corporation.name
                             when 'BK', 'MS', 'CL', 'SB'
                               corporation.par_price.price * 8
                             else
                               corporation.par_price.price * corporation.total_shares
                             end

          @bank.spend(floating_capital, corporation)
          @log << "#{corporation.name} receives floating capital of #{format_currency(floating_capital)}"
        end

        private

        def mine_hex?(hex)
          option_cisleithania ? MINE_HEX_NAMES_CISLEITHANIA.include?(hex.name) : MINE_HEX_NAMES.include?(hex.name)
        end

        MOUNTAIN_RAILWAY_DEFINITION = {
          sym: 'B%1$d',
          name: 'B%1$d %2$s',
          value: 120,
          revenue: 25,
          desc: 'Moutain railway (B%1$d). Cannot be sold but can be exchanged for a 10 percent share in a '\
                'regional railway during phase 3 SR, or when first 4 train is bought. '\
                'If no regional railway shares are available from IPO this private is lost without compensation.',
          abilities: [
            {
              type: 'no_buy',
              owner_type: 'player',
            },
            {
              type: 'exchange',
              corporations: %w[BK MS CL SB BH],
              owner_type: 'player',
              from: %w[ipo market],
            },
          ],
        }.freeze

        def mountain_railway_definition(index)
          real_index = index + 1
          definition = MOUNTAIN_RAILWAY_DEFINITION.dup
          definition[:sym] = format(definition[:sym], real_index)
          definition[:name] = format(definition[:name], real_index, MOUNTAIN_RAILWAY_NAMES[real_index])
          definition[:desc] = format(definition[:desc], real_index)
          definition
        end
      end
    end
  end
end
