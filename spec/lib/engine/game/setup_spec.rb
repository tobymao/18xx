# frozen_string_literal: true

require 'spec_helper'

# Exercises the `setup` god-move action (Engine::Action::Setup / Engine::Step::Setup)
# used to author preset game positions. Each facet is checked two ways:
#   1. direct replay  -- build a game from a setup action log and assert engine state
#   2. JSON round-trip -- serialize the raw actions, re-parse, replay again (this is
#      exactly the "Import hotseat game" path) and assert the same state survives.
# Representative sample spanning mechanics; 1871 is an alpha prototype (stress case).
SETUP_SAMPLE_TITLES = ['1830', '1846', '1889', '1817', 'The Old Prince 1871'].freeze

SETUP_THREE_PLAYERS = [
  { 'id' => 0, 'name' => 'Alice' },
  { 'id' => 1, 'name' => 'Bob' },
  { 'id' => 2, 'name' => 'Carol' },
].freeze

module Engine
  describe 'Setup action' do
    def setup_action(id: 1, **directives)
      { 'type' => 'setup', 'entity' => 0, 'entity_type' => 'player', 'id' => id }
        .merge(directives.transform_keys(&:to_s))
    end

    # Build + replay a game from a setup action log.
    def load_game(title, actions, players: SETUP_THREE_PLAYERS)
      game = Engine::Game.load({ 'title' => title, 'players' => players, 'actions' => actions })
      game.maybe_raise!
      game
    end

    # Re-load through a JSON serialize/parse round-trip (the import path).
    def round_trip(game, title, players: SETUP_THREE_PLAYERS)
      json = JSON.generate('title' => title, 'players' => players, 'actions' => game.raw_actions)
      reloaded = Engine::Game.load(JSON.parse(json))
      reloaded.maybe_raise!
      reloaded
    end

    describe 'cash' do
      SETUP_SAMPLE_TITLES.each do |title|
        it "sets corporation and player cash in #{title}" do
          game = load_game(title, [])
          corp_id = game.corporations.first.id

          game2 = load_game(title, [setup_action(cash: { corp_id => 777, '0' => 555 })])

          expect(game2.corporation_by_id(corp_id).cash).to eq(777)
          expect(game2.player_by_id(0).cash).to eq(555)

          reloaded = round_trip(game2, title)
          expect(reloaded.corporation_by_id(corp_id).cash).to eq(777)
          expect(reloaded.player_by_id(0).cash).to eq(555)
        end
      end
    end

    describe 'par + president' do
      it 'pars a corporation, assigns the president, and floats ownership in 1830' do
        game = load_game('1830', [setup_action(par: [
          { 'corporation' => 'B&O', 'price' => 100, 'president' => 1 },
        ])])

        bo = game.corporation_by_id('B&O')
        expect(bo.par_price.price).to eq(100)
        expect(bo.ipoed).to be(true)
        expect(bo.owner).to eq(game.player_by_id(1))
        expect(game.player_by_id(1).percent_of(bo)).to eq(bo.presidents_percent)

        reloaded = round_trip(game, '1830')
        rbo = reloaded.corporation_by_id('B&O')
        expect(rbo.par_price.price).to eq(100)
        expect(rbo.owner).to eq(reloaded.player_by_id(1))
      end
    end

    describe 'market' do
      it 'moves a par\'d corporation to an arbitrary market cell in 1830' do
        # Par B&O, then move it to the top-right end cell.
        market = game_market_end('1830')
        game = load_game('1830', [setup_action(
          par: [{ 'corporation' => 'B&O', 'price' => 100, 'president' => 1 }],
          market: [{ 'corporation' => 'B&O', 'coordinates' => market }],
        )])

        bo = game.corporation_by_id('B&O')
        expect(bo.share_price.coordinates).to eq(market)

        reloaded = round_trip(game, '1830')
        expect(reloaded.corporation_by_id('B&O').share_price.coordinates).to eq(market)
      end

      # Coordinates of a valid, non-par cell near the top of the market.
      def game_market_end(title)
        market = load_game(title, []).stock_market.market
        [0, market[0].size - 1]
      end
    end

    describe 'phase' do
      it 'advances the game to a target phase in 1830' do
        game = load_game('1830', [setup_action(phase: '4')])

        expect(game.phase.name).to eq('4')
        expect(round_trip(game, '1830').phase.name).to eq('4')
      end

      it 'raises for an unknown phase' do
        expect { load_game('1830', [setup_action(phase: '99')]).maybe_raise! }
          .to raise_error(Engine::GameError, /unknown phase/)
      end

      # phase.next! is generic (no round transition), so 1871 is included here.
      SETUP_SAMPLE_TITLES.each do |title|
        it "advances to the second phase in #{title}" do
          second = load_game(title, []).phase.phases[1][:name]
          game = load_game(title, [setup_action(phase: second)])

          expect(game.phase.name).to eq(second)
          expect(round_trip(game, title).phase.name).to eq(second)
        end
      end
    end

    describe 'trains' do
      it 'assigns a specific train to a corporation for free in 1830' do
        before = load_game('1830', []).depot.upcoming.count { |t| t.name == '4' }

        game = load_game('1830', [setup_action(
          phase: '4',
          par: [{ 'corporation' => 'B&O', 'price' => 100, 'president' => 1 }],
          trains: [{ 'corporation' => 'B&O', 'train' => '4' }],
        )])

        bo = game.corporation_by_id('B&O')
        expect(bo.trains.map(&:name)).to include('4')
        expect(game.depot.upcoming.count { |t| t.name == '4' }).to eq(before - 1)

        reloaded = round_trip(game, '1830')
        expect(reloaded.corporation_by_id('B&O').trains.map(&:name)).to include('4')
      end
    end

    describe 'rust' do
      it 'retires all trains of the named types in 1830' do
        game = load_game('1830', [setup_action(rust: %w[2 3])])

        expect(game.trains.any? { |t| %w[2 3].include?(t.name) && !t.rusted }).to be(false)
        expect(game.depot.upcoming.map(&:name) & %w[2 3]).to be_empty

        reloaded = round_trip(game, '1830')
        expect(reloaded.depot.upcoming.map(&:name) & %w[2 3]).to be_empty
      end

      it 'rusts a train already held by a corporation in 1830' do
        game = load_game('1830', [
          setup_action(id: 1, trains: [{ 'corporation' => 'PRR', 'train' => '2' }]),
          setup_action(id: 2, rust: ['2']),
        ])

        expect(game.corporation_by_id('PRR').trains.map(&:name)).not_to include('2')
      end
    end

    describe 'tiles' do
      it 'lays a tile with a rotation on a hex in 1830' do
        blank = load_game('1830', []).hexes
          .find { |h| h.tile.color == :white && h.tile.cities.empty? && h.tile.towns.empty? }

        game = load_game('1830', [setup_action(tiles: [
          { 'hex' => blank.id, 'tile' => '9', 'rotation' => 2 },
        ])])

        laid = game.hex_by_id(blank.id)
        expect(laid.tile.name).to eq('9')
        expect(laid.tile.rotation).to eq(2)
        # Routing-graph sanity: the graph invalidated by the lay rebuilds without error.
        expect do
          game.graph.clear
          game.graph.connected_hexes(game.corporations.first)
        end.not_to raise_error

        reloaded = round_trip(game, '1830')
        expect(reloaded.hex_by_id(blank.id).tile.name).to eq('9')
        expect(reloaded.hex_by_id(blank.id).tile.rotation).to eq(2)
      end
    end

    describe 'remove_tiles' do
      it 'reverts a hex to its original tile and returns the tile to the pool in 1830' do
        blank = load_game('1830', []).hexes
          .find { |h| h.tile.color == :white && h.tile.cities.empty? && h.tile.towns.empty? }
        original_name = blank.tile.name
        pool_before = load_game('1830', []).tiles.count { |t| t.name == '9' }

        game = load_game('1830', [setup_action(
          tiles: [{ 'hex' => blank.id, 'tile' => '9', 'rotation' => 0 }],
          remove_tiles: [blank.id],
        )])

        hex = game.hex_by_id(blank.id)
        expect(hex.tile.name).to eq(original_name)
        expect(hex.tile).to eq(hex.original_tile)
        expect(game.tiles.count { |t| t.name == '9' }).to eq(pool_before)

        reloaded = round_trip(game, '1830')
        expect(reloaded.hex_by_id(blank.id).tile).to eq(reloaded.hex_by_id(blank.id).original_tile)
      end
    end

    describe 'tokens' do
      it 'places a home token for a corporation in 1830' do
        game = load_game('1830', [setup_action(
          par: [{ 'corporation' => 'B&O', 'price' => 100, 'president' => 1 }],
          tokens: [{ 'corporation' => 'B&O', 'home' => true }],
        )])

        bo = game.corporation_by_id('B&O')
        expect(bo.tokens.count(&:used)).to be >= 1
        expect(bo.placed_tokens.first.hex.id).to eq(bo.coordinates)

        reloaded = round_trip(game, '1830')
        expect(reloaded.corporation_by_id('B&O').tokens.count(&:used)).to be >= 1
      end

      it 'places a token on an explicit hex/city in 1830' do
        prr = load_game('1830', []).corporation_by_id('PRR')
        game = load_game('1830', [setup_action(
          par: [{ 'corporation' => 'PRR', 'price' => 100, 'president' => 1 }],
          tokens: [{ 'corporation' => 'PRR', 'hex' => prr.coordinates, 'city' => 0 }],
        )])

        city = game.hex_by_id(prr.coordinates).tile.cities[0]
        expect(city.tokened_by?(game.corporation_by_id('PRR'))).to be(true)
      end
    end

    describe 'companies' do
      it 'assigns a private to a player and to a corporation, and closes one, in 1830' do
        game = load_game('1830', [setup_action(
          par: [{ 'corporation' => 'B&O', 'price' => 100, 'president' => 1 }],
          companies: [
            { 'company' => 'SV', 'owner' => 1 },      # to a player
            { 'company' => 'CS', 'owner' => 'B&O' },  # to a corporation
            { 'company' => 'DH', 'close' => true },
          ],
        )])

        sv = game.company_by_id('SV')
        cs = game.company_by_id('CS')
        dh = game.company_by_id('DH')

        expect(sv.owner).to eq(game.player_by_id(1))
        expect(game.player_by_id(1).companies).to include(sv)
        expect(cs.owner).to eq(game.corporation_by_id('B&O'))
        expect(game.corporation_by_id('B&O').companies).to include(cs)
        expect(dh.closed?).to be(true)

        # Assigned/closed privates are pulled out of the still-running auction.
        auction = game.round.active_step
        expect(auction.companies).not_to include(sv, cs, dh)

        reloaded = round_trip(game, '1830')
        expect(reloaded.company_by_id('SV').owner).to eq(reloaded.player_by_id(1))
        expect(reloaded.company_by_id('DH').closed?).to be(true)
      end
    end

    describe 'cross-game hardening' do
      %w[1830 1846 1889].each do |title|
        it "pars a corporation, assigns a president, and grants a share in #{title}" do
          base = load_game(title, [])
          corp = base.corporations.first
          price = base.stock_market.par_prices.first.price
          pct = corp.share_percent

          game = load_game(title, [setup_action(
            par: [{ 'corporation' => corp.id, 'price' => price, 'president' => 1 }],
            shares: [{ 'player' => 2, 'corporation' => corp.id, 'percent' => pct }],
          )])

          c = game.corporation_by_id(corp.id)
          expect(c.par_price.price).to eq(price)
          expect(c.owner).to eq(game.player_by_id(1))
          expect(game.player_by_id(2).percent_of(c)).to eq(pct)

          expect { round_trip(game, title) }.not_to raise_error
        end

        it "lays a track tile on a blank hex in #{title}" do
          blank = load_game(title, []).hexes
            .find { |h| h.tile.color == :white && h.tile.cities.empty? && h.tile.towns.empty? && h.tile.exits.empty? }
          next unless blank # some maps have no fully-blank hex; skip if so

          tile = load_game(title, []).tiles.find { |t| %w[7 8 9].include?(t.name) }
          game = load_game(title, [setup_action(tiles: [{ 'hex' => blank.id, 'tile' => tile.name }])])

          expect(game.hex_by_id(blank.id).tile.name).to eq(tile.name)
          expect { round_trip(game, title) }.not_to raise_error
        end
      end
    end

    describe 'bank cash' do
      it 'sets the bank cash directly, applied after entity transfers, in 1830' do
        game = load_game('1830', [setup_action(cash: { 'PRR' => 500, 'bank' => 99_999 })])

        expect(game.corporation_by_id('PRR').cash).to eq(500)
        expect(game.bank.cash).to eq(99_999)

        reloaded = round_trip(game, '1830')
        expect(reloaded.bank.cash).to eq(99_999)
      end
    end

    describe 'loans' do
      it 'takes loans for a corporation in 1817 (a loan game)' do
        corp_id = load_game('1817', []).corporations.first.id

        game = load_game('1817', [setup_action(
          par: [{ 'corporation' => corp_id, 'price' => 200, 'president' => 1 }],
          loans: [{ 'corporation' => corp_id, 'count' => 2 }],
        )])

        corp = game.corporation_by_id(corp_id)
        expect(corp.loans.size).to eq(2)
        expect(corp.cash).to be > 0

        reloaded = round_trip(game, '1817')
        expect(reloaded.corporation_by_id(corp_id).loans.size).to eq(2)
      end

      it 'raises for a game without loans' do
        expect do
          load_game('1830', [setup_action(loans: [{ 'corporation' => 'B&O', 'count' => 1 }])]).maybe_raise!
        end.to raise_error(Engine::GameError, /does not support loans/)
      end
    end

    describe 'advance (round positioning)' do
      # 1871 excluded: its prototype engine has a pre-existing Stock->Operating
      # transition bug (undefined method `name' for nil in its own next_round!),
      # so it can't be advanced into operation. Covered by the other facets.
      %w[1830 1846 1889 1817].each do |title|
        it "advances past the opening round to the first Stock Round in #{title}" do
          game = load_game(title, [setup_action(advance: { 'round' => 'stock' })])

          expect(game.round).to be_a(Engine::Round::Stock)
          expect(round_trip(game, title).round).to be_a(Engine::Round::Stock)
        end
      end

      it 'advances to a specified operating round with priority in 1830' do
        # Float B&O (60% out of IPO: 20% president at par + 40% granted) so there is
        # a corporation to operate -- otherwise the empty OR is auto-skipped.
        game = load_game('1830', [setup_action(
          par: [{ 'corporation' => 'B&O', 'price' => 100, 'president' => 1 }],
          shares: [{ 'player' => 1, 'corporation' => 'B&O', 'percent' => 40 }],
          advance: { 'round' => 'operating', 'turn' => 1, 'round_num' => 1, 'priority' => 1 },
        )])

        expect(game.corporation_by_id('B&O').floated?).to be(true)
        expect(game.round).to be_a(Engine::Round::Operating)
        expect(game.round.round_num).to eq(1)
        expect(game.turn).to eq(1)

        reloaded = round_trip(game, '1830')
        expect(reloaded.round).to be_a(Engine::Round::Operating)
        expect(reloaded.round.round_num).to eq(1)
      end
    end

    describe 'shares' do
      it 'grants IPO shares to a player in 1830' do
        game = load_game('1830', [setup_action(shares: [
          { 'player' => 1, 'corporation' => 'B&O', 'percent' => 40 },
        ])])

        bo = game.corporation_by_id('B&O')
        expect(game.player_by_id(1).percent_of(bo)).to eq(40)

        reloaded = round_trip(game, '1830')
        expect(reloaded.player_by_id(1).percent_of(reloaded.corporation_by_id('B&O'))).to eq(40)
      end
    end
  end
end
