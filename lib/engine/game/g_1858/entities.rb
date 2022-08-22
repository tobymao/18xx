# frozen_string_literal: true

module Engine
  module Game
    module G1858
      module Entities
        CORPORATIONS = [
          {
            sym: 'A',
            name: 'Andalucian Railway',
            logo: '18_eu/BNR',
            color: '#3751dc',
            text_color: 'white',
            simple_logo: '18_eu/BNR.alt',
            float_percent: 20,
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 0, 0],
          },
          {
            sym: 'AVT',
            name: 'Almanza, Valencia and Tarragona Railway',
            color: '#18a6d8',
            text_color: 'white',
            logo: '18_eu/DR',
            simple_logo: '18_eu/DR.alt',
            float_percent: 20,
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 0, 0],
          },
          {
            sym: 'MZA',
            name: 'Madrid, Zaragoza and Alicante Railway',
            logo: '18_eu/FS',
            simple_logo: '18_eu/FS.alt',
            color: '#fff114',
            text_color: 'black',
            float_percent: 20,
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 0, 0],
          },
          {
            sym: 'N',
            name: 'Northern Railway',
            logo: '18_eu/RBSR',
            simple_logo: '18_eu/RBSR.alt',
            color: '#000000',
            text_color: 'white',
            float_percent: 20,
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 0, 0],
          },
          {
            sym: 'RP',
            name: 'Royal Portugese Railway',
            logo: '18_eu/RPR',
            simple_logo: '18_eu/RPR.alt',
            color: '#e51f2e',
            text_color: 'white',
            float_percent: 20,
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 0, 0],
          },
          {
            sym: 'TBF',
            name: 'Tarragona, Barcelona and France Railway',
            logo: '18_eu/AIRS',
            simple_logo: '18_eu/AIRS.alt',
            color: '#59227f',
            text_color: 'white',
            float_percent: 20,
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 0, 0],
          },
          {
            sym: 'W',
            name: 'Western Railway',
            logo: '18_eu/SNCF',
            simple_logo: '18_eu/SNCF.alt',
            color: '#109538',
            text_color: 'white',
            float_percent: 20,
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 0, 0],
          },
          {
            sym: 'ZPB',
            name: 'Zaragoza, Pamplona and Barcelona Railway',
            logo: '18_eu/GSR',
            simple_logo: '18_eu/GSR.alt',
            color: '#ff7700',
            text_color: 'white',
            float_percent: 20,
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 0, 0],
          },
        ].freeze

        COMPANIES = [
          {
            sym: 'H&S',
            name: 'Havana and Güines Railway',
            min_price: 30,
            value: 30,
            revenue: 10,
            color: :yellow,
          },
          {
            sym: 'B&M',
            name: 'Barcelona and Mataró Railway',
            min_price: 90,
            value: 115,
            revenue: 23,
            color: :yellow,
          },
          {
            sym: 'M&A',
            name: 'Madrid and Aranjuez Railway',
            min_price: 100,
            value: 125,
            revenue: 25,
            color: :yellow,
          },
          {
            sym: 'P&L',
            name: 'Porto and Lisbon Railway',
            min_price: 90,
            value: 110,
            revenue: 22,
            color: :yellow,
          },
          {
            sym: 'V&J',
            name: 'Valencia and Jativa Railway',
            min_price: 80,
            value: 100,
            revenue: 20,
            color: :yellow,
          },
          {
            sym: 'R&T',
            name: 'Reus and Tarragona Railway',
            min_price: 50,
            value: 60,
            revenue: 12,
            color: :yellow,
          },
          {
            sym: 'L&C',
            name: 'Lisbon and Carregado Railway',
            min_price: 70,
            value: 90,
            revenue: 18,
            color: :yellow,
          },
          {
            sym: 'M&V',
            name: 'Madrid and Vallodolid Railway',
            min_price: 95,
            value: 120,
            revenue: 24,
            color: :yellow,
          },
          {
            sym: 'M&Z',
            name: 'Madrid and Zaragoza Railway',
            min_price: 75,
            value: 95,
            revenue: 19,
            color: :yellow,
          },
          {
            sym: 'C&S',
            name: 'Cordoba and Seville Railway',
            min_price: 85,
            value: 105,
            revenue: 21,
            color: :yellow,
          },
          {
            sym: 'SJ&C',
            name: 'Seville, Jerez and Cadiz Railway',
            min_price: 55,
            value: 70,
            revenue: 14,
            color: :yellow,
          },
          {
            sym: 'Z&P',
            name: 'Zaragoza and Pamplona Railway',
            min_price: 65,
            value: 80,
            revenue: 16,
            color: :yellow,
          },
          {
            sym: 'C&B',
            name: 'Castejón and Bilbao Railway',
            min_price: 60,
            value: 75,
            revenue: 15,
            color: :yellow,
          },
          {
            sym: 'C&M',
            name: 'Córdoba and Málaga Railway',
            min_price: 70,
            value: 85,
            revenue: 17,
            color: :yellow,
          },
          {
            sym: 'M&C',
            name: 'Murcia and Cartagena Railway',
            min_price: 55,
            value: 70,
            revenue: 14,
            color: :yellow,
          },
          {
            sym: 'A&S',
            name: 'Alar and Santander Railway',
            min_price: 65,
            value: 80,
            revenue: 16,
            color: :yellow,
          },
          {
            sym: 'B&C',
            name: 'Badajoz and Ciudad Real Railway',
            min_price: 50,
            value: 65,
            revenue: 13,
            color: :yellow,
          },
          {
            sym: 'S&C',
            name: 'Santiago and La Coruña Railway',
            min_price: 100,
            value: 100,
            revenue: 30,
            color: :green,
          },
          {
            sym: 'M&S',
            name: 'Medina and Salamanca Railway',
            min_price: 90,
            value: 90,
            revenue: 27,
            color: :green,
          },
          {
            sym: 'C&MP',
            name: 'Cáceres, Madrid and Portugal Railway',
            min_price: 165,
            value: 135,
            revenue: 40,
            color: :green,
          },
          {
            sym: 'O&V',
            name: 'Orense and Vigo Railway',
            min_price: 110,
            value: 110,
            revenue: 33,
            color: :green,
          },
          {
            sym: 'L&G',
            name: 'León and Gijón Railway',
            min_price: 120,
            value: 120,
            revenue: 36,
            color: :green,
          },
        ].freeze
      end
    end
  end
end
