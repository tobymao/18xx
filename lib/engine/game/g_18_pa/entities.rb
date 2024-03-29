# frozen_string_literal: true

module Engine
  module Game
    module G18PA
      module Entities
        def company_header(_company)
          'MINOR RAILWAY'
        end

        COMPANIES = [
          {
            name: '1. Mohawk and Hudson Railroad',
            sym: 'P1',
            value: 110,
            revenue: 0,
            desc: 'Mohawk and Hudson Railroad. Minor pays owner 50% of run. Starting location is D17 (Albany). Merges into the '\
                  'New York Central System at the start of Phase 4.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: '2. Auburn Road',
            sym: 'P2',
            value: 110,
            revenue: 0,
            desc: 'Auburn Road. Minor pays owner 50% of its run. Starting location is B5 (Rochester). Merges into the '\
                  'New York Central System at the start of Phase 4.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: '3. Tonawanda Railroad',
            sym: 'P3',
            value: 110,
            revenue: 0,
            desc: 'Tonawanda Railroad. Minor pays owner 50% of its run. Starting location is C2 (Buffalo). Merges into the '\
                  'New York Central System at the start of Phase 4.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: '4. Reading Company',
            sym: 'P4',
            value: 110,
            revenue: 0,
            desc: 'Reading Company. Minor pays owner 50% of its run. Starting location is J13 (Philadelphia).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: '5. Long Island Railroad',
            sym: 'P5',
            value: 110,
            revenue: 0,
            desc: 'Long Island Railroad. Minor pays owner 50% of its run. Starting location is H19 (New York).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: '6. Old Colony Railroad',
            sym: 'P6',
            value: 110,
            revenue: 0,
            desc: 'Old Colony Railroad. Minor pays owner 50% of its run. Starting location is D27 (Boston).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: '7. Boston & Maine Railroad',
            sym: 'P7',
            value: 110,
            revenue: 0,
            desc: 'Boston & Maine Railroad. Minor pays owner 50% of its run. Starting location is D27 (Boston).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: '8. New York & Harlem Railroad',
            sym: 'P8',
            value: 110,
            revenue: 0,
            desc: 'New York & Harlem Railroad. Minor pays owner 50% of its run. Starting location is H19 (New York).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: '9. Hudson & Manhattan Railroad',
            sym: 'P9',
            value: 110,
            revenue: 0,
            desc: 'Hudson & Manhattan Railroad. Minor pays owner 50% of its run. Starting location is H17 (Newark).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
      ].freeze

        CORPORATIONS = [
          {
            name: 'Mohawk and Hudson Railroad',
            sym: '1',
            logo: '18_ny/1',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
            coordinates: 'D17',
            color: '#000000',
          },
          {
            name: 'Auburn Road',
            sym: '2',
            logo: '18_ny/2',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
            coordinates: 'B5',
            color: '#000000',
          },
          {
            name: 'Tonawanda Railroad',
            sym: '3',
            logo: '18_ny/3',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
            coordinates: 'C2',
            color: '#000000',
          },
          {
            name: 'Reading Company',
            sym: '4',
            logo: '18_ny/4',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
            coordinates: 'J13',
            city: 1,
            color: '#000000',
          },
          {
            name: 'Long Island Railroad',
            sym: '5',
            logo: '18_ny/5',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
            coordinates: 'H19',
            city: 2,
            color: '#000000',
          },
          {
            name: 'Old Colony Railroad',
            sym: '6',
            logo: '18_ny/6',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
            coordinates: 'D27',
            city: 2,
            color: '#000000',
          },
          {
            name: 'Boston & Maine Railroad',
            sym: '7',
            logo: '18_ny/7',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
            coordinates: 'D27',
            city: 1,
            color: '#000000',
          },
          {
            name: 'New York & Harlem Railroad',
            sym: '8',
            logo: '18_ny/8',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
            coordinates: 'H19',
            city: 1,
            color: '#000000',
          },
          {
            name: 'Hudson & Manhattan Railroad',
            sym: '9',
            logo: '18_ny/9',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
            coordinates: 'H17',
            city: 2,
            color: '#000000',
          },
          {
            float_percent: 50,
            sym: 'B&O',
            name: 'Baltimore & Ohio Railroad',
            logo: '18_chesapeake/BO',
            simple_logo: '1830/BO.alt',
            tokens: [0, 40],
            shares: [40, 20, 20, 20],
            type: 'five_share',
            coordinates: 'K10',
            abilities: [{ type: 'assign_hexes', hexes: ['K2'], count: 1 }],
            color: '#025aaa',
          },
          {
            float_percent: 20,
            name: 'Boston and Albany Railroad',
            sym: 'B&A',
            logo: '18_ny/ba',
            simple_logo: '18_ny/ba.alt',
            tokens: [0, 40],
            shares: [40, 20, 20, 20],
            type: 'five_share',
            coordinates: 'D27',
            abilities: [{ type: 'assign_hexes', hexes: ['D17'], count: 1 }],
            color: '#E21F27',
          },
          {
            float_percent: 50,
            sym: 'CNJ',
            name: 'Central Railroad of New Jersey',
            logo: '',
            simple_logo: '',
            tokens: [0, 40],
            shares: [40, 20, 20, 20],
            type: 'five_share',
            coordinates: 'H17',
            city: 0,
            color: :'#ADD8E6',
            text_color: 'black',
          },
          {
            float_percent: 50,
            sym: 'ERIE',
            name: 'Erie Railroad',
            logo: '1846/ERIE',
            simple_logo: '1830/ERIE.alt',
            tokens: [0, 40],
            shares: [40, 20, 20, 20],
            type: 'five_share',
            coordinates: 'H17',
            city: 1,
            abilities: [{ type: 'assign_hexes', hexes: ['C2'], count: 1 }],
            color: :'#FFF500',
            text_color: 'black',
          },
          {
            float_percent: 50,
            name: 'New York, New Haven, & Hartford Railroad',
            sym: 'NH',
            logo: '18_ny/nynh',
            simple_logo: '18_ny/nynh.alt',
            tokens: [0, 40],
            shares: [40, 20, 20, 20],
            type: 'five_share',
            coordinates: 'G22',
            color: '#E96B21',
          },
          {
            float_percent: 50,
            sym: 'PRR',
            name: 'Pennsylvania Railroad',
            logo: '18_chesapeake/PRR',
            simple_logo: '1830/PRR.alt',
            tokens: [0, 40],
            shares: [40, 20, 20, 20],
            type: 'five_share',
            coordinates: 'I8',
            abilities: [{ type: 'assign_hexes', hexes: ['I2'], count: 1 }],
            color: '#32763f',
          },
          {
            float_percent: 50,
            sym: 'NYC',
            name: 'New York Central System',
            logo: '1830/NYC',
            simple_logo: '1830/NYC.alt',
            tokens: [100, 100, 100],
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            color: :'#474548',
          },
        ].freeze
      end
    end
  end
end
