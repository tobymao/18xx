# frozen_string_literal: true

module Engine
  module Game
    module G1854
      module Entities
        LOCAL_NAMES = [
          'Mariazellerbahn',
          'Kernhofer Bahn',
          'Ybbstalbahn',
          'Steyrtalbahn',
          'Pyhrnbahn',
          'Salzkammergutbahn'
        ]

        LOCAL_COORDINATES =[
          'J38',
          'J38',
          'M35',
          'J32',
          'J28',
          'L28'
        ]

        LOCAL_CITIES = [
          0,
          1,
          0,
          0,
          0,
          0,
        ]

        # These companies exist only for the initial auction.  When these are bought, the minor is assigned
        # to the buyer, and the companies are closed.
        LOCAL_COMPANIES = LOCAL_NAMES.zip(LOCAL_COORDINATES, LOCAL_CITIES).map.with_index do |vals, index|
          name, coords, city = vals
          sym = (index + 1).to_s
          {
            sym: "L#{sym}",
            name: "#{name} (#{sym})",
            value: 150,
            corp_sym: sym,
            color: "white",
            local_railway: true,
          }
        end.freeze

        COMPANIES = [
          {
            name: 'Außerfernbahn',
            sym: 'P1',
            value: 20,
            revenue: 5,
            desc: 'Building on one mountain is 20 G cheaper.',
          },
          {
            name: 'Murtalbahn',
            sym: 'P2',
            value: 50,
            revenue: 10,
            desc: 'Building one tunnel is 40 G cheaper.',
          },
          {
            name: 'Graz-Köflacher Bahn',
            sym: 'P3',
            value: 70,
            revenue: 15,
            desc: 'Routes through Graz earn 10 G extra.',
          },
          *LOCAL_COMPANIES,
          {
            name: 'Arlbergbahn',
            sym: 'P4',
            value: 170,
            revenue: 20,
            desc: 'Receives a 20% VB share. Closes when the VB runs for the first time.',
          },
          {
            name: 'Semmeringbahn',
            sym: 'P5',
            value: 190,
            revenue: 25,
            desc: 'Receives a 20% SD share. Closes when the SD runs for the first time.',
          },
        ].freeze

        LOCAL_CORPORATIONS = LOCAL_NAMES.zip(LOCAL_COORDINATES, LOCAL_CITIES).map.with_index do |vals, index|
          name, coords, city = vals
          sym = (index + 1).to_s
          {
            sym: sym,
            name: name,
            coordinates: coords,
            city: city,
            logo: "1854/#{sym}",
            simple_logo: "1854/#{sym}",
            tokens: [0, 40],
            color: '#000000',
            type: 'minor',
            # float_percent: 100,
            # hide_shares: true,
            # shares: [100],
            # forced_share_percent: 100,
            # max_ownership_percent: 100,
          }
        end.freeze

        MINORS = LOCAL_CORPORATIONS

        CORPORATIONS = [
          {
            float_percent: 50,
            sym: 'KE',
            name: 'Kaiserin Elisabeth-Westbahn',
            logo: '1854/KE',
            simple_logo: '1854/KE',
            tokens: [0, 40, 100, 100],
            type: 'major',
            coordinates: 'C23',
            city: 1,
            color: '#F0AC9D',
            text_color: 'black',
          },
          {
            float_percent: 50,
            sym: 'FJ',
            name: 'Kaiser Franz Joseph-Bahn',
            logo: '1854/FJ',
            simple_logo: '1854/FJ',
            tokens: [0, 40, 100],
            type: 'major',
            coordinates: 'C23',
            city: 2,
            color: '#D4AB6F',
          },
          {
            float_percent: 50,
            sym: 'SD',
            name: 'Südbahn',
            logo: '1854/SD',
            simple_logo: '1854/SD',
            tokens: [0, 40, 100, 100],
            type: 'major',
            coordinates: 'C23',
            city: 0,
            color: '#E5712F',
          },
          {
            float_percent: 50,
            sym: 'KR',
            name: 'Kronprinz Rudolf-Bahn',
            logo: '1854/KR',
            simple_logo: '1854/KR',
            tokens: [0, 40, 100, 100],
            type: 'major',
            coordinates: 'C17',
            color: '#82B642',
            text_color: 'black',
          },
          {
            float_percent: 50,
            sym: 'KT',
            name: 'Kärntner Bahn',
            logo: '1854/KT',
            simple_logo: '1854/KT',
            tokens: [0, 40, 100],
            type: 'major',
            coordinates: 'H18',
            color: '#FFFFFF',
            text_color: 'black',
          },
          {
            float_percent: 50,
            sym: 'SB',
            name: 'Salzburger Bahn',
            logo: '1854/SB',
            simple_logo: '1854/SB',
            tokens: [0, 40, 100],
            type: 'major',
            coordinates: 'E13',
            color: '#FF3B1E',
          },
          {
            float_percent: 50,
            sym: 'NT',
            name: 'Nordtiroler Staatsbahn',
            logo: '1854/NT',
            simple_logo: '1854/NT',
            tokens: [0, 40, 100, 100],
            type: 'major',
            coordinates: 'F8',
            color: '#7DC5E0',
          },
          {
            float_percent: 50,
            sym: 'VB',
            name: 'Vorarlberger Bahn',
            logo: '1854/VB',
            simple_logo: '1854/VB',
            tokens: [0, 40, 100],
            type: 'major',
            coordinates: 'E3',
            color: '#ECE821',
            text_color: 'black',
          },
        ]
      end
    end
  end
end
