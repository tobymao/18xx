# frozen_string_literal: true

require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative '../base'
require_relative 'round/operating'
require_relative 'step/waterfall_auction'
require_relative 'step/buy_train'
require_relative 'step/route'

module Engine
  module Game
    module G2038
      class Game < Game::Base
        include_meta(G2038::Meta)
        include Map
        include Entities

        TILE_TYPE = :lawson
        TRACK_RESTRICTION = :permissive
        SELL_BUY_ORDER = :sell_buy
        SELL_AFTER = :p_any_operate
        CURRENCY_FORMAT_STR = '$%s'

        # Every tile carries no functional track at all (a single-city
        # tile centers itself automatically with no path needed; see
        # map.rb's own comment on MINE_LINK for the one, purely cosmetic,
        # exception) -- hex-to-hex adjacency is purely geometric
        # (Game::Base#connect_hexes builds hex.neighbors from grid
        # coordinates alone; Step::Route never inspects a tile's paths).
        # The base engine's IMPASSABLE_HEX_COLORS default (blue/gray/red)
        # treats a hex as impassable *unless* its tile has a path pointing
        # back at the neighbor (Hex#targeting?) -- with zero paths
        # anywhere, every blue/gray hex would otherwise silently lose all
        # its neighbor connections. There's no genuinely impassable
        # terrain in this game.
        IMPASSABLE_HEX_COLORS = [].freeze

        BANK_CASH = 10_000

        CERT_LIMIT = { 3 => 22, 4 => 16, 5 => 13, 6 => 11 }.freeze

        STARTING_CASH = { 3 => 600, 4 => 450, 5 => 360, 6 => 300 }.freeze

        HOME_TOKEN_TIMING = :never

        MARKET = [
          %w[71 80 90 101 113 126 140 155 171 188 206 225 245 266 288 311 335 360 386 413 441 470 500],
          %w[62 70 79 89 100p 112 125x 139 154 170 187 205 224 244 265 287 310 334 359 385 412 440 469],
          %w[54 61 69 78 88p 99 111 124 138 153 169 186 204 223 243 264],
          %w[46 53 60 68 77p 87 98 110 123 137 152 168 185],
          %w[36 45 52 59 67p 76 86 97 109 122 136],
          %w[24 35 44 51 58 66 75 85 96],
          %w[10z 23 34 43 50 57 65],
        ].freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(
          par: 'Public Corps Par',
          par_1: 'Asteroid League Par',
          par_2: 'All Growth Corps Par',
        )

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          par: :grey,
          par_1: :brown,
          par_2: :blue,
        )

        ENTITY_DISPLAY_ORDER = %w[FB IF DH OC TH LY TSI RU VP LE MM OPC RCC AL].freeze

        PHASES = [
          {
            name: '1',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
          },
          {
            name: '2',
            on: '4/3',
            train_limit: 4,
            tiles: %i[yellow],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '3',
            on: '5/4',
            train_limit: 3,
            tiles: %i[yellow],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '4',
            on: '6/5',
            train_limit: 3,
            tiles: %i[yellow gray],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '7/6',
            train_limit: 3,
            tiles: %i[yellow gray],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '9/7',
            train_limit: 2,
            tiles: %i[yellow gray],
            operating_rounds: 2,
          },
        ].freeze

        # Spaceship names are movement/cargo_holds (e.g. '3/2' = 3 MP, 2 cargo holds),
        # matching the physical spaceship card naming. cargo_holds: is stored in
        # Train#@opts by the base engine; a custom Train subclass will expose it properly.
        TRAINS = [
          {
            name: 'probe',
            distance: 4,
            cargo_holds: 0,
            price: 1,
            rusts_on: %w[4/3 6/2],
            num: 1,
          },
          {
            name: '3/2',
            distance: 3,
            cargo_holds: 2,
            price: 100,
            rusts_on: %w[5/4 7/3],
            num: 10,
            variants: [
              {
                name: '5/1',
                distance: 5,
                cargo_holds: 1,
                price: 100,
                rusts_on: %w[5/4 7/3],
              },
            ],
          },
          {
            name: '4/3',
            distance: 4,
            cargo_holds: 3,
            price: 200,
            rusts_on: %w[7/6 9/5],
            num: 10,
            variants: [
              {
                name: '6/2',
                distance: 6,
                cargo_holds: 2,
                price: 175,
                rusts_on: %w[7/6 9/5],
              },
            ],
          },
          {
            name: '5/4',
            distance: 5,
            cargo_holds: 4,
            price: 325,
            rusts_on: 'D',
            num: 6,
            variants: [
              {
                name: '7/3',
                distance: 7,
                cargo_holds: 3,
                price: 275,
                rusts_on: 'D',
              },
            ],
            events: [{ 'type' => 'asteroid_league_can_form' }],
          },
          {
            name: '6/5',
            distance: 6,
            cargo_holds: 5,
            price: 450,
            num: 5,
            variants: [
              {
                name: '8/4',
                distance: 8,
                cargo_holds: 4,
                price: 400,
              },
            ],
            events: [{ 'type' => 'close_companies' }],
          },
          {
            name: '7/6',
            distance: 7,
            cargo_holds: 6,
            price: 600,
            num: 2,
            variants: [
              {
                name: '9/5',
                distance: 9,
                cargo_holds: 5,
                price: 550,
              },
            ],
          },
          {
            name: '9/7',
            distance: 9,
            cargo_holds: 7,
            price: 950,
            num: 9,
            discount: {
              '5/4' => 700,
              '7/3' => 700,
              '6/5' => 700,
              '8/4' => 700,
              '7/6' => 700,
              '9/5' => 700,
            },
          },
        ].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'asteroid_league_can_form' => ['Asteroid League may be formed'],
          'group_b_corps_available' => ['Group B Corporations become available'],
          'group_c_corps_available' => ['Group C Corporations become available'],
        ).freeze

        def bank_starting_cash
          optional_short_game ? 4_000 : BANK_CASH
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            Engine::Step::CompanyPendingPar,
            G2038::Step::WaterfallAuction,
          ])
        end

        def new_operating_round(round_num = 1)
          G2038::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::DiscardTrain,
            G2038::Step::Route,
            G2038::Step::BuyTrain,
            Engine::Step::BuyCompany,
          ], round_num: round_num)
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when G2038::Round::Operating
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
              reorder_players
              new_stock_round
            end
        end

        def bank_sort(entities)
          entities.sort_by { |e| ENTITY_DISPLAY_ORDER.index(e.id) || ENTITY_DISPLAY_ORDER.size }
        end

        def setup
          @al_corporation = corporation_by_id('AL')
          @al_corporation.capitalization = :incremental

          @corporations.reject! { |c| c.id == 'AL' }

          @log << '2038 is a game of exploration, involving reveals of hidden tiles. Using Undo to revert '\
                  'a revealed tile to its hidden state could give a player an unfair benefit. Please exercise '\
                  'care in exploration, and refrain from undoing actions that have revealed tiles.'
          @mine_state = {}
          assign_exploration_tiles

          return if optional_variant_start_pack

          @available_corp_group = :group_a

          @corporations, @b_group_corporations = @corporations.partition do |corporation|
            corporation.type == :group_a
          end

          @b_group_corporations, @c_group_corporations = @b_group_corporations.partition do |corporation|
            corporation.type == :group_b
          end
        end

        def event_group_b_corps_available!
          @log << 'Group B corporations are now available'

          @corporations.concat(@b_group_corporations)
          @b_group_corporations = []
          @available_corp_group = :group_b
        end

        def event_group_c_corps_available!
          @log << 'Group C corporations are now available'

          @corporations.concat(@c_group_corporations)
          @c_group_corporations = []
          @available_corp_group = :group_c
        end

        def event_asteroid_league_can_form!
          @log << 'Asteroid League may now be formed'
          @corporations << @al_corporation
        end

        def event_asteroid_league_formed!
          @log << 'Asteroid League has formed'
        end

        def company_header(company)
          is_minor = @minors.find { |m| m.id == company.id }
          is_minor ? 'INDEPENDENT COMPANY' : 'PRIVATE COMPANY'
        end

        def after_par(corporation)
          super

          return unless @corporations.all?(&:ipoed)

          case @available_corp_group
          when :group_a
            event_group_b_corps_available!
          when :group_b
            event_group_c_corps_available!
          end
        end

        def after_buy_company(player, company, _price)
          target_price = optional_short_game ? 67 : 100
          share_price = stock_market.par_prices.find { |pp| pp.price == target_price }

          # NOTE: This should only ever be TSI
          abilities(company, :shares) do |ability|
            ability.shares.each do |share|
              if share.president
                par_corporation(share.corporation, share_price)
                share_pool.buy_shares(player, share, exchange: :free)
                after_par(share.corporation)
              else
                share_pool.buy_shares(player, share, exchange: :free)
              end
            end
          end
        end

        def optional_short_game
          @optional_rules&.include?(:optional_short_game)
        end

        def optional_variant_start_pack
          @optional_rules&.include?(:optional_variant_start_pack)
        end

        # Reset the Used Mine markers at the end of every OR -- a claimed/
        # used distinction doesn't exist yet in this PR (no claims step),
        # so this is currently a no-op in practice, but it's the correct,
        # already-anticipated hook for the claims PR that adds mine[:used]
        # tracking.
        def or_round_finished
          @mine_state.each_value do |state|
            state[:mines].each { |mine| mine[:used] = false }
          end
        end

        def cargo_holds_for_ship(ship)
          return 0 if ship.name == 'Probe'

          ship.name.split('/').last.to_i
        end

        def route_trains(entity)
          entity.runnable_trains
        end

        def can_run_route?(entity)
          !route_trains(entity).empty?
        end

        def revenue_str(route)
          route.hexes.map(&:id).join(' - ')
        end

        def route_distance(route)
          [route.hexes.size - 1, 0].max
        end

        def route_distance_str(route)
          "#{route_distance(route)}H"
        end

        # A hex counts as a deliverable destination if it is a transshipment
        # point or contains any placed base token (any company/corp).
        def deliverable_destination?(hex)
          return true if TRANSSHIPMENT_HEXES.include?(hex.id)

          hex_has_base?(hex)
        end

        # Shared by deliverable_destination? and (the not-yet-built)
        # can_place_station? -- both need "does this hex have a placed
        # base token (any company/corp)." `city.tokens` is an array of
        # token SLOTS, not placed tokens -- an unfilled slot holds `nil`
        # rather than being absent from the array, so `!tokens.empty?`
        # alone would be true even for an empty slot; `tokens.compact.
        # empty?` is the real "is anything actually placed here" check.
        def hex_has_base?(hex)
          hex.tile.cities.any? { |c| !c.tokens.compact.empty? }
        end

        EXPLORATION_BONUS = 10

        # `pay:` is false while G2038::Step::Route is still building a route
        # locally, unsubmitted (see Step::Route#local_choose!/@committing) --
        # the corp can't do anything with the bonus until the route step
        # ends anyway, so there's no need to move real cash (and log it)
        # for a flight that might still be discarded before it's ever
        # submitted. The real payment happens once, when the submitted
        # choice is actually replayed (live or on reload) with `pay: true`.
        def explore_hex!(hex_id, entity, pay: true)
          hex = hex_by_id(hex_id)
          tile_name = @hex_assignments[hex_id]

          mines =
            if tile_name && (tile = @tiles.find { |t| t.name == tile_name && !t.hex })
              # Random rotation (deterministic via the engine's seeded rand,
              # not Kernel#rand) so identically-typed mine tiles don't all
              # look the same way round -- purely cosmetic, tiles are
              # topologically symmetric under any rotation.
              tile.rotate!(rand % 6)
              hex.lay(tile)
              # Not update_tile_lists -- that's built for a normal upgrade
              # (new tile drawn from the pool, old one returned to it), but
              # a revealed mine tile never goes back into circulation. Just
              # remove it, so the Tile Manifest's count reflects what's
              # left un-revealed (Step::Route#rollback_local_flight!
              # reverses this if the exploring flight gets discarded).
              @tiles.delete(tile)
              MINE_DATA.fetch(tile_name, [])
            else
              []
            end

          @mine_state[hex_id] = {
            mines: mines.map { |m| m.merge(owner: nil, used: false) },
          }

          return unless pay

          # TODO(Probe PR): while TSI hasn't floated yet, this bonus goes
          # to the owner of the ST private (who is flying the Probe), not
          # to TSI's treasury (§6) -- deferred until the Probe is wired up.
          bank.spend(EXPLORATION_BONUS, entity)
          mine_count = mines.size
          @log << "#{entity.name} explores #{hex_id}: #{mine_count} #{mine_count == 1 ? 'mine' : 'mines'} found; "\
                  "#{entity.name} receives #{format_currency(EXPLORATION_BONUS)}"
        end

        # Revenue for a completed run. No pickup mechanic exists yet in
        # this PR (deferred to the claims/infrastructure PR), so the only
        # cargo a route can ever carry is a transshipment credit --
        # ending at a transshipment point with an EMPTY hold earns its
        # printed value instead (§7.1). Note that trace.size == 1 means
        # the ship has launched but not left the starting hex yet.
        def trace_revenue(_entity, ship, trace, cargo)
          return 0 if ship.name == 'Probe' || trace.size < 2
          return 0 unless deliverable_destination?(trace.last)

          cargo.sum { |c| c[:value] }
        end

        # A transshipment point's printed value works like a mine with
        # unlimited availability (no "used" marker, any ship any number of
        # times) -- but unlike an ore pickup, collecting it is never
        # automatic: it requires an explicit click on the hex (see
        # Step::Route#transshipment_choice/pick_up_transshipment!, the
        # latter's own comment on why -- the rules permit ending a flight
        # at a transshipment point without collecting there), and choosing
        # to collect ends the ship's flight immediately.
        # Phase-scaled values (§8): A13/D2/H10/O11 go $30 -> $60 and H18
        # goes $20 -> $70 once gray tiles unlock at Phase 4 -- already
        # handled for free by the standard route_revenue(phase, train)
        # mechanism, since map.rb's tile codes for these hexes are already
        # `yellow_X|gray_Y`. Rendered as an offboard part (not a city) so
        # the standard off-board box display shows both values.
        def transshipment_value(hex, ship)
          hex.tile.offboards.sum { |o| o.route_revenue(@phase, ship) }
        end

        def transshipment_hex?(hex_id)
          TRANSSHIPMENT_HEXES.include?(hex_id)
        end

        def ship_distance(_entity, ship)
          ship.distance
        end

        # Plain BFS shortest-hop tree from `start`, ignoring MP entirely
        # (1 MP per hop, unconstrained) -- memoized per source hex for the
        # life of this game. The underlying hex-adjacency graph (which
        # hexes are real vs. .empty, and which are neighbors) never
        # changes over a game, only what's explored/placed on top of it
        # does, so this exact same walk from a given source hex would
        # otherwise get recomputed byte-for-byte identically every time
        # it's asked for. Shared by Step::Route#plain_shortest_paths.
        #
        # Returns [dist, predecessor]: dist is {hex_id => hop count},
        # predecessor is {hex_id => the hex reached just before it} for
        # every hex reachable from start (excluding start itself).
        def hex_bfs(start)
          @hex_bfs_cache ||= {}
          return @hex_bfs_cache[start.id] if @hex_bfs_cache.key?(start.id)

          dist = { start.id => 0 }
          predecessor = {}
          queue = [start]

          until queue.empty?
            hex = queue.shift
            hex.neighbors.each_value do |neighbor|
              next if neighbor.empty || dist.key?(neighbor.id)

              dist[neighbor.id] = dist[hex.id] + 1
              predecessor[neighbor.id] = hex
              queue << neighbor
            end
          end

          @hex_bfs_cache[start.id] = [dist, predecessor]
        end

        # Pre-assign an asteroid tile to every blue space hex (Decision D,
        # ROADMAP.md). Derived deterministically from the game seed via
        # the engine's LCG rand, so every clone/undo rebuilds the identical
        # assignment without storing it in the action history. Never
        # revealed to clients until explored.
        def assign_exploration_tiles
          hex_ids = HEXES[:blue].keys.flatten.sort

          pool = []
          ('2001'..'2022').each do |name|
            TILES[name]['count'].times { pool << name }
          end

          @hex_assignments = hex_ids.zip(pool.sort_by { rand }).to_h
        end
      end
    end
  end
end
