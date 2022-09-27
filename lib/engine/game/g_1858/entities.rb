# frozen_string_literal: true

module Engine
  module Game
    module G1858
      module Entities
        CORPORATIONS = [
          {
            sym: 'A',
            name: 'Andalucian Railway',
            color: '#3751dc',
            text_color: 'white',
            logo: '1858/A',
            simple_logo: '1858/A.alt',
            float_percent: 40,
            type: 'medium',
            shares: [40, 20, 20, 20],
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 20, 20],
          },
          {
            sym: 'AVT',
            name: 'Almanza, Valencia and Tarragona Railway',
            color: '#18a6d8',
            text_color: 'white',
            logo: '1858/AVT',
            simple_logo: '1858/AVT.alt',
            float_percent: 40,
            type: 'medium',
            shares: [40, 20, 20, 20],
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 20, 20],
          },
          {
            sym: 'MZA',
            name: 'Madrid, Zaragoza and Alicante Railway',
            logo: '1858/MZA',
            simple_logo: '1858/MZA.alt',
            color: '#fff114',
            text_color: 'black',
            float_percent: 40,
            type: 'medium',
            shares: [40, 20, 20, 20],
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 20, 20],
            city: 2,
          },
          {
            sym: 'N',
            name: 'Northern Railway',
            logo: '1858/N',
            simple_logo: '1858/N.alt',
            color: '#000000',
            text_color: 'white',
            float_percent: 40,
            type: 'medium',
            shares: [40, 20, 20, 20],
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 20, 20],
          },
          {
            sym: 'RP',
            name: 'Royal Portugese Railway',
            logo: '1858/RP',
            simple_logo: '1858/RP.alt',
            color: '#e51f2e',
            text_color: 'white',
            float_percent: 40,
            type: 'medium',
            shares: [40, 20, 20, 20],
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 20, 20],
          },
          {
            sym: 'TBF',
            name: 'Tarragona, Barcelona and France Railway',
            logo: '1858/TBF',
            simple_logo: '1858/TBF.alt',
            color: '#59227f',
            text_color: 'white',
            float_percent: 40,
            type: 'medium',
            shares: [40, 20, 20, 20],
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 20, 20],
          },
          {
            sym: 'W',
            name: 'Western Railway',
            logo: '1858/W',
            simple_logo: '1858/W.alt',
            color: '#109538',
            text_color: 'white',
            float_percent: 40,
            type: 'medium',
            shares: [40, 20, 20, 20],
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 20, 20],
          },
          {
            sym: 'ZPB',
            name: 'Zaragoza, Pamplona and Barcelona Railway',
            logo: '1858/ZPB',
            simple_logo: '1858/ZPB.alt',
            color: '#ff7700',
            text_color: 'white',
            float_percent: 40,
            type: 'medium',
            shares: [40, 20, 20, 20],
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 20, 20],
          },
        ].freeze

        COMPANIES = [
          {
            sym: 'H&G',
            name: 'Havana and Güines Railway',
            value: 30,
            discount: 0,
            revenue: 10,
            color: :yellow,
            abilities: [
              { type: 'no_buy' },
            ],
          },
          {
            sym: 'B&M',
            name: 'Barcelona and Mataró Railway',
            value: 115,
            discount: 25,
            revenue: 23,
            color: :yellow,
            abilities: [
              { type: 'no_buy' },
              { type: 'revenue_change', revenue: 35, on_phase: '3' },
            ],
          },
          {
            sym: 'M&A',
            name: 'Madrid and Aranjuez Railway',
            value: 125,
            discount: 25,
            revenue: 25,
            color: :yellow,
            abilities: [
              { type: 'no_buy' },
              { type: 'revenue_change', revenue: 38, on_phase: '3' },
            ],
          },
          {
            sym: 'P&L',
            name: 'Porto and Lisbon Railway',
            value: 110,
            discount: 20,
            revenue: 22,
            color: :yellow,
            abilities: [
              { type: 'no_buy' },
              { type: 'revenue_change', revenue: 33, on_phase: '3' },
            ],
          },
          {
            sym: 'V&J',
            name: 'Valencia and Jativa Railway',
            value: 100,
            discount: 20,
            revenue: 20,
            color: :yellow,
            abilities: [
              { type: 'no_buy' },
              { type: 'revenue_change', revenue: 30, on_phase: '3' },
            ],
          },
          {
            sym: 'R&T',
            name: 'Reus and Tarragona Railway',
            value: 60,
            discount: 10,
            revenue: 12,
            color: :yellow,
            abilities: [
              { type: 'no_buy' },
              { type: 'revenue_change', revenue: 18, on_phase: '3' },
            ],
          },
          {
            sym: 'L&C',
            name: 'Lisbon and Carregado Railway',
            value: 90,
            discount: 20,
            revenue: 18,
            color: :yellow,
            abilities: [
              { type: 'no_buy' },
              { type: 'revenue_change', revenue: 27, on_phase: '3' },
            ],
          },
          {
            sym: 'M&V',
            name: 'Madrid and Vallodolid Railway',
            value: 120,
            discount: 25,
            revenue: 24,
            color: :yellow,
            abilities: [
              { type: 'no_buy' },
              { type: 'revenue_change', revenue: 36, on_phase: '3' },
            ],
          },
          {
            sym: 'M&Z',
            name: 'Madrid and Zaragoza Railway',
            value: 95,
            discount: 20,
            revenue: 19,
            color: :yellow,
            abilities: [
              { type: 'no_buy' },
              { type: 'revenue_change', revenue: 29, on_phase: '3' },
            ],
          },
          {
            sym: 'C&S',
            name: 'Cordoba and Seville Railway',
            value: 105,
            discount: 20,
            revenue: 21,
            color: :yellow,
            abilities: [
              { type: 'no_buy' },
              { type: 'revenue_change', revenue: 32, on_phase: '3' },
            ],
          },
          {
            sym: 'SJ&C',
            name: 'Seville, Jerez and Cadiz Railway',
            value: 70,
            discount: 15,
            revenue: 14,
            color: :yellow,
            abilities: [
              { type: 'no_buy' },
              { type: 'revenue_change', revenue: 21, on_phase: '3' },
            ],
          },
          {
            sym: 'Z&P',
            name: 'Zaragoza and Pamplona Railway',
            value: 80,
            discount: 15,
            revenue: 16,
            color: :yellow,
            abilities: [
              { type: 'no_buy' },
              { type: 'revenue_change', revenue: 24, on_phase: '3' },
            ],
          },
          {
            sym: 'C&B',
            name: 'Castejón and Bilbao Railway',
            value: 75,
            discount: 15,
            revenue: 15,
            color: :yellow,
            abilities: [
              { type: 'no_buy' },
              { type: 'revenue_change', revenue: 23, on_phase: '3' },
            ],
          },
          {
            sym: 'C&M',
            name: 'Córdoba and Málaga Railway',
            value: 85,
            discount: 15,
            revenue: 17,
            color: :yellow,
            abilities: [
              { type: 'no_buy' },
              { type: 'revenue_change', revenue: 26, on_phase: '3' },
            ],
          },
          {
            sym: 'M&C',
            name: 'Murcia and Cartagena Railway',
            value: 70,
            discount: 15,
            revenue: 14,
            color: :yellow,
            abilities: [
              { type: 'no_buy' },
              { type: 'revenue_change', revenue: 21, on_phase: '3' },
            ],
          },
          {
            sym: 'A&S',
            name: 'Alar and Santander Railway',
            value: 80,
            discount: 15,
            revenue: 16,
            color: :yellow,
            abilities: [
              { type: 'no_buy' },
              { type: 'revenue_change', revenue: 24, on_phase: '3' },
            ],
          },
          {
            sym: 'B&C',
            name: 'Badajoz and Ciudad Real Railway',
            value: 65,
            discount: 15,
            revenue: 13,
            color: :yellow,
            abilities: [
              { type: 'no_buy' },
              { type: 'revenue_change', revenue: 20, on_phase: '3' },
            ],
          },
          {
            sym: 'S&C',
            name: 'Santiago and La Coruña Railway',
            value: 100,
            discount: 0,
            revenue: 30,
            color: :green,
            abilities: [
              { type: 'no_buy' },
            ],
          },
          {
            sym: 'M&S',
            name: 'Medina and Salamanca Railway',
            value: 90,
            discount: 0,
            revenue: 27,
            color: :green,
            abilities: [
              { type: 'no_buy' },
            ],
          },
          {
            sym: 'C&MP',
            name: 'Cáceres, Madrid and Portugal Railway',
            value: 135,
            discount: -30,
            revenue: 40,
            color: :green,
            abilities: [
              { type: 'no_buy' },
            ],
          },
          {
            sym: 'O&V',
            name: 'Orense and Vigo Railway',
            value: 110,
            discount: 0,
            revenue: 33,
            color: :green,
            abilities: [
              { type: 'no_buy' },
            ],
          },
          {
            sym: 'L&G',
            name: 'León and Gijón Railway',
            value: 120,
            discount: 0,
            revenue: 36,
            color: :green,
            abilities: [
              { type: 'no_buy' },
            ],
          },
        ].freeze

        QUICK_START_PACKETS_A = {
          3 => [
            { companies: ['M&A', 'V&J', 'M&C', 'B&M', 'R&T', 'H&G'], cost: 500 },
            { companies: ['M&V', 'A&S', 'C&B', 'P&L', 'L&C'], cost: 475 },
            { companies: ['C&S', 'C&M', 'SJ&C', 'B&C', 'M&Z', 'Z&P'], cost: 500 },
          ],
          4 => [
            { companies: ['M&A', 'V&J', 'M&C', 'B&C'], cost: 360 },
            { companies: ['B&M', 'R&T', 'M&Z', 'Z&P'], cost: 350 },
            { companies: ['M&V', 'A&S', 'C&B', 'L&C'], cost: 365 },
            { companies: ['C&S', 'C&M', 'SJ&C', 'P&L'], cost: 370 },
          ],
          5 => [
            { companies: ['M&A', 'V&J', 'M&C'], cost: 295 },
            { companies: ['B&M', 'R&T', 'M&Z'], cost: 270 },
            { companies: ['M&V', 'A&S', 'C&B'], cost: 275 },
            { companies: ['C&S', 'C&M', 'SJ&C'], cost: 260 },
            { companies: ['P&L', 'L&C', 'B&C', 'H&G'], cost: 295 },
          ],
          6 => [
            { companies: ['M&A', 'M&Z'], cost: 220 },
            { companies: ['B&M', 'R&T', 'C&B'], cost: 250 },
            { companies: ['M&V', 'A&S'], cost: 200 },
            { companies: ['C&S', 'B&C', 'SJ&C'], cost: 240 },
            { companies: ['P&L', 'L&C', 'H&G'], cost: 230 },
            { companies: ['V&J', 'M&C', 'Z&P'], cost: 250 },
          ],
        }.freeze

        QUICK_START_PACKETS_B = QUICK_START_PACKETS_A.merge({
          4 => [
            { companies: ['M&A', 'V&J', 'M&C', 'B&C'], cost: 360 },
            { companies: ['B&M', 'R&T', 'P&L', 'L&C'], cost: 375 },
            { companies: ['M&V', 'A&S', 'C&B', 'Z&P'], cost: 355 },
            { companies: ['C&S', 'C&M', 'SJ&C', 'M&Z'], cost: 355 },
          ],
        }.freeze)

        def quick_start
          packets = option_quick_start_packets[@players.size].sort_by { rand }
          @players.zip(packets).each do |player, packet|
            cost = packet[:cost]
            player.spend(cost, @bank)
            companies = packet[:companies]
            companies.each do |sym|
              company = @companies.find { |c| c.sym == sym }
              purchase_company(player, company, 0)
            end
            @log << "#{player.name} spends #{format_currency(cost)} and " \
                    "buys private companies #{companies.join(', ')}"
          end
        end
      end
    end
  end
end
