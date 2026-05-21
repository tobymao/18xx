# frozen_string_literal: true

module Engine
  module Game
    module G2038
      module Entities
        COMPANIES = [
          {
            name: 'Planetary Imports',
            sym: 'PI',
            value: 50,
            revenue: 10,
            desc: 'No special abilities',
            color: nil,
          },
          {
            name: 'Fast Buck',
            sym: 'FB',
            value: 100,
            revenue: 0,
            desc: 'May form a Growth Corporation OR join the Asteroid League for 1 share.'\
                  ' Earns $15/round into company treasury.',
            # TODO Phase 7: add custom ability type for $15/round treasury income
            # TODO Phase 2: remove exchange ability; private transfers immediately to minor FB at purchase.
            #   The merge into AL is handled by the minor's own mechanics (Phase 9), not this private.
            abilities: [
              { type: 'no_buy' },
            ],
            color: 'white',
          },
          {
            name: 'Ice Finder',
            sym: 'IF',
            value: 100,
            revenue: 0,
            desc: 'May form a Growth Corporation OR join the Asteroid League for 1 share.'\
                  ' $10 bonus per Ice ore delivered. Must draw a second tile if first drawn has no Ice mines.',
            delivery_bonus: :I,
            # TODO Phase 7: add custom ability type for second-tile-draw-if-no-ice exploration rule
            # TODO Phase 2: remove exchange ability; private transfers immediately to minor IF at purchase.
            abilities: [
              { type: 'no_buy' },
            ],
            color: 'white',
          },
          {
            name: 'Drill Hound',
            sym: 'DH',
            value: 100,
            revenue: 0,
            desc: 'May form a Growth Corporation OR join the Asteroid League for 1 share.'\
                  ' $10 bonus per Rare ore delivered. Must draw a second tile if first drawn has no Rare mines.',
            delivery_bonus: :R,
            # TODO Phase 7: add custom ability type for second-tile-draw-if-no-rare exploration rule
            # TODO Phase 2: remove exchange ability; private transfers immediately to minor DH at purchase.
            abilities: [
              { type: 'no_buy' },
            ],
            color: 'white',
          },
          {
            name: 'Ore Crusher',
            sym: 'OC',
            value: 100,
            revenue: 0,
            desc: 'May form a Growth Corporation OR join the Asteroid League for 1 share.'\
                  ' $10 bonus per Nickel ore delivered.',
            delivery_bonus: :N,
            # TODO Phase 2: remove exchange ability; private transfers immediately to minor OC at purchase.
            abilities: [
              { type: 'no_buy' },
            ],
            color: 'white',
          },
          {
            name: 'Torch',
            sym: 'TH',
            value: 100,
            revenue: 0,
            desc: 'May form a Growth Corporation OR join the Asteroid League for 1 share.'\
                  ' All spaceships operated by this company get +1 movement point.',
            # TODO Phase 7: add custom ability type for +1 MP bonus
            # TODO Phase 2: remove exchange ability; private transfers immediately to minor TH at purchase.
            abilities: [
              { type: 'no_buy' },
            ],
            color: 'white',
          },
          {
            name: 'Lucky',
            sym: 'LY',
            value: 100,
            revenue: 0,
            desc: 'May form a Growth Corporation OR join the Asteroid League for 1 share.'\
                  ' When exploring, draw 2 tiles and choose which to place (discard the other).',
            # TODO Phase 7: add custom ability type for draw-2-choose-1 exploration rule
            # TODO Phase 2: remove exchange ability; private transfers immediately to minor LY at purchase.
            abilities: [
              { type: 'no_buy' },
            ],
            color: 'white',
          },
          {
            name: 'Tunnel Systems',
            sym: 'TS',
            value: 120,
            revenue: 5,
            desc: 'Buyer receives a TSI Share. If owned by a corporation, may place 1 free Base on ANY'\
                  ' explored and unclaimed tile.',
            abilities: [
              { type: 'shares', shares: 'TSI_3' },
              # TODO Phase 10: replace with custom base-placement ability (owning_corp_or_turn, free, anywhere)
            ],
            color: '#40b1b9',
          },
          {
            name: 'Vacuum Associates',
            sym: 'VA',
            value: 140,
            revenue: 10,
            desc: 'Buyer receives a TSI Share. If owned by a corporation, may place 1 free'\
                  ' Refueling Station within range.',
            abilities: [
              { type: 'shares', shares: 'TSI_2' },
              # TODO Phase 10: replace with custom refueling-station ability (owning_corp_or_turn, free, in range)
            ],
            color: '#40b1b9',
          },
          {
            name: 'Robot Smelters, Inc.',
            sym: 'RS',
            value: 160,
            revenue: 15,
            desc: 'Buyer receives a TSI Share. If owned by a corporation, may place 1 free Claim within range.',
            abilities: [
              { type: 'shares', shares: 'TSI_1' },
              # TODO Phase 10: replace with custom claim ability (owning_corp_or_turn, free, in range)
            ],
            color: '#40b1b9',
          },
          {
            name: 'Space Transportation Co.',
            sym: 'ST',
            value: 180,
            revenue: 20,
            desc: "Buyer receives TSI president's Share and flies probe if TSI isn't active. May not be owned"\
                  ' by a corporation. Remove from the game after TSI buys a spaceship.',
            abilities: [
              { type: 'shares', shares: 'TSI_0' },
              { type: 'no_buy' },
              { type: 'close', when: 'bought_train', corporation: 'TSI' },
            ],
            color: '#40b1b9',
          },
          {
            name: 'Asteroid Export Co.',
            sym: 'AE',
            value: 180,
            revenue: 30,
            desc: "Forms Asteroid League, receiving its President's certificate. May not be bought by a"\
                  ' corporation. Remove from the game after AL acquires a spaceship.',
            abilities: [
              { type: 'close', when: 'bought_train', corporation: 'AL' },
              { type: 'no_buy' },
              {
                type: 'shares',
                shares: 'AL_0',
                when: %w[3 4],
              },
            ],
            color: '#fa3d58',
          },
        ].freeze

        MINORS = [
          {
            sym: 'FB',
            name: 'Fast Buck',
            value: 100,
            coordinates: 'G7',
            logo: '18_eu/1',
            tokens: [0],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[RU VP MM LE OPC RCC AL],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
          {
            sym: 'IF',
            name: 'Ice Finder',
            value: 100,
            coordinates: 'M13',
            logo: '18_eu/2',
            tokens: [0],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[RU VP MM LE OPC RCC AL],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
          {
            sym: 'DH',
            name: 'Drill Hound',
            value: 100,
            coordinates: 'D14',
            logo: '18_eu/3',
            tokens: [0],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[RU VP MM LE OPC RCC AL],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
          {
            sym: 'OC',
            name: 'Ore Crusher',
            value: 100,
            coordinates: 'M5',
            logo: '18_eu/4',
            tokens: [0],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[RU VP MM LE OPC RCC AL],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
          {
            sym: 'TH',
            name: 'Torch',
            value: 100,
            coordinates: 'B6',
            logo: '18_eu/5',
            tokens: [0],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[RU VP MM LE OPC RCC AL],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
          {
            sym: 'LY',
            name: 'Lucky',
            value: 100,
            coordinates: 'H14',
            logo: '18_eu/6',
            tokens: [0],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[RU VP MM LE OPC RCC AL],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
        ].freeze

        def corporation_opts
          { float_percent: 50 }
        end

        CORPORATIONS = [
          {
            sym: 'TSI',
            name: 'Trans-Space Incorporated',
            logo: 'g_2038/TSI',
            simple_logo: 'g_2038/TSI.alt',
            tokens: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            bases: [50],
            stations: [50, 50, 50],
            coordinates: 'K9',
            color: '#40b1b9',
            type: :group_a,
          },
          {
            sym: 'RU',
            name: 'Resources Unlimited',
            logo: 'g_2038/RU',
            simple_logo: 'g_2038/RU.alt',
            tokens: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            bases: [50],
            stations: [50],
            claim_costs: [0, 100],
            coordinates: 'D8',
            color: '#d57e59',
            type: :group_a,
          },
          {
            sym: 'VP',
            name: 'Venus Prospectors Limited',
            logo: 'g_2038/VP',
            simple_logo: 'g_2038/VP.alt',
            tokens: [0, 0, 0, 0, 0],
            bases: [50, 50, 50],
            stations: [25, 25, 25, 25],
            delivery_bonus: :R,
            coordinates: 'J2',
            color: '#3eb75b',
            type: :group_b,
          },
          {
            sym: 'LE',
            name: 'Lunar Enterprises',
            logo: 'g_2038/LE',
            simple_logo: 'g_2038/LE.alt',
            tokens: [0, 0, 0, 0, 0, 0, 0, 0, 0],
            bases: [50],
            stations: [50, 50],
            delivery_bonus: :N,
            coordinates: 'O1',
            color: '#fefc5d',
            type: :group_b,
          },
          {
            sym: 'MM',
            name: 'Mars Mining',
            logo: 'g_2038/MM',
            simple_logo: 'g_2038/MM.alt',
            tokens: [0, 0, 0, 0, 0, 0],
            bases: [25, 25, 25],
            stations: [50, 50, 50],
            delivery_bonus: :I,
            coordinates: 'A1',
            color: '#f66936',
            type: :group_b,
          },
          {
            sym: 'OPC',
            name: 'Outer Planet Consortium',
            logo: 'g_2038/OPC',
            simple_logo: 'g_2038/OPC.alt',
            tokens: [0, 0, 0, 0, 0, 0, 0],
            bases: [50, 50],
            stations: [0, 50, 50],
            delivery_bonus: :N,
            coordinates: 'J18',
            color: '#cc4f8c',
            text_color: 'black',
            type: :group_c,
          },
          {
            sym: 'RCC',
            name: 'Ring Construction Corporation',
            logo: 'g_2038/RCC',
            simple_logo: 'g_2038/RCC.alt',
            tokens: [0, 0, 0, 0, 0, 0, 0, 0],
            bases: [50, 50],
            stations: [50, 50],
            delivery_bonus: :N,
            coordinates: 'F18',
            color: '#f8b34b',
            text_color: 'black',
            type: :group_c,
          },
          {
            sym: 'AL',
            name: 'Asteroid League',
            logo: 'g_2038/AL',
            simple_logo: 'g_2038/AL.alt',
            tokens: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            bases: [50, 50, 50, 50, 50, 50, 50],
            stations: [50, 50, 50, 50],
            claim_costs: [60, 75, 100],
            coordinates: 'H10',
            color: '#fa3d58',
            type: :group_d,
          },
        ].freeze
      end
    end
  end
end
