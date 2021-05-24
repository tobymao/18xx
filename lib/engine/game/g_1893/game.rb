# frozen_string_literal: true

require_relative '../base'
require_relative 'meta'
require_relative '../stubs_are_restricted'

module Engine
  module Game
    module G1893
      class Game < Game::Base
        include_meta(G1893::Meta)

        attr_accessor :passers_first_stock_round, :agv_mergable, :agv_auto_found, :hgk_mergable, :hgk_auto_found,
                      :potential_discard_trains

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

        GAME_END_CHECK = { bankrupt: :immediate, bank: :full_or }.freeze

        # Move down one step for a whole block, not per share
        SELL_MOVEMENT = :down_block

        # Cannot sell until operated
        SELL_AFTER = :operate

        # Sell zero or more, then Buy zero or one
        SELL_BUY_ORDER = :sell_buy

        # New track must be usable
        TRACK_RESTRICTION = :restrictive

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

        LEVERKUSEN_YELLOW_TILES = %w[K1 K55].freeze
        LEVERKUSEN_GREEN_TILE = 'K314'
        LEVERKUSEN_HEX_NAME = 'G6'

        RHINE_PASSAGE = %w[L5 S6].freeze

        LOCATION_NAMES = {
          'B5' => 'Düsseldorf & Neuss',
          'D5' => 'Benrath',
          'D7' => 'Solingen',
          'B9' => 'Wuppertal',
          'E2' => 'Grevenbroich',
          'E4' => 'Dormagen',
          LEVERKUSEN_HEX_NAME => 'Leverkusen',
          'I2' => 'Bergheim',
          'I8' => 'Bergisch-Gladbach',
          'L3' => 'Frechen',
          'L5' => 'Köln',
          'L9' => 'Gummersbach',
          'N1' => 'Aachen',
          'O2' => 'Düren',
          'O4' => 'Brühl',
          'O6' => 'Porz',
          'P7' => 'Troisdorf',
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
                             { 'type' => 'fdsd_closed' }],
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
            name: 'Fond der Stadt Düsseldorf',
            value: 190,
            revenue: 20,
            desc: 'May be exchanged against 20% shares of the Rheinbahn AG in an SR (except the first one). '\
              'If less than 20% remains in the market the exchange will be what remains. May also be exchanged '\
              'to par RAG in which case the private is exchanged for the 20% presidency share. '\
              'FdSD is closed either due to the exchange or if FdSD has not been exchanged to do an exchange '\
              'after the first SR of phase 5. An exchange is handled as a Buy action. This private '\
              'cannot be sold.',
            abilities: [
              {
                type: 'no_buy',
                owner_type: 'player',
              },
              {
                type: 'exchange',
                corporations: ['RAG'],
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                from: %w[ipo market],
              },
            ],
            color: nil,
          },
          {
            sym: 'EVA',
            name: 'Eisenbahnverkehrsmittel Aktiengesellschaft',
            value: 150,
            revenue: 30,
            desc: 'Leaves the game after the purchase of the first 6-train. This private cannot be sold to '\
              'any corporation.',
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
            desc: "Buyer takes control of minor with same name (EKB), and the price paid makes the minor's treasury. "\
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
            desc: "Buyer takes control of minor with same name (KFBE), and the price paid makes the minor's treasury. "\
              "KFBE minor and private are exchanged into the 20% president's certificate of AGV when AGV is formed. "\
              'The private and minor cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
          {
            sym: 'KSZ',
            name: 'Kleinbahn Siegburg-Zündorf',
            value: 100,
            revenue: 0,
            desc: "Buyer takes control of minor with same name (KSZ), and the price paid makes the minor's treasury. "\
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
            desc: "Buyer takes control of minor with same name (KBE), and the price paid makes the minor's treasury. "\
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
            desc: "Buyer takes control of minor with same name (BKB), and the price paid makes the minor's treasury. "\
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
            type: 'corporation',
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
            type: 'corporation',
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
            type: 'corporation',
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
            tokens: [0, 0, 0, 100, 100],
            type: 'corporation',
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
            tokens: [0, 0, 0, 100, 100],
            type: 'corporation',
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
            coordinates: 'J5',
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
            name: '3 Kleinbahn Siegburg-Zündorf',
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
            name: '5 Bergheimer Kreisbahn',
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

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'remove_tile_block' => ['Remove tile block', 'Rhine may be passed. N5 P5 becomes possible to lay tiles in'],
          'agv_buyable' => ['AGV buyable', 'AGV shares can be bought in the stockmarket'],
          'agv_founded' => ['AGV founded', 'AGV is automatically founded in next Merge Round'],
          'hgk_buyable' => ['HGK buyable', 'HGK shares can be bought in the stockmarket'],
          'hgk_founded' => ['HGK founded', 'HGK is automatically founded in next Merge Round'],
          'fdsd_closed' => ['FdSD closed at end of SR', 'Fond der Stadt Düsseldorf is closed at end of next'\
              'Stock Round'],
          'eva_closed' => ['EVA closed', 'EVA is closed']
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
            when G1893::Round::Merger
              case @after_merger_round
              when :operating_round_first
                new_operating_round
              when :operating_round_second
                new_operating_round(@round.round_num + 1)
              when :stock_round
                @turn += 1
                new_stock_round
              when :auction_round
                @turn += 1
                new_auction_round
              end
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              if @turn == 1
                reorder_player_pass_order
              else
                reorder_players
              end
              @after_merger_round = :operating_round_first
              new_merger_round(1)
            when Engine::Round::Operating
              or_round_finished
              if @round.round_num < @operating_rounds
                @after_merger_round = :operating_round_second
                merger_count = 2
              else
                or_set_finished
                # If starting package remains, need to sell it first
                @after_merger_round = if buyable_companies.empty?
                                        :stock_round
                                      else
                                        :auction_round
                                      end
                merger_count = 3
              end
              new_merger_round(merger_count)
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

        def new_merger_round(count)
          @log << "-- Merge Round #{@turn}.#{count} (of 3) --"
          G1893::Round::Merger.new(self, [
            G1893::Step::PotentialDiscardTrainsAfterMerge,
            G1893::Step::Merger,
          ])
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

        def hdsk
          @hdsk_company ||= company_by_id('HdSK')
        end

        def ekb
          @ekb_minor ||= minor_by_id('EKB')
        end

        def kfbe
          @kfbe_minor ||= minor_by_id('KFBE')
        end

        def ksz
          @ksz_minor ||= minor_by_id('KSZ')
        end

        def kbe
          @kbe_minor ||= minor_by_id('KBE')
        end

        def bkb
          @bkb_minor ||= minor_by_id('BKB')
        end

        def eva
          @eva_private ||= company_by_id('EVA')
        end

        def hdsk_reserved_share
          # 10% certificate in HGK
          { share: hgk.shares[1], private: hdsk, minor: nil }
        end

        def ekb_reserved_share
          # President's certificate in AGV
          { share: agv.shares[0], private: nil, minor: ekb }
        end

        def kfbe_reserved_share
          # 20% certificate in HGK
          { share: hgk.shares[2], private: nil, minor: kfbe }
        end

        def ksz_reserved_share
          # 10% certificate in AGV
          { share: agv.shares[1], private: nil, minor: ksz }
        end

        def kbe_reserved_share
          # President's certificate in HGK
          { share: hgk.shares[0], private: nil, minor: kbe }
        end

        def bkb_reserved_share
          # 20% certificate in AGV
          { share: agv.shares[2], private: nil, minor: bkb }
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

          # Use neutral token to make cities passable, but not blockable
          @neutral = Corporation.new(
            sym: 'N',
            name: 'Neutral',
            logo: 'open_city',
            simple_logo: 'open_city',
            tokens: [0],
          )
          @neutral.owner = @bank
          @neutral.tokens.each { |token| token.type = :neutral }
          city_by_id('H5-0-0').place_token(@neutral, @neutral.next_token)

          @passers_first_stock_round = []
          @is_init_round = false
          @after_merger_round = nil
          @agv_mergable = false
          @hgk_mergable = false
          @agv_auto_found = false
          @hgk_auto_found = false
          agv.floatable = false
          hgk.floatable = false

          @potential_discard_trains = []

          @green_leverkusen_tile ||= @tiles.find { |t| t.name == LEVERKUSEN_GREEN_TILE }
        end

        include StubsAreRestricted

        def legal_tile_rotation?(_entity, hex, tile)
          return false unless legal_if_stubbed?(hex, tile)
          return true if @phase.current[:name] != '2' || !RHINE_PASSAGE.include?(hex.name)

          water_borders = hex.tile.borders.select { |b| b.type == :water }.map(&:edge)
          (water_borders & tile.exits).empty?
        end

        def upgrades_to?(from, to, _special = false, selected_company: nil)
          # Leverkusen can upgrade double dits to one city
          return to.name == LEVERKUSEN_GREEN_TILE if from.color == :yellow && from.hex.name == LEVERKUSEN_HEX_NAME

          # The TILE_BLOCK hexes cannot be upgraded until block has been removed (when phase 3 starts)
          return super unless TILE_BLOCK.include?(from.hex.name)
          return super if from.hex.tile.icons.empty?

          raise GameError, "Cannot place a tile in #{from.hex.name} until green phase"
        end

        def all_potential_upgrades(tile, tile_manifest: false)
          upgrades = super
          return upgrades if !tile_manifest || !LEVERKUSEN_YELLOW_TILES.include?(tile.name)

          # Tile manifest for Leverkusen yellow tiles should show green Leverkusen tile
          upgrades |= [@green_leverkusen_tile] if @green_leverkusen_tile

          upgrades
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
          @agv_mergable = true
          remove_ability(agv, :no_buy)
        end

        def event_agv_founded!
          @agv_mergable = false
          return if agv.presidents_share.buyable

          @log << "#{agv.name} will be founded at the start of the next Merge Round"
          @agv_auto_found = true
        end

        def found_agv
          @agv_mergable = false
          @agv_auto_found = false
          form_mergable(agv, mergers_agv)
        end

        def mergers_agv
          [ekb_reserved_share, ksz_reserved_share, bkb_reserved_share]
        end

        def mergers(target)
          reserved_shares = target == agv ? mergers_agv : mergers_hgk
          reserved_shares.map { |info| info['minor'] || info['private'] }
        end

        def event_hgk_buyable!
          @log << "Unreserved #{hgk.name} shares are now available to buy"
          bond_price = @stock_market.par_prices.reverse.find { |p| p.price == 120 }
          @stock_market.set_par(hgk, bond_price)
          move_buyable_shares_to_market(hgk)
          @hgk_mergable = true
          remove_ability(hgk, :no_buy)
        end

        def event_hgk_founded!
          @hgk_mergable = false
          return if hgk.presidents_share.buyable

          @log << "#{hgk.name} will be founded at the start of the next Merge Round"
          @hgk_auto_found = true
        end

        def found_hgk
          @hgk_mergable = false
          @hgk_auto_found = false
          form_mergable(hgk, mergers_hgk)
        end

        def mergers_hgk
          [kbe_reserved_share, hdsk_reserved_share, kfbe_reserved_share]
        end

        def form_mergable(mergable, exchange_info)
          @log << "#{mergable.name} receives #{format_currency(400)} from the bank as starting treasury"
          @bank.spend(400, mergable)
          mergable.floatable = true
          president_priority = []
          president_share = nil

          # If HGK, activate J5 token
          if mergable == hgk
            @log << "#{hgk.name} places an token in #{hgk.coordinates}"
            city_by_id('J5-0-0').place_token(hgk, hgk.next_token, free: true)
          end

          exchange_info.each do |mergeinfo|
            share = mergeinfo['share']
            puts("Share: #{share} from #{mergeinfo}")
            mergee = mergeinfo['minor'] || mergeinfo['private']
            player = mergee.owner
            if share.president
              extra_info = ' presidency'
              president_share = share
            else
              extra_info = ''
            end
            @log << "#{player.name} exchanges ownership of #{mergee.name} for #{share.percent}%#{extra_info} "\
              "share in #{share.corporation.name}"
            share.buyable = true
            @share_pool.transfer_shares(
              share.to_bundle,
              player,
              allow_president_change: false,
              price: 0
            )
            president_priority << player

            # If this was the private (company) - nothing more to do
            if mergee.company?
              mergee.close!
              next
            end

            # Mergee is a minor - transfer any cash
            if mergee.cash.positive?
              @log << "#{mergable.name} receives the #{mergee.name} treasure of #{format_currency(mergable.cash)}"
              mergee.spend(mergee.cash, mergable)
            end

            # Transfer any trains - director will later get a chance to discard any
            unless mergee.trains.empty?
              transferred = transfer(:trains, mergee, mergable)
              @log << "#{mergable.name} receives the trains from #{mergee.name}: #{transferred.map(&:name).join(', ')}"
            end

            # Transfer tokens (Note! HGK first token is )
            minor_token = mergee.tokens.first
            city = minor_token.city
            city.remove_reservation!(mergee)
            @log << "#{mergee.name}'s token in #{city.hex.name} is replaced with a token for #{mergable.name}"
            minor_token.remove!
            city.place_token(mergable, mergable.next_token, free: true)

            # Minor is no longer used
            mergee.close!
          end

          # Give presidency to largest share percentage - with previous mergee order as tie breaker
          share_holders = mergable.player_share_holders
          max_holding = share_holders.values.max
          majority_share_holders = share_holders.select { |_, p| p == max_holding }.keys
          if majority_share_holders.include?(president_share.owner)
            new_president = president_share.owner
          else
            majority_share_holders.sort_by! { |sh| president_priority.index(sh) || Integer::MAX }
            new_president = majority_share_holders.first
          end
          if president_share.owner == new_president
            @log << "#{president_share.owner.name} retains the presidency"
            mergable.owner = president_share.owner
          else
            @log << "#{new_president.name} becomes the president of #{mergable.name}"
            mergable.owner = new_president
            shares_for_presidency_swap(mergable, new_president).each do |s|
              move_share(s, president_share.owner)
            end
            move_share(president_share, new_president)
          end

          # Give president the chance to discard any trains
          if !mergable.trains.empty?
            puts("Mergable #{mergable.name} is added to potential_discard_trains")
            @potential_discard_trains << mergable
          else
            puts("Mergable #{mergable.name} has no trains")
          end

          mergable.ipoed = true
          @log << "#{mergable.name} have been completly founded and now floats"
        end

        def shares_for_presidency_swap(corporation, owner)
          # Try to get 2 10%, otherwise (when owner has 1 10% and 1 20%) return the 20%
          ten_percents = owner.shares_of(corporation).select { |s| s.percent == 10 }.take(2)
          return ten_percents if ten_percent.size == 2

          owner.shares_of(corporation).select { |s| s.percent == 20 }
        end

        def event_fdsd_closed!
          @log << 'NOT IMPLEMENTED - FdSD closed'
        end

        def event_eva_closed!
          @log << "#{eva.name} closed"
          eva.close!
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

        def president_assisted_buy(entity, train, price)
          # Can only assist if it is a train less minor, that
          # cannot afford the train.
          return super if entity.corporation? || entity.trains.size.positive? || price <= entity.cash ||
            entity.player.cash + entity.cash < price

          fee = 0
          president_assist = price - entity.cash
          [president_assist, fee]
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
          simple_city = %w[I2 I8 L3 O2 O4 T3]
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
              ['F5'] => 'path=a:1,b:2;path=a:3,b:5',
              ['T7'] => 'path=a:1,b:2;path=a:3,b:5;upgrade=cost:0,terrain:water',
              ['F9'] => 'path=a:2,b:0',
              ['H5'] => 'city=revenue:20;path=a:0,b:_0',
              ['H9'] => 'path=a:3,b:1',
              ['J5'] => 'city=revenue:20;path=a:1,b:_0;path=a:0,b:_0;path=a:3,b:_0',
              ['J9'] => '',
              ['U4'] => 'town=revenue:10;path=a:2,b:_0;path=a:4,b:_0',
            },
            white: {
              %w[B3 C2 C6 D3 E6 F3 F7 G2 G4 I6 J3 J7 K2 K4 K8 L7 M2 N3 N7 O8 Q2 R5 S8 T5] => '',
              %w[B7 H3 I4 M4 M8 Q4 Q8 S2] => 'town=revenue:0',
              ['K6'] => 'town=revenue:0;border=edge:1,type:water,cost:0',
              simple_city => 'city=revenue:0',
              ['R7'] => 'city=revenue:0;border=edge:1,type:water,cost:0',
              %w[C8 E8 G8 H7 P3 R3 S4] => 'upgrade=cost:40,terrain:mountain',
              [LEVERKUSEN_HEX_NAME] => 'town=revenue:0;town=revenue:0;label=L',
              ['C4'] => 'border=edge:5,type:impassable',
              ['D5'] => 'city=revenue:0;border=edge:1,type:impassable;border=edge:2,type:impassable;label=BX',
              ['E4'] => 'city=revenue:0;border=edge:4,type:impassable',
              ['L5'] => 'city=revenue:0;border=edge:5,type:impassable;upgrade=cost:40,terrain:water;label=K;'\
                        'border=edge:4,type:water,cost:0',
              ['M6'] => 'upgrade=cost:40,terrain:water;border=edge:2,type:impassable',
              ['O6'] => 'city=revenue:0;upgrade=cost:0,terrain:water;border=edge:1,type:impassable;'\
                        'border=edge:2,type:impassable',
              ['Q6'] => 'upgrade=cost:0,terrain:water;border=edge:0,type:impassable;border=edge:1,type:impassable;'\
                        'border=edge:2,type:impassable',
              ['S6'] => 'city=revenue:0;upgrade=cost:40,terrain:water;border=edge:3,type:impassable;'\
                        'border=edge:4,type:water,cost:0;label=BX',
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
