# frozen_string_literal: true

require_relative '../base'
require_relative 'meta'

module Engine
  module Game
    module G1893
      class Game < Game::Base
        include_meta(G1893::Meta)

        attr_accessor :passers_first_stock_round

        register_colors(
          gray70: '#B3B3B3',
          gray50: '#7F7F7F'
        )

        CURRENCY_FORMAT_STR = '%dM'

        BANK_CASH = 7200

        CERT_LIMIT = { 2 => 18, 3 => 12, 4 => 9 }.freeze

        STARTING_CASH = { 2 => 900, 3 => 600, 4 => 450 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        TILES = {
          '3' => 2,
          '4' => 4,
          '5' => 2,
          '6' => 4,
          '7' => 3,
          '8' => 10,
          '9' => 7,
          '14' => 4,
          '15' => 5,
          '16' => 1,
          '19' => 1,
          '20' => 2,
          '23' => 3,
          '24' => 3,
          '25' => 1,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '39' => 1,
          '40' => 2,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '57' => 3,
          '58' => 4,
          '70' => 1,
          '141' => 2,
          '142' => 2,
          '143' => 2,
          '144' => 2,
          '145' => 1,
          '146' => 1,
          '147' => 1,
          '611' => 4,
          '619' => 3,
          'K1' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' =>
            'town=revenue:10;town=revenue:10;path=a:1,b:_0;path=a:_0,b:3;path=a:0,b:_1;path=a:_1,b:4;label=L',
          },
          'K5' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:0,b:_0;path=a:1,b:_0;label=BX',
          },
          'K6' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:0,b:_0;path=a:2,b:_0;label=BX',
          },
          'K14' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=BX',
          },
          'K15' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=BX',
          },
          'K57' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:0,b:_0;path=a:_0,b:3;label=BX',
          },
          'K55' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' =>
            'town=revenue:10;town=revenue:10;path=a:0,b:_0;path=a:_0,b:3;path=a:1,b:_1;path=a:_1,b:4;label=L',
          },
          'K170' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:50,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
              'path=a:5,b:_0;label=L',
          },
          'K201' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:0,b:_0;path=a:1,b:_0;label=K',
          },
          'K255' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=K',
          },
          'K269' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:50,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=K',
          },
          'K314' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:30;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=L',
          },
          'KV63' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
              'path=a:5,b:_0;label=S',
          },
          'KV201' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' =>
            'city=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;upgrade=cost:40,terrain:water;label=K',
          },
          'KV255' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
              'upgrade=cost:60,terrain:water;label=K',
          },
          'KV259' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
              'path=a:5,b:_0',
          },
          'KV269' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:50,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=K',
          },
          'KV333' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=K',
          },
          'KV619' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:30,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=S',
          },
        }.freeze

        LOCATION_NAMES = {
          'B5' => 'Düseldorf & Neuss',
          'D5' => 'Benrath',
          'D7' => 'Solingen',
          'B9' => 'Wuppertal',
          'E2' => 'Grevenbroich',
          'E4' => 'DOrmagen',
          'G6' => 'Leverkusen',
          'I2' => 'Bergheim',
          'I8' => 'Bergisch-Gladbach',
          'L3' => 'Frechen',
          'L5' => 'Köln',
          'L9' => 'Gummersbach',
          'N1' => 'Aachen',
          'O2' => 'Düren',
          'O4' => 'Brühl',
          'O6' => 'Porz',
          'P7' => 'Troizdorf',
          'P9' => 'Siegen',
          'R7' => 'Bonn-Beuel',
          'S6' => 'Bonn',
          'T3' => 'Euskirchen',
          'U6' => 'Andernach',
          'U8' => 'Neuwied',
        }.freeze

        MARKET = [['',
                   '',
                   '100',
                   '110',
                   '120',
                   '135',
                   '150',
                   '165',
                   '180',
                   '195',
                   '210',
                   '230',
                   '250',
                   '270',
                   '300',
                   '330'],
                  ['',
                   '80',
                   '90',
                   '100p',
                   '110',
                   '120x',
                   '135',
                   '150',
                   '165',
                   '180',
                   '195',
                   '210',
                   '230',
                   '250'],
                  %w[70 75 80 90p 100 110 120z 135 150 165 180],
                  %w[65 70 75 80p 90 100 110 120],
                  %w[60 65 70p 75 80 90],
                  %w[55 60p 65 70 75],
                  %w[50 55 60 65]].freeze

        PHASES = [
          {
            name: '2',
            on: '2',
            train_limit: { minor: 2, corporation: 3 },
            tiles: [:yellow],
            status: ['rhine_impassible'],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '3',
            train_limit: { minor: 2, corporation: 3 },
            tiles: %i[yellow green],
            status: ['can_buy_trains'],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: { minor: 2, corporation: 3 },
            tiles: %i[yellow green],
            status: %w[can_buy_trains may_found_agv],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: { minor: 1, corporation: 2 },
            tiles: %i[yellow green brown],
            status: %w[can_buy_trains may_found_hgk],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '6',
            train_limit: { minor: 1, corporation: 2 },
            tiles: %i[yellow green brown],
            status: ['can_buy_trains'],
            operating_rounds: 2,
          },
          {
            name: '8+x',
            on: '8+x',
            train_limit: { minor: 1, corporation: 2 },
            tiles: %i[yellow green brown gray],
            status: ['can_buy_trains'],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [{ name: '2', distance: 2, num: 8, price: 80, rusts_on: '4' },
                  {
                    name: '3',
                    distance: 3,
                    num: 4,
                    price: 180,
                    rusts_on: '6',
                    discount: { '2' => 40 },
                    events: [{ 'type' => 'remove_tile_block' }],
                  },
                  {
                    name: '4',
                    distance: 4,
                    num: 4,
                    price: 300,
                    rusts_on: '8+x',
                    discount: { '2' => 40, '3' => 90 },
                    events: [{ 'type' => 'agv_buyable' }],
                  },
                  {
                    name: '5',
                    distance: 5,
                    num: 3,
                    price: 450,
                    discount: { '3' => 90, '4' => 150 },
                    events: [{ 'type' => 'agv_founded' },
                             { 'type' => 'hgk_buyable' },
                             { 'type' => 'bonds_exchanged' }],
                  },
                  {
                    name: '6',
                    distance: 6,
                    num: 3,
                    price: 630,
                    discount: { '3' => 90, '4' => 150, '5' => 225 },
                    events: [{ 'type' => 'hgk_founded' }, { 'type' => 'eva_closed' }],
                  },
                  {
                    name: '8+x',
                    distance: [{ 'nodes' => %w[city offboard], 'pay' => 8, 'visit' => 8 },
                               { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                    num: 3,
                    price: 800,
                    available_on: '6',
                    discount: { '4' => 150, '5' => 225, '6' => 315 },
                  }].freeze

        COMPANIES = [
          {
            sym: 'FdSD',
            name: 'Fond de Stadt Düsseldorf',
            value: 190,
            revenue: 20,
            desc: 'May be exchanged against 20% shares of the Rheinbahn AG. This private cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
          {
            sym: 'EVA',
            name: 'Eisenbehnverkehrsmittel Aktiengesellschaft',
            value: 150,
            revenue: 30,
            desc: 'Leaves the game after the purchase of the first 6-train. This private cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
          {
            sym: 'HdSK',
            name: 'Häfen der Stadt Köln',
            value: 100,
            revenue: 10,
            desc: 'Exchange against 10% certificate of HGK. This private cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
          {
            sym: 'EKB',
            name: 'Euskirchener Kreisbahn',
            value: 210,
            revenue: 0,
            desc: "Buyer take control of minor with same name (EKB), and the price paid makes the minor's treasury. "\
              "EKB minor and private are exchanged into the 20% president's certificate of AGV when AGV is formed. "\
              'The private and minor cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
          {
            sym: 'KFBE',
            name: 'Köln-Frechen-Benzelrather Eisenbahn',
            value: 200,
            revenue: 0,
            desc: "Buyer take control of minor with same name (KFBE), and the price paid makes the minor's treasury. "\
              "KFBE minor and private are exchanged into the 20% president's certificate of AGV when AGV is formed. "\
              'The private and minor cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
          {
            sym: 'KSZ',
            name: 'Klienahn Siegburg-Zündorf',
            value: 100,
            revenue: 0,
            desc: "Buyer take control of minor with same name (KSZ), and the price paid makes the minor's treasury. "\
              'KSZ minor and private are exchanged into a 10% certificate of AGV when AGV is formed. '\
              'The private and minor cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
          {
            sym: 'KBE',
            name: 'Köln-Bonner Eisenbahn',
            value: 220,
            revenue: 0,
            desc: "Buyer take control of minor with same name (KBE), and the price paid makes the minor's treasury. "\
              "KBE minor and private are exchanged into the 20% president's certificate of HGK when HGK is formed. "\
              'The private and minor cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
          {
            sym: 'BKB',
            name: 'Bergheimer Kreisbahn',
            value: 190,
            revenue: 0,
            desc: "Buyer take control of minor with same name (BKB), and the price paid makes the minor's treasury. "\
              'BKB minor and private are exchanged into a 20% certificate of AGV when AGV is formed. '\
              'The private and minor cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
        ].freeze

        NAME_OF_PRIVATES = %w[FdSD EVA HdSK].freeze

        CORPORATIONS = [
          {
            float_percent: 50,
            float_excludes_market: true,
            always_market_price: true,
            name: 'Dürener Eisenbahn',
            sym: 'DE',
            tokens: [0, 40, 100],
            logo: '1893/DE',
            simple_logo: '1893/DE.alt',
            color: :blue,
            coordinates: 'O2',
            reservation_color: nil,
          },
          {
            name: 'Rhein-Sieg Eisenbahn',
            sym: 'RSE',
            float_percent: 50,
            float_excludes_market: true,
            always_market_price: true,
            tokens: [0, 40, 100],
            logo: '1893/RSE',
            simple_logo: '1893/RSE.alt',
            color: :pink,
            text_color: 'black',
            coordinates: 'R7',
            reservation_color: nil,
          },
          {
            name: 'Rheinbahn AG',
            sym: 'RAG',
            float_percent: 50,
            float_excludes_market: true,
            always_market_price: true,
            tokens: [0, 40, 100],
            color: '#B3B3B3',
            logo: '1893/RAG',
            simple_logo: '1893/RAG.alt',
            text_color: 'black',
            coordinates: 'D5',
            reservation_color: nil,
          },
          {
            name: 'Anleihen der Stadt Köln',
            sym: 'AdSK',
            float_percent: 101,
            always_market_price: true,
            max_ownership_percent: 100,
            floatable: false,
            tokens: [],
            shares: [0, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
            logo: '1893/AdSK',
            simple_logo: '1893/AdSK.alt',
            color: :gray,
            text_color: 'white',
            reservation_color: nil,
          },
          {
            name: 'AG für Verkehrswesen',
            sym: 'AGV',
            float_percent: 50,
            float_excludes_market: true,
            always_market_price: true,
            floatable: false,
            tokens: [100, 100],
            shares: [20, 10, 20, 10, 10, 10, 10, 10],
            logo: '1893/AGV',
            simple_logo: '1893/AGV.alt',
            color: :green,
            text_color: 'black',
            abilities: [
              {
                type: 'no_buy',
                description: 'Unavailable in SR before phase 4',
              },
            ],
            reservation_color: nil,
          },
          {
            name: 'Häfen und Güterverkehr Köln AG',
            sym: 'HGK',
            float_percent: 50,
            float_excludes_market: true,
            always_market_price: true,
            floatable: false,
            tokens: [100, 100],
            shares: [20, 10, 20, 10, 10, 10, 10, 10],
            logo: '1893/HGK',
            simple_logo: '1893/HGK.alt',
            color: :red,
            abilities: [
              {
                type: 'no_buy',
                description: 'Unavailable in SR before phase 5',
              },
            ],
            reservation_color: nil,
          },
        ].freeze

        MINORS = [
          {
            sym: 'EKB',
            name: '1 Euskirchener Kreisbahn',
            type: 'minor',
            tokens: [0],
            logo: '1893/EKB',
            simple_logo: '1893/EKB.alt',
            coordinates: 'T3',
            city: 0,
            color: :green,
          },
          {
            sym: 'KFBE',
            name: '2 Köln-Frechen-Benzelrather E',
            type: 'minor',
            tokens: [0],
            logo: '1893/KFBE',
            simple_logo: '1893/KFBE.alt',
            coordinates: 'L3',
            city: 0,
            color: :red,
          },
          {
            sym: 'KSZ',
            name: '3 Kleinbagn Siegburg-Zündprf',
            type: 'minor',
            tokens: [0],
            logo: '1893/KSZ',
            simple_logo: '1893/KSZ.alt',
            coordinates: 'P7',
            city: 0,
            color: :green,
          },
          {
            sym: 'KBE',
            name: '4 Köln-Bonner Eisenbahn',
            type: 'minor',
            tokens: [0],
            logo: '1893/KBE',
            simple_logo: '1893/KBE.alt',
            coordinates: 'O4',
            city: 0,
            color: :red,
          },
          {
            sym: 'BKB',
            name: '5 Bergerheimer Kreisbahn',
            type: 'minor',
            tokens: [0],
            logo: '1893/BKB',
            simple_logo: '1893/BKB.alt',
            coordinates: 'I2',
            city: 0,
            color: :green,
          },
        ].freeze

        LAYOUT = :flat

        AXES = { x: :number, y: :letter }.freeze

        GAME_END_CHECK = { bankrupt: :immediate, bank: :full_or }.freeze

        # Move down one step for a whole block, not per share
        SELL_MOVEMENT = :down_block

        # Cannot sell until operated
        SELL_AFTER = :operate

        # Sell zero or more, then Buy zero or one
        SELL_BUY_ORDER = :sell_buy

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'remove_tile_block' => ['Remove tile block', 'Rhine may be passed. N5 P5 becomes possible to lay tiles in'],
          'agv_buyable' => ['AGV buyable', 'AGV shares can be bought in the stockmarket'],
          'agv_founded' => ['AGV founded', 'AGV is founded if not yet founded'],
          'hgk_buyable' => ['HGK buyable', 'HGK shares can be bought in the stockmarket'],
          'hgk_founded' => ['HGK founded', 'AGV is founded if not yet founded'],
          'bonds_exchanged' => ['FdSD exchanged', 'Any remaining Fond der Stadt Düsseldorf bonds are exchanged'],
          'eva_closed' => ['EVA closed', 'EVA Is closed']
        ).freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'can_buy_trains' => ['Can Buy trains', 'Can buy trains from other corporations'],
          'rhine_impassible' => ['Rhine impassible', 'Cannot lay tile across the Rhine'],
          'may_found_agv' => ['May found AGV', 'AGV may be founded during the SR'],
          'may_found_hgk' => ['May found HGK', 'HGK may be founded during the SR']
        ).freeze

        MARKET_TEXT = {
          par: 'Par values for non-merged corporations',
          par_1: 'Par value for AGV',
          par_2: 'Par value for HGK',
        }.freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          par: :orange,
          par_1: :red,
          par_2: :green
        ).freeze

        OPTION_TILES_USE_GREY_PHASE = %w[KV201-0 KV269-0 KV255-0 KV333-0 KV259-0].freeze
        OPTION_TILES_REMOVE_GREY_PHASE = %w[K269-0 K255-0].freeze
        OPTION_TILES_USE_EXISTING_TRACK = %w[KV619-0 KV63-0].freeze

        MERGED_CORPORATIONS = %w[AGV HGK].freeze
        TILE_BLOCK = %w[N5 P5].freeze

        def num_trains(train)
          return train[:num] unless train[:name] == '2'

          optional_2_train ? 8 : 7
        end

        def optional_2_train
          @optional_rules&.include?(:optional_2_train)
        end

        def optional_grey_phase
          @optional_rules&.include?(:optional_grey_phase)
        end

        def optional_existing_track
          @optional_rules&.include?(:optional_existing_track)
        end

        def optional_hexes
          base_map
        end

        def optional_tiles
          remove_tiles(OPTION_TILES_USE_GREY_PHASE) unless optional_grey_phase
          remove_tiles(OPTION_TILES_REMOVE_GREY_PHASE) if optional_grey_phase
          remove_tiles(OPTION_TILES_USE_EXISTING_TRACK) unless optional_existing_track
        end

        def remove_tiles(tiles)
          tiles.each do |ot|
            @tiles.reject! { |t| t.id == ot }
            @all_tiles.reject! { |t| t.id == ot }
          end
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              if @turn == 1
                reorder_player_pass_order
              else
                reorder_players
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
                # If starting package remains, need to sell it first
                buyable_companies.empty? ? new_stock_round : new_auction_round
              end
            when Engine::Round::Draft
              if @is_init_round
                @is_init_round = false
                init_round_finished
                reorder_player_pass_order
                # If one certificate remains, continue with SR
                buyable_companies.one? ? new_stock_round : new_operating_round
              else
                new_stock_round
              end
            end
        end

        def reorder_player_pass_order
          return reorder_players(:first_to_pass) if @passers_first_stock_round.empty?

          pd = @passers_first_stock_round.first
          @players.rotate!(@players.index(pd))
          @log << "#{pd.name} has priority deal due to being first to pass"
        end

        def init_round
          @log << '-- Draft of starting package'
          @is_init_round = true
          Engine::Round::Draft.new(self, [
            G1893::Step::StartingPackageInitialAuction,
          ])
        end

        def new_auction_round
          @log << '-- Auction of starting package'
          Engine::Round::Draft.new(self, [
            G1893::Step::StartingPackageForcedAuction,
          ])
        end

        def new_operating_round(_round_num = 1)
          @passers_first_stock_round = []
          super
        end

        def stock_round
          G1893::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1893::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::DiscardTrain,
            Engine::Step::HomeToken,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G1893::Step::Dividend,
            G1893::Step::BuyTrain,
          ], round_num: round_num)
        end

        def float_str(entity)
          return 'Each pay 10M per OR' if entity.name == 'AdSK'
          return super if !entity.corporation || entity.floatable
          return super unless merged_corporation?(entity)

          'Floated via merge'
        end

        def status_str(entity)
          return 'Minor' if entity.minor?
          return 'Exchangable corporation' if !entity.floated? && merged_corporation?(entity)
          return 'Bond - Buy/Sell as share for set price' if entity == adsk

          'Corporation'
        end

        def adsk
          @adsk_corporation ||= corporation_by_id('AdSK')
        end

        def agv
          @agv_corporation ||= corporation_by_id('AGV')
        end

        def hgk
          @hgk_corporation ||= corporation_by_id('HGK')
        end

        def hdsk_reserved_share
          # 10% certificate in HGK
          { share: hgk.shares[1], private: company_by_id('HdSK'), minor: nil }
        end

        def ekb_reserved_share
          # President's certificate in AGV
          { share: agv.shares[0], private: nil, minor: minor_by_id('EKB') }
        end

        def kfbe_reserved_share
          # 20% certificate in HGK
          { share: hgk.shares[2], private: nil, minor: minor_by_id('KFBE') }
        end

        def ksz_reserved_share
          # 10% certificate in AGV
          { share: agv.shares[1], private: nil, minor: minor_by_id('KSZ') }
        end

        def kbe_reserved_share
          # President's certificate in HGK
          { share: hgk.shares[0], private: nil, minor: minor_by_id('KBE') }
        end

        def bkb_reserved_share
          # 20% certificate in AGV
          { share: agv.shares[2], private: nil, minor: minor_by_id('BKB') }
        end

        def merged_corporation?(corporation)
          MERGED_CORPORATIONS.include?(corporation.id)
        end

        def setup
          # Set up bonds to have a presidency share owned by the bank
          # and have a set price of 100
          adsk.shares[0].buyable = false
          @share_pool.transfer_shares(adsk.shares[0].to_bundle, @bank)
          bond_price = @stock_market.par_prices.find { |p| p.price == 100 }
          @stock_market.set_par(adsk, bond_price)
          adsk.ipoed = true
          move_buyable_shares_to_market(adsk)

          [hdsk_reserved_share, ekb_reserved_share, kfbe_reserved_share, ksz_reserved_share,
           kbe_reserved_share, bkb_reserved_share].each { |info| info[:share].buyable = false }

          @companies.each do |c|
            c.owner = @bank
            @bank.companies << c
          end

          @minors.each do |minor|
            hex = hex_by_id(minor.coordinates)
            hex.tile.cities[0].place_token(minor, minor.next_token)
          end

          # Use neutral tokens to make cities passable, but not blockable
          @neutral = Corporation.new(
            sym: 'N',
            name: 'Neutral',
            logo: 'open_city',
            simple_logo: 'open_city',
            tokens: [0, 0],
          )
          @neutral.owner = @bank
          @neutral.tokens.each { |token| token.type = :neutral }
          city_by_id('H5-0-0').place_token(@neutral, @neutral.next_token)
          city_by_id('J5-0-0').place_token(@neutral, @neutral.next_token)

          @passers_first_stock_round = []
        end

        def upgrades_to?(from, to, special = false)
          return super unless TILE_BLOCK.include?(from.hex.name)
          return super if from.hex.tile.icons.empty?

          raise GameError, "Cannot place a tile in #{from.hex.name} until green phase"
        end

        def event_remove_tile_block!
          @hexes
            .select { |hex| TILE_BLOCK.include?(hex.name) }
            .each { |hex| hex.tile.icons = [] }
        end

        def event_agv_buyable!
          @log << "Unreserved #{agv.name} shares are now available to buy"
          bond_price = @stock_market.par_prices.find { |p| p.price == 120 }
          @stock_market.set_par(agv, bond_price)
          move_buyable_shares_to_market(agv)
        end

        def event_agv_founded!
          found_agv unless agv.presidents_share.buyable
        end

        def found_agv
          @log << "#{agv.name} founded"
          form_mergable(agv, [ekb_reserved_share, ksz_reserved_share, bkb_reserved_share])
        end

        def event_hgk_buyable!
          @log << "Unreserved #{hgk.name} shares are now available to buy"
          bond_price = @stock_market.par_prices.reverse.find { |p| p.price == 120 }
          @stock_market.set_par(hgk, bond_price)
          move_buyable_shares_to_market(hgk)
        end

        def event_hgk_founded!
          found_hgk unless hgk.presidents_share.buyable
        end

        def found_hgk
          @log << "#{hgk.name} founded"
          form_mergable(hgk, [kbe_reserved_share, hdsk_reserved_share, kfbe_reserved_share])
        end

        def form_mergable(_mergable, _exchange_info)
          @log << 'NOT YET IMPLEMENTED'
        end

        def buyable?(entity)
          return true unless entity.corporation?

          entity.all_abilities.none? { |a| a.type == :no_buy }
        end

        def buyable_companies
          buyable = @companies.select { |c| !c.closed? && c.owner == @bank }

          # Privates A-C always buyable, minors topmost 2
          privates, minors = buyable.partition { |c| NAME_OF_PRIVATES.include?(c.sym) }
          privates + (minors.size < 2 ? minors : minors[0..1])
        end

        def remove_ability(corporation, ability_name)
          abilities(corporation, ability_name) do |ability|
            corporation.remove_ability(ability)
          end
        end

        def must_buy_train?(entity)
          return false if entity.minor?

          super
        end

        def payout_companies
          super

          @players.each do |player|
            bonds = player.num_shares_of(adsk)
            next unless bonds.positive?

            revenue = bonds * 10
            @log << "#{player.name} collects #{format_currency(revenue)} from #{adsk.name}"
            @bank.spend(revenue, player)
          end
        end

        def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil)
          corporation = bundle.corporation
          return super unless corporation == adsk

          @share_pool.sell_shares(bundle, allow_president_change: false, swap: swap)
        end

        private

        def move_buyable_shares_to_market(corporation)
          corporation.shares.each do |s|
            next unless s.buyable

            @share_pool.transfer_shares(s.to_bundle, @share_pool, price: 0, allow_president_change: false)
          end
        end

        def base_map
          simple_city = %w[I2 I8 L3 O2 O4 R7 T3]
          simple_city += %w[D7 E2] unless optional_existing_track
          optional_d7 = optional_existing_track ? ['D7'] : []
          optional_e2 = optional_existing_track ? ['E2'] : []
          {
            red: {
              ['A4'] => 'city=revenue:yellow_10|green_30|brown_50;'\
                        'path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0',
              ['B5'] => 'path=a:2,b:0;path=a:2,b:5',
              ['B9'] => 'offboard=revenue:yellow_20|green_30|brown_40,hide:1,groups:Wuppertal;'\
                        'path=a:1,b:_0,terminal:1',
              ['D9'] => 'offboard=revenue:yellow_20|green_30|brown_40,groups:Wuppertal'\
                        'path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1',
              ['L9'] => 'offboard=revenue:yellow_20|green_20|brown_20;'\
                        'path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1',
              ['N1'] => 'offboard=revenue:yellow_20|green_30|brown_50,hide:1,groups:Aachen;'\
                        'path=a:5,b:_0,terminal:1',
              ['P1'] => 'offboard=revenue:yellow_20|green_30|brown_50,groups:Aachen;'\
                        'path=a:4,b:_0,terminal:1',
              ['P9'] => 'offboard=revenue:yellow_20|green_20|brown_30;'\
                        'path=a:1,b:_0,terminal:1',
              ['U6'] => 'offboard=revenue:yellow_10|green_20|brown_30;'\
                        'path=a:4,b:_0,terminal:1',
              ['U8'] => 'offboard=revenue:yellow_20|green_30|brown_40;'\
                        'path=a:2,b:_0,terminal:1',
            },
            gray: {
              ['F1'] => 'town=revenue:10;path=a:4,b:_0;path=a:5,b:_0',
              %w[F5 T7] => 'path=a:1,b:2;path=a:3,b:5',
              ['F9'] => 'path=a:2,b:0',
              ['H5'] => 'city=revenue:20;path=a:0,b:_0',
              ['H9'] => 'path=a:3,b:1',
              ['J5'] => 'city=revenue:20;path=a:1,b:_0;path=a:0,b:_0;path=a:3,b:_0',
              ['J9'] => '',
              ['U4'] => 'town=revenue:10;path=a:2,b:_0;path=a:4,b:_0',
            },
            white: {
              %w[B3 C2 C6 D3 E6 F3 F7 G2 G4 I6 J3 J7 K2 K4 K8 L7 M2 N3 N7 O8 Q2 R5 S8 T5] => '',
              %w[B7 H3 I4 K6 M4 M8 Q4 Q8 S2] => 'town=revenue:0',
              simple_city => 'city=revenue:0',
              %w[C8 E8 G8 H7 P3 R3 S4] => 'upgrade=cost:40,terrain:mountain',
              ['G6'] => 'town=revenue:0;town=revenue:0;label=L',
              ['C4'] => 'border=edge:5,type:impassable',
              ['D5'] => 'city=revenue:0;border=edge:1,type:impassable;border=edge:2,type:impassable;label=BX',
              ['E4'] => 'city=revenue:0;border=edge:4,type:impassable',
              ['L5'] => 'city=revenue:0;border=edge:5,type:impassable;upgrade=cost:40,terrain:water;label=K',
              ['M6'] => 'upgrade=cost:40,terrain:water;border=edge:2,type:impassable',
              ['O6'] => 'city=revenue:0;border=edge:1,type:impassable;border=edge:2,type:impassable',
              ['Q6'] => 'border=edge:0,type:impassable;border=edge:1,type:impassable;border=edge:2,type:impassable',
              ['S6'] => 'city=revenue:0;upgrade=cost:40;border=edge:3,type:impassable;label=BX',
              ['N5'] => 'stub=edge:4;border=edge:5,type:impassable;icon=image:1893/green_hex',
              ['P5'] => 'town=revenue:0;border=edge:4,type:impassable;border=edge:5,type:impassable;'\
                        'icon=image:1893/green_hex',
            },
            yellow: {
              ['P7'] => 'city=revenue:20;path=a:1,b:_0;path=a:5,b:_0',
              optional_d7 => 'city=revenue:20;path=a:1,b:_0;path=a:4,b:_0;label=S',
              optional_e2 => 'city=revenue:20;path=a:0,b:_0;path=a:3,b:_0',
            },
          }
        end
      end
    end
  end
end
