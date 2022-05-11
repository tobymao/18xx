# frozen_string_literal: true

module Engine
  module Game
    module G18SJ
      module Entities
        COMPANIES = [
          {
            name: 'Frykstadsbanan',
            value: 20,
            revenue: 5,
            desc: 'Blocks hex B17 if owned by a player.',
            sym: 'FRY',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['B17'] }],
          },
          {
            name: 'Nässjö-Oskarshamns järnväg',
            value: 20,
            revenue: 5,
            desc: 'Blocks hex D9 if owned by a player.',
            sym: 'NOJ',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['D9'] }],
          },
          {
            name: 'Göta kanalbolag',
            value: 40,
            revenue: 15,
            desc: 'When Göta kanalbolag is purchsed by a corporation The president of the corporation places the '\
                  'three Göta kanal bonus tokens (50/30/20) on up to three of the Göta kanalbolag hexes (E8, C8, C12'\
                  ' and C16).'\
                  '  When this corporation operates, if any of the hexes are included in a route, the route is '\
                  'increased by the sum of all Göta kanal bonuses that are reached by that route. After operating '\
                  'trains, the largest numbered Göta kanal bonus token that was included in a route is removed from '\
                  'play.  The tokens only affect the corporation that owns the Göta kanalbolag private company.',
            sym: 'GKB',
            abilities:
            [
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: %w[C8 C12 C16 E8],
                count: 3,
                owner_type: 'corporation',
              },
            ],
          },
          {
            name: 'Sveabolaget',
            value: 45,
            revenue: 15,
            desc: 'May lay or shift port token in Halmstad (A6), Ystad(C2), Kalmar (D5), Sundsvall (F19), Umeå (F23), '\
                  'and Luleå (G26).  Add 30 kr/symbol to all routes run to this location by owning company.',
            sym: 'SB',
            abilities:
            [
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: %w[A6 C2 D5 F19 F23 G26],
                owner_type: 'corporation',
              },
            ],
          },
          {
            name: 'The Gellivare Company',
            value: 70,
            revenue: 15,
            desc: 'Two extra connected track lays in hex E28 and F27.  Reduce terrain cost in D29 to 0 kr and in '\
                  'C30 to 75 kr.  Blocks hexes E28 and F27 if owned by a player.',
            sym: 'GC',
            abilities:
            [
              { type: 'blocks_hexes', owner_type: 'player', hexes: %w[E28 F27] },
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                hexes: %w[E28 F27],
                tiles: %w[7 8 9],
                when: %w[track owning_corp_or_turn],
                count: 2,
              },
              {
                type: 'tile_discount',
                discount: 75,
                terrain: 'mountain',
                owner_type: 'corporation',
                hexes: %w[C30 D29],
              },
              {
                type: 'tile_discount',
                discount: 100,
                terrain: 'water',
                owner_type: 'corporation',
                hexes: %w[C30],
              },
            ],
          },
          {
            name: 'Motala Verkstad',
            value: 90,
            revenue: 20,
            desc: "During the owning corporation's operating turn, that corporation may at any time buy one or more "\
                  'train/s from the bank. This power may only be used one time during the game and must be used '\
                  'before this private company closes.',
            sym: 'MV',
            abilities:
            [
              {
                type: 'train_buy',
                description: 'Buy trains before instead of after Run Routes',
                owner_type: 'corporation',
                count: 1,
              },
            ],
          },
          {
            name: 'Nydqvist och Holm AB',
            value: 90,
            revenue: 20,
            desc: 'May buy one train at half price (one time during the game).',
            sym: 'NOHAB',
            abilities:
            [
              {
                type: 'train_discount',
                discount: 0.5,
                owner_type: 'corporation',
                trains: %w[3 4 5],
                count: 1,
                when: 'buying_train',
              },
            ],
          },
          {
            name: 'Köping-Hults järnväg',
            value: 140,
            revenue: 0,
            desc: 'Buy gives control of minor corporation with same name. The minor starts with a 2 train '\
                  'and a home token and splits revenue evenly with owner. The minor may never buy or sell trains.'\
                  '  KHJ pays no revenue after the 2 train are rusted.',
            sym: 'KHJ',
          },
          {
            name: 'Nils Ericson',
            value: 220,
            revenue: 25,
            desc: "Receive president's share in a corporation randomly determined before auction. "\
                  'Buying player may once during the game take the priority deal at the beginning of one stock round '\
                  '(and this ability is not lost even if this private is closed). Cannot be bought by any corporation. '\
                  'Closes when the connected corporation buys its first train.',
            sym: 'NE',
            abilities: [{ type: 'shares', shares: 'random_president' }, { type: 'no_buy' }],
          },
          {
            name: 'Nils Ericson Första Tjing',
            value: 0,
            revenue: 0,
            desc: 'This represents the ability to once during the game take over the priority deal at the beginning '\
                  "of a stock round. Cannot be bought by any corporation. This 'company' remains through the whole game, "\
                  'or until the ability is used.',
            sym: 'NEFT',
            abilities: [{ type: 'no_buy' }, { type: 'close', on_phase: 'never', owner_type: 'player' }],
          },
          {
            name: 'Adolf Eugene von Rosen',
            value: 220,
            revenue: 30,
            desc: "Receive president's share in ÖKJ. Cannot be bought by any corporation. Closes when ÖKJ "\
                  'buys its first train.',
            sym: 'AEvR',
            abilities: [{ type: 'shares', shares: 'ÖKJ_0' },
                        { type: 'close', when: 'bought_train', corporation: 'ÖKJ' },
                        { type: 'no_buy' }],
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 60,
            sym: 'BJ',
            name: 'Bergslagernas järnvägar AB',
            logo: '18_sj/BJ',
            simple_logo: '18_sj/BJ.alt',
            tokens: [0, 40, 100],
            coordinates: 'A10',
            color: '#7b352a',
          },
          {
            float_percent: 60,
            sym: 'KFJ',
            name: 'Kil-Fryksdalens Järnväg',
            logo: '18_sj/KFJ',
            simple_logo: '18_sj/KFJ.alt',
            tokens: [0, 40, 100],
            coordinates: 'C16',
            color: :pink,
            text_color: 'black',
          },
          {
            float_percent: 60,
            sym: 'MYJ',
            name: 'Malmö-Ystads järnväg',
            logo: '18_sj/MYJ',
            simple_logo: '18_sj/MYJ.alt',
            tokens: [0, 40, 100],
            coordinates: 'A2',
            color: '#FFF500',
            text_color: 'black',
          },
          {
            float_percent: 60,
            sym: 'MÖJ',
            name: 'Mellersta Östergötlands Järnvägar',
            logo: '18_sj/MOJ',
            simple_logo: '18_sj/MOJ.alt',
            tokens: [0, 40],
            coordinates: 'E8',
            color: :turquoise,
            text_color: 'black',
          },
          {
            float_percent: 60,
            sym: 'SNJ',
            name: 'The Swedish-Norwegian Railroad Company ltd',
            logo: '18_sj/SNJ',
            simple_logo: '18_sj/SNJ.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'G26',
            color: :blue,
          },
          {
            float_percent: 60,
            sym: 'STJ',
            name: 'Sundsvall-Torphammars järnväg',
            logo: '18_sj/STJ',
            simple_logo: '18_sj/STJ.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'F19',
            color: '#0a0a0a',
          },
          {
            float_percent: 60,
            sym: 'SWB',
            name: 'Stockholm-Västerås-Bergslagens Järnvägar',
            logo: '18_sj/SWB',
            simple_logo: '18_sj/SWB.alt',
            tokens: [0, 40],
            coordinates: 'G10',
            city: 2,
            color: '#237333',
          },
          {
            float_percent: 60,
            sym: 'TGOJ',
            name: 'Trafikaktiebolaget Grängesberg-Oxelösunds järnvägar',
            logo: '18_sj/TGOJ',
            simple_logo: '18_sj/TGOJ.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'D19',
            color: '#f48221',
          },
          {
            float_percent: 60,
            sym: 'UGJ',
            name: 'Uppsala-Gävle järnväg',
            logo: '18_sj/UGJ',
            simple_logo: '18_sj/UGJ.alt',
            tokens: [0, 40, 100],
            coordinates: 'F13',
            color: :lime,
            text_color: 'black',
          },
          {
            float_percent: 60,
            sym: 'ÖKJ',
            name: 'Örebro-Köpings järnvägsaktiebolag',
            logo: '18_sj/OKJ',
            simple_logo: '18_sj/OKJ.alt',
            tokens: [0, 40],
            coordinates: 'C12',
            color: :purple,
          },
          {
            float_percent: 60,
            sym: 'ÖSJ',
            name: 'Östra Skånes Järnvägsaktiebolag',
            logo: '18_sj/OSJ',
            simple_logo: '18_sj/OSJ.alt',
            tokens: [0, 40, 100],
            coordinates: 'C2',
            color: '#d81e3e',
          },
        ].freeze

        MINORS = [
          {
            sym: 'KHJ',
            name: 'Köping-Hults järnväg',
            logo: '18_sj/KHJ',
            simple_logo: '18_sj/KHJ.alt',
            tokens: [0],
            coordinates: 'D15',
            color: '#ffffff',
            text_color: 'black',
          },
        ].freeze
      end
    end
  end
end
