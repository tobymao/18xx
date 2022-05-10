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
            logo: '1825/LNWR',
            simple_logo: '1825/LNWR.alt',
            capitalization: :full,
            max_ownership_percent: 100,
            tokens: [0, 40, 100, 100, 100],
            coordinates: 'T16',
            city: 0,
            color: '#000000',
            text_color: '#ffffff',
            reservation_color: nil,
            abilities: [{ type: 'blocks_hexes', owner_type: nil, hexes: ['U17'] }],
          },
          {
            sym: 'GWR',
            name: 'Great Western Railway Company',
            logo: '1825/GWR',
            simple_logo: '1825/GWR.alt',
            capitalization: :full,
            max_ownership_percent: 100,
            tokens: [0, 40, 100, 100, 100],
            coordinates: 'V14',
            city: 0,
            color: '#004225',
            text_color: '#ffffff',
            reservation_color: nil,
            abilities: [{ type: 'blocks_hexes', owner_type: nil, hexes: ['V18'] }],
          },
          {
            sym: 'GER',
            name: 'Great Eastern Railway Company',
            logo: '1825/GER',
            simple_logo: '1825/GER.alt',
            capitalization: :full,
            max_ownership_percent: 100,
            tokens: [0, 40, 100, 100],
            coordinates: 'V20',
            city: 4,
            color: '#191970',
            text_color: '#ffffff',
            reservation_color: nil,
            abilities: [{ type: 'blocks_hexes', owner_type: nil, hexes: ['U23'] }],
          },
          {
            sym: 'LSWR',
            name: 'London & South Western Railway Company',
            logo: '1825/LSWR',
            simple_logo: '1825/LSWR.alt',
            capitalization: :full,
            max_ownership_percent: 100,
            tokens: [0, 40, 100, 100],
            coordinates: 'V20',
            city: 0,
            color: '#d0f0c0',
            text_color: '#000000',
            reservation_color: nil,
            abilities: [{ type: 'blocks_hexes', owner_type: nil, hexes: ['W19'] }],
          },
          {
            sym: 'SECR',
            name: 'South Eastern & Chatham Railway Company',
            logo: '1825/SECR',
            simple_logo: '1825/SECR.alt',
            capitalization: :full,
            max_ownership_percent: 100,
            tokens: [0, 40, 100, 100],
            coordinates: 'W23',
            city: 0,
            color: '#ffef00',
            text_color: '#000000',
            reservation_color: nil,
            abilities: [],
          },
          {
            sym: 'LBSC',
            name: 'London Brighton & South Coast Railway Company',
            logo: '1825/LBSC',
            simple_logo: '1825/LBSC.alt',
            capitalization: :full,
            max_ownership_percent: 100,
            tokens: [0, 40, 100],
            coordinates: 'X20',
            city: 0,
            color: '#ffa500',
            text_color: 'black',
            reservation_color: nil,
            abilities: [{ type: 'blocks_hexes', owner_type: nil, hexes: ['X20'] }],
          },
        ].freeze

        UNIT2_CORPORATIONS = [
          {
            sym: 'LNWR',
            name: 'London & North Western Railway Company',
            logo: '1825/LNWR',
            simple_logo: '1825/LNWR.alt',
            capitalization: :full,
            max_ownership_percent: 100,
            tokens: [0, 40, 100, 100],
            coordinates: 'Q11',
            city: 0,
            color: '#000000',
            text_color: '#ffffff',
            reservation_color: nil,
          },
          {
            sym: 'MR',
            name: 'Midland Railway Company',
            logo: '1825/MR',
            simple_logo: '1825/MR.alt',
            capitalization: :full,
            max_ownership_percent: 100,
            tokens: [0, 40, 100, 100],
            coordinates: 'Q15',
            city: 0,
            color: '#ff0000',
            text_color: '#ffffff',
            reservation_color: nil,
            abilities: [{ type: 'blocks_hexes', owner_type: nil, hexes: ['Q15'] }],
          },
          {
            sym: 'NER',
            name: 'North Eastern Railway Company',
            logo: '1825/NER',
            simple_logo: '1825/NER.alt',
            capitalization: :full,
            max_ownership_percent: 100,
            tokens: [0, 40, 100, 100],
            coordinates: 'L14',
            city: 0,
            color: '#00ff00',
            text_color: '#000000',
            reservation_color: nil,
            abilities: [{ type: 'blocks_hexes', owner_type: nil, hexes: ['L14'] }],
          },
          {
            sym: 'GCR',
            name: 'Great Central Railway Company',
            logo: '1825/GCR',
            simple_logo: '1825/GCR.alt',
            capitalization: :full,
            max_ownership_percent: 100,
            tokens: [0, 40, 100],
            coordinates: 'O15',
            city: 0,
            color: '#89cff0',
            text_color: '#000000',
            reservation_color: nil,
          },
          {
            sym: 'GNR',
            name: 'Great Northern Railway Company',
            logo: '1825/GNR',
            simple_logo: '1825/GNR.alt',
            capitalization: :full,
            max_ownership_percent: 100,
            tokens: [0, 40, 100],
            coordinates: 'O15',
            city: 1,
            color: '#228c22',
            text_color: '#ffffff',
            reservation_color: nil,
          },
          {
            sym: 'L&Y',
            name: 'Lancashire & Yorkshire Railway Company',
            logo: '1825/LY',
            simple_logo: '1825/LY.alt',
            capitalization: :full,
            max_ownership_percent: 100,
            tokens: [0, 40, 100],
            coordinates: 'O11',
            city: 1,
            color: '#6c0ba9',
            text_color: '#ffffff',
            reservation_color: nil,
            abilities: [{ type: 'blocks_hexes', owner_type: nil, hexes: ['N10'] }],
          },
        ].freeze

        UNIT3_CORPORATIONS = [
          {
            sym: 'CR',
            name: 'Caledonia Railway',
            logo: '1825/CR',
            simple_logo: '1825/CR.alt',
            capitalization: :full,
            max_ownership_percent: 100,
            tokens: [0, 40, 100, 100],
            coordinates: 'G5',
            city: 2,
            color: '#0047ab',
            text_color: '#ffffff',
            reservation_color: nil,
          },
          {
            sym: 'NBR',
            name: 'North British Railway',
            logo: '1825/NBR',
            simple_logo: '1825/NBR.alt',
            capitalization: :full,
            max_ownership_percent: 100,
            tokens: [0, 40, 100, 100],
            coordinates: 'G5',
            city: 1,
            color: '#7c4700',
            text_color: '#ffffff',
            reservation_color: nil,
          },
          {
            sym: 'GSWR',
            name: 'Glasgow & South West Railway Company',
            logo: '1825/GSWR',
            simple_logo: '1825/GSWR.alt',
            capitalization: :full,
            max_ownership_percent: 100,
            tokens: [0, 40, 100],
            coordinates: 'G5',
            city: 0,
            color: '#001800',
            text_color: '#ffff00',
            reservation_color: nil,
            abilities: [{ type: 'blocks_hexes', owner_type: nil, hexes: ['H4'] }],
          },
          {
            sym: 'GNoS',
            name: 'Great North of Scotland Railway',
            logo: '1825/GNS',
            simple_logo: '1825/GNS.alt',
            capitalization: :incremental,
            float_percent: 40,
            shares: [40, 20, 20, 20],
            price_percent: 10,
            max_ownership_percent: 100,
            tokens: [0],
            coordinates: 'B12',
            city: 0,
            color: '#299617',
            text_color: '#000000',
          },
          {
            sym: 'HR',
            name: 'Highland Railway',
            logo: '1825/HR',
            simple_logo: '1825/HR.alt',
            capitalization: :incremental,
            float_percent: 40,
            shares: [40, 20, 20, 20],
            price_percent: 10,
            max_ownership_percent: 100,
            tokens: [0],
            coordinates: 'B8',
            city: 0,
            color: '#ffd300',
            text_color: '#000000',
          },
          {
            sym: 'M&C',
            name: 'Maryport and Carslisle Railway Company',
            logo: '1825/MC',
            simple_logo: '1825/MC.alt',
            capitalization: :incremental,
            float_percent: 40,
            shares: [40, 20, 20, 20],
            price_percent: 10,
            max_ownership_percent: 100,
            tokens: [0],
            coordinates: 'K7',
            city: 0,
            color: '#00ffef',
            text_color: '#000000',
          },
        ].freeze

        R1_CORPORATIONS = [
          {
            sym: 'Cam',
            name: 'Cambrian Railway',
            logo: '1825/CAM',
            simple_logo: '1825/CAM.alt',
            capitalization: :incremental,
            float_percent: 40,
            shares: [40, 20, 20, 20],
            price_percent: 10,
            max_ownership_percent: 100,
            tokens: [0],
            coordinates: 'R8',
            color: '#48260d',
            text_color: '#ffffff',
            abilities: [{ type: 'blocks_hexes', owner_type: nil, hexes: ['R8'] }],
          },
          {
            sym: 'TV',
            name: 'Taff Vale Railway',
            logo: '1825/TV',
            simple_logo: '1825/TV.alt',
            capitalization: :incremental,
            float_percent: 40,
            shares: [40, 20, 20, 20],
            price_percent: 10,
            max_ownership_percent: 100,
            tokens: [0],
            coordinates: 'V8',
            color: '#ffa6c9',
            text_color: '#000000',
          },
        ].freeze

        R2_CORPORATIONS = [
          {
            sym: 'S&DR',
            name: 'Somerset & Dorset Railway',
            logo: '1825/SDR',
            simple_logo: '1825/SDR.alt',
            capitalization: :incremental,
            float_percent: 40,
            shares: [40, 20, 20, 20],
            price_percent: 10,
            max_ownership_percent: 100,
            tokens: [0],
            coordinates: 'W9',
            color: '#4666ff',
            text_color: '#ffffff',
          },
        ].freeze

        R3_CORPORATIONS = [
          {
            sym: 'M&GN',
            name: 'Midland & Great Northern Joint Railway',
            logo: '1825/MGN',
            simple_logo: '1825/MGN.alt',
            capitalization: :incremental,
            float_percent: 40,
            shares: [40, 20, 20, 20],
            price_percent: 10,
            max_ownership_percent: 100,
            tokens: [0],
            coordinates: 'Q23',
            color: '#cc5500',
            text_color: '#ffffff',
          },
        ].freeze

        K5_CORPORATIONS = [
          {
            sym: 'FR',
            name: 'Furness Railway',
            logo: '1825/FR',
            simple_logo: '1825/FR.alt',
            capitalization: :incremental,
            float_percent: 40,
            shares: [40, 20, 20, 20],
            price_percent: 10,
            max_ownership_percent: 100,
            tokens: [0],
            coordinates: 'M9',
            color: '#fafad2',
            text_color: '#000000',
          },
          {
            sym: 'NS',
            name: 'North Staffordshire Railway',
            logo: '1825/NS',
            simple_logo: '1825/NS.alt',
            capitalization: :incremental,
            float_percent: 40,
            shares: [40, 20, 20, 20],
            price_percent: 10,
            max_ownership_percent: 100,
            tokens: [0],
            coordinates: 'Q13',
            color: '#404040',
            text_color: '#ffffff',
          },
        ].freeze

        K7_CORPORATIONS = [
          {
            sym: 'LT&S',
            name: 'London, Tilbury & Southend Railway',
            logo: '1825/LTS',
            simple_logo: '1825/LTS.alt',
            capitalization: :incremental,
            float_percent: 40,
            shares: [40, 20, 20, 20],
            price_percent: 10,
            max_ownership_percent: 100,
            tokens: [0],
            coordinates: 'V22',
            color: '#1b967a',
            text_color: '#ffffff',
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
          'L&Y' => 71,
          'SECR' => 71,
          'GSWR' => 67,
          'LBSC' => 67,
        }.freeze

        def game_par_values
          par_values = PAR_BY_CORPORATION.dup
          par_values['SECR'] = 67 if @optional_rules.include?(:db2)
          par_values
        end

        REQUIRED_TRAIN = {
          'GNoS' => '5',
          'HR' => 'U3',
          'M&C' => '3T',
          'Cam' => 'U3',
          'FR' => '5',
          'LT&S' => '2+2',
          'M&GN' => '4T',
          'NS' => '3T',
          'S&DR' => '5',
          'TV' => '4T',
        }.freeze

        def add_entities(corps, clist)
          clist.each do |chash|
            corps << chash.dup
          end
        end

        # combining is based on http://fwtwr.com/fwtwr/18xx/1825/privates.asp
        def game_companies
          comps = []
          add_entities(comps, UNIT1_COMPANIES) if @units[1]
          add_entities(comps, UNIT3_COMPANIES.reject { |c| comps.any? { |comp| comp[:value] == c[:value] } }) if @units[3]
          add_entities(comps, UNIT2_COMPANIES.reject { |c| comps.any? { |comp| comp[:value] == c[:value] } }) if @units[2]
          comps
        end

        def game_corporations
          corps = []
          add_entities(corps, UNIT1_CORPORATIONS) if @units[1]
          if !@units[1] && @units[2]
            add_entities(corps, UNIT2_CORPORATIONS)
          elsif @units[1] && @units[2]
            add_entities(corps, UNIT2_CORPORATIONS.reject { |corp| corp[:sym] == 'LNWR' })
            lnwr = corps.find { |corp| corp[:sym] == 'LNWR' }
            lnwr[:tokens] = [0, 0, 40, 100, 100, 100, 100]
            lnwr[:coordinates] = %w[T16 Q11]
            midland = corps.find { |corp| corp[:sym] == 'MR' }
            midland[:abilities] << { type: 'blocks_hexes', owner_type: nil, hexes: ['R14'] }
          end
          add_entities(corps, UNIT3_CORPORATIONS) if @units[3]
          add_entities(corps, R1_CORPORATIONS) if @regionals[1]
          # Modify GWR (Unit 1) if playing with R2
          if @regionals[2]
            add_entities(corps, R2_CORPORATIONS)
            gwr = corps.find { |corp| corp[:sym] == 'GWR' }
            gwr[:tokens] = [0, 0, 40, 100, 100, 100, 100]
            gwr[:coordinates] = %w[V14 Y7]
          end
          # Modify SECR / LBSC in variant DB2
          if @optional_rules.include?(:db2)
            secr = corps.find { |corp| corp[:sym] == 'SECR' }
            secr[:abilities] << { type: 'blocks_hexes', owner_type: nil, hexes: ['W21'] }
            lbsc = corps.find { |corp| corp[:sym] == 'LBSC' }
            lbsc[:abilities] = []
          end
          # Move HR with Unit 4
          if @optional_rules.include?(:unit_4)
            hr = corps.find { |corp| corp[:sym] == 'HR' }
            hr[:coordinates] = 'A5'
          end
          add_entities(corps, R3_CORPORATIONS) if @regionals[3]
          add_entities(corps, K5_CORPORATIONS) if @kits[5]
          add_entities(corps, K7_CORPORATIONS) if @kits[7]
          corps
        end
      end
    end
  end
end
