# frozen_string_literal: true

module Engine
  module Game
    module G18FL
      module Entities
        COMPANIES = [
          {
            name: 'Tallahassee Railroad',
            value: 0,
            discount: -20,
            revenue: 5,
            desc: 'The winner of this private gets Priority Deal in the first Stock Round. '\
                  'This may be closed to grant a corporation an additional yellow tile lay. '\
                  'Terrain costs must be paid for normally',
            sym: 'TR',
            abilities: [
            {
              type: 'tile_lay',
              owner_type: 'player',
              count: 1,
              free: false,
              special: false,
              reachable: true,
              hexes: [],
              tiles: %w[3 4 6o 6fl 8 9 58],
              closed_when_used_up: true,
              when: %w[track owning_player_track],
            },
          ],
            color: nil,
          },
          {
            name: 'Peninsular and Occidental Steamship Company',
            value: 0,
            discount: -30,
            revenue: 10,
            desc: 'Closing this private grants the operating Corporation a port token to place on a port city. '\
                  'The port token increases the value of that city by $20 for that corporation only',
            sym: 'POSC',
            abilities: [
              {
                type: 'assign_hexes',
                when: 'any',
                hexes: %w[B5 B23 G20 K28],
                count: 1,
                owner_type: 'player',
              },
              {
                type: 'assign_corporation',
                when: 'any',
                count: 1,
                owner_type: 'player',
              },
            ],
            color: nil,
          },
          {
            name: 'Terminal Company',
            value: 0,
            discount: -70,
            revenue: 15,
            desc: 'Allows a Corporation to place an extra token on a city tile of yellow or higher. '\
                  'This is an additional token and free. This token does not use a token slot in the city. '\
                  'This token can be disconnected',
            sym: 'TC',
            min_players: 3,
            abilities: [
              {
                when: 'any',
                extra_action: true,
                type: 'token',
                owner_type: 'player',
                count: 1,
                from_owner: true,
                extra_slot: true,
                special_only: true,
                price: 0,
                teleport_price: 0,
                hexes: %w[B5 B15 B23 G20 F23 J27 K28],
              },
            ],
            color: nil,
          },
          {
            name: 'Florida East Coast Canal and Transportation Company',
            value: 0,
            discount: -110,
            revenue: 20,
            desc: 'This Company comes with a single share of the Florida East Coast Railway. '\
                  'This company closes when the FECR buys its first train',
            sym: 'FECCTC',
            min_players: 4,
            abilities: [{ type: 'close', when: 'bought_train', corporation: 'FECR' },
                        { type: 'shares', shares: 'FECR_1' }],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 50,
            sym: 'LN',
            name: 'Louisville and Nashville Railroad',
            logo: '18_fl/LN',
            simple_logo: '18_fl/LN.alt',
            shares: [40, 20, 20, 20],
            tokens: [0, 20, 20, 20],
            coordinates: 'B5',
            color: :darkblue,
            type: 'five_share',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'Plant',
            name: 'The Plant System',
            logo: '18_fl/Plant',
            simple_logo: '18_fl/Plant.alt',
            shares: [40, 20, 20, 20],
            tokens: [0, 20, 20, 20],
            coordinates: 'B15',
            color: :deepskyblue,
            text_color: 'black',
            type: 'five_share',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'SR',
            name: 'Southern Railway',
            logo: '18_fl/SR',
            simple_logo: '18_fl/SR.alt',
            shares: [40, 20, 20, 20],
            tokens: [0, 20, 20, 20],
            coordinates: 'B23',
            city: 1,
            color: '#76a042',
            type: 'five_share',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'SAL',
            name: 'Seaboard Air Line',
            logo: '18_fl/SAL',
            simple_logo: '18_fl/SAL.alt',
            shares: [40, 20, 20, 20],
            tokens: [0, 20, 20, 20],
            coordinates: 'B23',
            city: 0,
            color: '#f48221',
            type: 'five_share',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'ACL',
            name: 'Atlantic Coast Line',
            logo: '18_fl/ACL',
            simple_logo: '18_fl/ACL.alt',
            shares: [40, 20, 20, 20],
            tokens: [0, 20, 20, 20],
            coordinates: 'G20',
            color: :purple,
            type: 'five_share',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'FECR',
            name: 'Florida East Coast Railway',
            logo: '18_fl/FECR',
            simple_logo: '18_fl/FECR.alt',
            shares: [40, 20, 20, 20],
            tokens: [0, 20, 20, 20],
            coordinates: 'K28',
            color: '#d81e3e',
            type: 'five_share',
            always_market_price: true,
            reservation_color: nil,
          },
        ].freeze
      end
    end
  end
end
