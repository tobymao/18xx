# frozen_string_literal: true

module Engine
  module Game
    module G1864
      module Entities
        COMPANIES = [
          {
            name: 'Corporate Lobbyists',
            sym: 'CL1',
            value: 0,
            revenue: 0,
            desc: 'The company may exceed the current train limit by one train.',
            abilities: [{ type: 'train_limit', increase: 1, owner_type: 'corporation' }],
            color: nil,
          },
          {
            name: 'Corporate Lobbyists',
            sym: 'CL2',
            value: 0,
            revenue: 0,
            desc: 'The company may exceed the current train limit by one train.',
            abilities: [{ type: 'train_limit', increase: 1, owner_type: 'corporation' }],
            color: nil,
          },
          {
            name: 'U.S. Government Subsidy',
            sym: 'GS1',
            value: 0,
            revenue: 20,
            desc: 'At the start of each Operating Round, the Bank pays $20 to the treasury of the company.',
            color: nil,
          },
          {
            name: 'U.S. Government Subsidy',
            sym: 'GS2',
            value: 0,
            revenue: 20,
            desc: 'At the start of each Operating Round, the Bank pays $20 to the treasury of the company.',
            color: nil,
          },
          {
            name: 'Track Builder',
            sym: 'TB1',
            value: 0,
            revenue: 0,
            desc: 'The additional tile placement costs nothing. The Bank pays the $20 to Credit Mobilier.',
            color: nil,
          },
          {
            name: 'Track Builder',
            sym: 'TB2',
            value: 0,
            revenue: 0,
            desc: 'The additional tile placement costs nothing. The Bank pays the $20 to Credit Mobilier.',
            color: nil,
          },
          {
            name: 'Local Contract',
            sym: 'LC1',
            value: 0,
            revenue: 0,
            desc: 'Place a +$10 marker on one station of this company; that city pays $10 more '\
                  '(doubled for 2+2 and 5+5E trains).',
            abilities: [{ type: 'assign_hexes', hexes: [], count: 1, owner_type: 'corporation', when: 'owning_corp_or_turn' }],
            color: nil,
          },
          {
            name: 'Local Contract',
            sym: 'LC2',
            value: 0,
            revenue: 0,
            desc: 'Place a +$10 marker on one station of this company; that city pays $10 more '\
                  '(doubled for 2+2 and 5+5E trains).',
            abilities: [{ type: 'assign_hexes', hexes: [], count: 1, owner_type: 'corporation', when: 'owning_corp_or_turn' }],
            color: nil,
          },
          {
            name: 'Angel Investors',
            sym: 'AI1',
            value: 0,
            revenue: 0,
            desc: 'The company begins play with an additional $60 in its treasury.',
            color: nil,
          },
          {
            name: 'Angel Investors',
            sym: 'AI2',
            value: 0,
            revenue: 0,
            desc: 'The company begins play with an additional $60 in its treasury.',
            color: nil,
          },
          {
            name: 'Union Station',
            sym: 'US1',
            value: 0,
            revenue: 0,
            desc: 'An additional station token which may be placed for $10 per hexagon. It is removed at Phase 6.',
            abilities: [
              {
                type: 'token',
                owner_type: 'corporation',
                when: 'owning_corp_or_turn',
                hexes: [],
                price: 10,
                connected: true,
                count: 1,
              },
            ],
            color: nil,
          },
          {
            name: 'Central Station',
            sym: 'CS1',
            value: 0,
            revenue: 0,
            desc: 'An additional station token which may be placed for $10 per hexagon. It is removed at Phase 6.',
            abilities: [
              {
                type: 'token',
                owner_type: 'corporation',
                when: 'owning_corp_or_turn',
                hexes: [],
                price: 10,
                connected: true,
                count: 1,
              },
            ],
            color: nil,
          },
          {
            name: 'Early Adopter',
            sym: 'EA1',
            value: 0,
            revenue: 0,
            desc: 'The company begins play with a 2-train and pays $100 for it when it floats.',
            color: nil,
          },
          {
            name: 'Civil Engineering Firm',
            sym: 'CE1',
            value: 0,
            revenue: 0,
            desc: 'Terrain costs are free. The Bank pays the full terrain cost to Credit Mobilier.',
            color: nil,
          },
          {
            name: 'Double Tracks',
            sym: 'DT1',
            value: 0,
            revenue: 0,
            desc: 'Two trains of this company may share some or all track on their routes.',
            color: nil,
          },
          {
            name: 'Pullman Car',
            sym: 'PC1',
            value: 0,
            revenue: 0,
            desc: 'The company begins play with the Pullman, which lets one train serve an additional two small '\
                  'stations without counting them as stops. It may be bought by another company for a minimum of $1.',
            color: nil,
          },
        ].freeze

        MAJOR_CORPORATIONS = [
          {
            sym: 'CNW',
            name: 'Chicago & North Western Railway',
            simple_logo: '18_neb/CNW.alt',
            color: '#2C9846',
            text_color: 'white',
          },
          {
            sym: 'MP',
            name: 'Missouri Pacific Railroad',
            simple_logo: '1850/MP.alt',
            color: '#181D62',
            text_color: 'white',
          },
          {
            sym: 'SP',
            name: 'Southern Pacific Railroad',
            color: '#F48221',
            text_color: 'black',
          },
          {
            sym: 'NP',
            name: 'Northern Pacific Railway',
            simple_logo: '18_usa/NP.alt',
            color: '#000000',
            text_color: 'white',
          },
          {
            sym: 'RI',
            name: 'Chicago, Rock Island & Pacific Railroad',
            logo: '1850/RI',
            simple_logo: '1850/RI.alt',
            color: '#881319',
            text_color: 'white',
          },
          {
            sym: 'GN',
            name: 'Great Northern Railway',
            color: '#87CEFA',
            text_color: 'black',
          },
          {
            sym: 'CBQ',
            name: 'Chicago, Burlington & Quincy Railroad',
            logo: '1850/CBQ',
            simple_logo: '1850/CBQ.alt',
            color: '#8C8C7E',
            text_color: 'white',
          },
          {
            sym: 'ATSF',
            name: 'Atchison, Topeka & Santa Fe Railway',
            simple_logo: '18_usa/ATSF.alt',
            color: '#7090C9',
            text_color: 'white',
          },
        ].map do |major|
          {
            logo: "1864/#{major[:sym]}",
            simple_logo: "1864/#{major[:sym]}.alt",
            float_percent: 20,
            always_market_price: true,
            tokens: [0, 20, 40],
            type: 'major',
          }.merge(major)
        end.freeze

        GREEN_MINOR_RESERVATION_COLOR = '#009a54ff'

        MINOR_CORPORATIONS = [
          {
            sym: 'RF&CC',
            name: 'Rocky Fork & Cooke City Railway',
            coordinates: 'C18',
            color: '#4169A1',
            text_color: 'white',
          },
          {
            sym: 'BW&GF',
            name: 'Bismarck, Washburn & Great Falls Railway',
            coordinates: 'B23',
            color: '#2F3E46',
            text_color: 'white',
          },
          {
            sym: 'CO&G',
            name: 'Choctaw, Oklahoma & Gulf Railroad',
            simple_logo: '1864/CO&G.alt',
            coordinates: 'J25',
            color: '#C43A36',
            text_color: 'white',
          },
          {
            sym: 'CS',
            name: 'Colorado & Southern Railway',
            simple_logo: '1864/CS.alt',
            coordinates: 'G20',
            city: 2,
            color: '#57534E',
            text_color: 'white',
          },
          {
            sym: 'CP',
            name: 'Central Pacific Railroad',
            coordinates: 'G2',
            color: '#1D3557',
            text_color: 'white',
          },
          {
            sym: 'SFP&P',
            name: 'Santa Fe, Prescott & Phoenix Railway',
            coordinates: 'K12',
            color: '#F2D492',
            text_color: 'black',
            reservation_color: GREEN_MINOR_RESERVATION_COLOR,
          },
          {
            sym: 'UCR',
            name: 'Utah Central Railway',
            coordinates: 'G14',
            city: 1,
            color: '#8B8C5A',
            text_color: 'black',
          },
          {
            sym: 'FE&MV',
            name: 'Fremont, Elkhorn & Missouri Valley Railroad',
            simple_logo: '1864/FE&MV.alt',
            coordinates: 'F27',
            color: '#285943',
            text_color: 'white',
          },
          {
            sym: 'OSL',
            name: 'Oregon Short Line Railroad',
            logo: '1868_wy/OSL',
            simple_logo: '1868_wy/OSL.alt',
            coordinates: 'D11',
            city: 0,
            color: '#492F24',
            text_color: 'white',
            reservation_color: GREEN_MINOR_RESERVATION_COLOR,
          },
          {
            sym: 'DRG',
            name: 'Denver & Rio Grande Railroad',
            logo: '18_usa/DRG',
            simple_logo: '18_usa/DRG.alt',
            coordinates: 'G20',
            city: 0,
            color: '#A0522D',
            text_color: 'white',
          },
          {
            sym: 'RGW',
            name: 'Rio Grande Western Railway',
            simple_logo: '1864/RGW.alt',
            coordinates: 'G14',
            city: 0,
            color: '#2B7A78',
            text_color: 'white',
          },
          {
            sym: 'NM&SP',
            name: 'New Mexico & Southern Pacific Railroad',
            coordinates: 'J19',
            color: '#3FA7A0',
            text_color: 'black',
          },
          {
            sym: 'SLS&E',
            name: 'Seattle, Lake Shore & Eastern Railway',
            coordinates: 'B5',
            color: '#8C1C3A',
            text_color: 'white',
            reservation_color: GREEN_MINOR_RESERVATION_COLOR,
          },
          {
            sym: 'KP',
            name: 'Kansas Pacific Railway',
            simple_logo: '1864/KP.alt',
            coordinates: 'G20',
            city: 1,
            color: '#C8A153',
            text_color: 'black',
            reservation_color: GREEN_MINOR_RESERVATION_COLOR,
          },
          {
            sym: 'SCR',
            name: 'Southern California Railway',
            coordinates: 'J5',
            color: '#E377A6',
            text_color: 'black',
            reservation_color: GREEN_MINOR_RESERVATION_COLOR,
          },
          {
            sym: 'O&C',
            name: 'Oregon & California Railroad',
            coordinates: 'D5',
            color: '#6C8794',
            text_color: 'black',
            reservation_color: GREEN_MINOR_RESERVATION_COLOR,
          },
        ].map do |minor|
          {
            logo: "1864/#{minor[:sym]}",
            simple_logo: "1864/#{minor[:sym]}",
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            reservation_color: :yellow,
          }.merge(minor)
        end.freeze

        MINORS = [
          {
            sym: 'CM',
            name: 'Crédit Mobilier',
            logo: '1864/CM',
            simple_logo: '1864/CM',
            tokens: [],
            color: '#5b4636',
            text_color: 'white',
            abilities: [
              {
                type: 'description',
                description: 'Collects extra-tile and terrain costs',
                desc_detail: 'Every $20 extra yellow tile cost and every terrain cost is paid here; the Bank pays any '\
                             'amount waived by a Minor Company Ability. Immediately before each Merger Round the '\
                             'money is divided equally among the players, with any remainder staying here. Closes at '\
                             'Phase 4, returning its money to the Bank.',
              },
            ],
          },
        ].freeze

        UNION_PACIFIC = {
          sym: 'UP',
          coordinates: 'F27',
          name: 'Union Pacific Railroad',
          logo: '18_usa/UP',
          simple_logo: '18_usa/UP.alt',
          tokens: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          shares: [10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
          max_ownership_percent: 60,
          always_market_price: true,
          type: 'national',
          color: '#FFD700',
          text_color: 'black',
        }.freeze

        CORPORATIONS = (
          MAJOR_CORPORATIONS + MINOR_CORPORATIONS + [UNION_PACIFIC]
        ).freeze
      end
    end
  end
end
