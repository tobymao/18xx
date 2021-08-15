# frozen_string_literal: true

module Engine
  module Game
    module G1825
      module Entities
        UNIT1_COMPANIES = [
          {
            name: 'Swansea & Mumbles Railway',
            sym: 'S&M',
            value: 30,
            revenue: 5,
            color: :Green,
          },
          {
            name: 'Cromford & High Peak Railway',
            sym: 'C&HP',
            value: 75,
            revenue: 12,
            color: :Green,
          },
          {
            name: 'Canterbury & Whitstable Railway',
            sym: 'C&W',
            value: 130,
            revenue: 20,
            color: :Green,
          },
          {
            name: 'Liverpool & Manchester Railway',
            sym: 'L&M',
            value: 210,
            revenue: 30,
            color: :Green,
          },
        ].freeze

        UNIT2_COMPANIES = [
          {
            name: 'Leeds & Middleton Railway',
            sym: 'L&MI',
            value: 30,
            revenue: 5,
            color: :Green,
          },
          {
            name: 'Cromford & High Peak Railway',
            sym: 'C&HP',
            value: 75,
            revenue: 12,
            color: :Green,
          },
          {
            name: 'Stockton & Darlington',
            sym: 'S&D',
            value: 160,
            revenue: 25,
            color: :Green,
          },
          {
            name: 'Liverpool & Manchester Railway',
            sym: 'L&M',
            value: 210,
            revenue: 30,
            color: :Green,
          },
        ].freeze

        UNIT3_COMPANIES = [
          {
            name: 'Arbroath & Forfar',
            sym: 'A&F',
            value: 30,
            revenue: 5,
            color: :Green,
          },
          {
            name: 'Tanfield Wagon Way',
            sym: 'TWW',
            value: 60,
            revenue: 10,
            color: :Green,
          },
          {
            name: 'Stockton & Darlington',
            sym: 'S&D',
            value: 160,
            revenue: 25,
            color: :Green,
          },
        ].freeze

        UNIT1_CORPORATIONS = [
          {
            sym: 'LNWR',
            name: 'London & North Western Railway Company',
            capitalization: :full,
            tokens: [0, 40, 100, 100, 100],
            coordinates: 'T16',
            city: 0,
            color: 'black',
            text_color: 'white',
            reservation_color: nil,
            abilities: [{ type: 'blocks_hexes', owner_type: nil, hexes: ['U17'] }],
          },
          {
            sym: 'GWR',
            name: 'Great Western Railway Company',
            capitalization: :full,
            tokens: [0, 40, 100, 100, 100],
            coordinates: 'V14',
            city: 0,
            color: 'darkgreen',
            text_color: 'white',
            reservation_color: nil,
            abilities: [{ type: 'blocks_hexes', owner_type: nil, hexes: ['V18'] }],
          },
          {
            sym: 'GER',
            name: 'Great Eastern Railway Company',
            capitalization: :full,
            tokens: [0, 40, 100, 100],
            coordinates: 'V20',
            city: 4,
            color: 'darkblue',
            text_color: 'white',
            reservation_color: nil,
          },
          {
            sym: 'LSWR',
            name: 'London & South Western Railway Company',
            capitalization: :full,
            tokens: [0, 40, 100, 100],
            coordinates: 'V20',
            city: 0,
            color: 'lightgreen',
            text_color: 'black',
            reservation_color: nil,
            abilities: [{ type: 'blocks_hexes', owner_type: nil, hexes: ['W19'] }],
          },
          {
            sym: 'SECR',
            name: 'South Eastern & Chatham Railway Company',
            capitalization: :full,
            tokens: [0, 40, 100, 100],
            coordinates: 'W23',
            city: 0,
            color: 'yellow',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: 'LBSC',
            name: 'London Brighton & South Coast Railway Company',
            capitalization: :full,
            tokens: [0, 40, 100],
            coordinates: 'X20',
            city: 0,
            color: 'orange',
            text_color: 'black',
            reservation_color: nil,
            abilities: [{ type: 'blocks_hexes', owner_type: nil, hexes: ['X20'] }],
          },
        ].freeze

        UNIT2_CORPORATIONS = [
          {
            sym: 'LNWR',
            name: 'London & North Western Railway Company',
            capitalization: :full,
            tokens: [0, 40, 100, 100],
            coordinates: 'Q11',
            city: 0,
            color: 'black',
            text_color: 'white',
            reservation_color: nil,
          },
          {
            sym: 'MR',
            name: 'Midland Railway Company',
            capitalization: :full,
            tokens: [0, 40, 100, 100],
            coordinates: 'Q15',
            city: 0,
            color: 'red',
            text_color: 'white',
            reservation_color: nil,
            abilities: [{ type: 'blocks_hexes', owner_type: nil, hexes: ['Q15'] }],
          },
          {
            sym: 'NER',
            name: 'North Eastern Railway Company',
            capitalization: :full,
            tokens: [0, 40, 100, 100],
            coordinates: 'L14',
            city: 0,
            color: 'limegreen',
            reservation_color: nil,
            abilities: [{ type: 'blocks_hexes', owner_type: nil, hexes: ['L14'] }],
          },
          {
            sym: 'GCR',
            name: 'Great Central Railway Company',
            capitalization: :full,
            tokens: [0, 40, 100],
            coordinates: 'O15',
            city: 0,
            color: 'lightblue',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: 'GNR',
            name: 'Great Northern Railway Company',
            capitalization: :full,
            tokens: [0, 40, 100],
            coordinates: 'O15',
            city: 1,
            color: 'green',
            reservation_color: nil,
          },
          {
            sym: 'L&YR',
            name: 'Lancashire & Yorkshire Railway Company',
            capitalization: :full,
            tokens: [0, 40, 100],
            coordinates: 'O11',
            city: 0,
            color: 'purple',
            reservation_color: nil,
            abilities: [{ type: 'blocks_hexes', owner_type: nil, hexes: ['N10'] }],
          },
        ].freeze

        UNIT3_CORPORATIONS = [
          {
            sym: 'CR',
            name: 'Caledonia Railway',
            capitalization: :full,
            tokens: [0, 40, 100, 100],
            coordinates: 'G5',
            city: 2,
            color: :Blue,
            reservation_color: nil,
          },
          {
            sym: 'NBR',
            name: 'North British Railway',
            capitalization: :full,
            tokens: [0, 40, 100, 100],
            coordinates: 'G5',
            city: 1,
            color: '#868c1b',
            reservation_color: nil,
          },
          {
            sym: 'GSWR',
            name: 'Glasgow & South West Railway Company',
            capitalization: :full,
            tokens: [0, 40, 100],
            coordinates: 'G5',
            city: 0,
            color: '#8c1b2f',
            reservation_color: nil,
            abilities: [{ type: 'blocks_hexes', owner_type: nil, hexes: ['H4'] }],
          },
          {
            sym: 'GNoS',
            name: 'Great North of Scotland Railway',
            capitalization: :incremental,
            shares: [40, 20, 20, 20],
            tokens: [0],
            coordinates: 'B12',
            city: 0,
            color: 'green',
          },
          {
            sym: 'HR',
            name: 'Highland Railway',
            capitalization: :incremental,
            shares: [40, 20, 20, 20],
            tokens: [0],
            coordinates: 'B8',
            city: 0,
            color: '#e0b53d',
          },
          {
            sym: 'M&C',
            name: 'Maryport and Carslisle Railway Company',
            capitalization: :incremental,
            shares: [40, 20, 20, 20],
            tokens: [0],
            coordinates: 'K7',
            city: 0,
            color: '#1b967a',
          },
        ].freeze

        PAR_BY_CORPORATION = {
          'LNWR' => 100,
          'GWR' => 90,
          'MR' => 82,
          'NER' => 82,
          'CR' => 76,
          'GER' => 76,
          'LSWR' => 76,
          'NBR' => 76,
          'GCR' => 71,
          'GNR' => 71,
          'L&YR' => 71,
          'SECR' => 71,
          'GSWR' => 67,
          'LBSC' => 67,
        }.freeze

        REQUIRED_TRAIN = {
          'GNoS' => '5',
          'HR' => 'U3',
          'M&C' => '3T',
          'C' => 'U3',
          'FR' => '5',
          'LT&S' => '2+2',
          'M&GN' => '4T',
          'NSR' => '3T',
          'S&DR' => '5',
          'TV' => '4T',
        }.freeze

        # combining is based on http://fwtwr.com/fwtwr/18xx/1825/privates.asp
        def game_companies
          comps = []
          comps.concat(UNIT1_COMPANIES) if @units[1]
          comps.concat(UNIT3_COMPANIES.reject { |c| comps.any? { |comp| comp[:value] == c[:value] } }) if @units[3]
          comps.concat(UNIT2_COMPANIES.reject { |c| comps.any? { |comp| comp[:value] == c[:value] } }) if @units[2]
          comps
        end

        # FIXME: R1, R2, R3, K5, K7
        def game_corporations
          corps = []
          corps.concat(UNIT1_CORPORATIONS) if @units[1]
          if !@units[1] && @units[2]
            corps.concat(UNIT2_CORPORATIONS)
          elsif @units[1] && @units[2]
            corps.concat(UNIT2_CORPORATIONS.reject { |corp| corp[:sym] == 'LNWR' })
            lnwr = corps.find { |corp| corp[:sym] == 'LNWR' }
            lnwr[:tokens] = [0, 0, 40, 100, 100, 100, 100]
            lnwr[:coordinates] = %w[T16 Q11]
          end
          corps.concat(UNIT3_CORPORATIONS) if @units[3]
          # FIXME: Modify GWR (Unit 1) if playing with R2
          corps
        end
      end
    end
  end
end
