# frozen_string_literal: true

module Engine
  module Game
    module G18ESP
      module Entities
        MINE_HEXES = %w[C5 C9 E9 E11 E19 G9 H6 I7 C23 G17 G21 D18 D32 E31 H30 I23 D8 E7 B30 F30 I21].freeze
        COMPANIES = [
          {
            sym: 'P1',
            name: 'La Habana - Güines',
            value: 20,
            revenue: 5,
            min_price: 1,
            desc: 'It gives a discount of pts30 for laying a yellow
            mine tile or for shutting down a mine for
            updating that hex to green. When this privilege is done, the
            company closes.',
            abilities: [
              {
                type: 'tile_lay',
                hexes: MINE_HEXES,
                tiles: [],
                free: false,
                when: 'track',
                discount: 30,
                reachable: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                special: false,
                count: 1,
              },
            ],
            color: nil,
          },
          {
            sym: 'P2',
            name: 'Barcelona - Mataró',
            value: 60,
            revenue: 10,
            min_price: 1,
            desc: 'Owning Corporation receives 2/1+2 train. closes when bought by a corporation.',
            color: nil,
          },
          {
            sym: 'P3',
            name: 'Madrid - Aranjuez o El tren de la fresa',
            value: 70,
            revenue: 15,
            min_price: 1,
            desc: 'If owned by a corporation at phase 5 then it is converted to a permanent 2 train. '\
                  'The train does not count towards train limit.  It does not fulfill train ownership requierments'\
                  '. The first run must go through Aranjuez, later runs can be anywhere on the map.',

            color: nil,
          },
          {
            sym: 'P4',
            name: 'La Maquinista',
            value: 130,
            revenue: 10,
            min_price: 1,
            desc: "Provides five tender cards. The owner of this company (only player) can \
            sell up to four of these five tenders (to any company). Each tender costs pts80 \
            (20 goes to the owner and 60 to the bank). The fifth tender remains with the company\
             until it is bought by a major or minor company. Then the fifth tender belongs to the\
              company that bought this private. The director of the company that buys this private\
              or that buys a tender to their owner, can assign its tender to a train of his choice\
              in each OR. The same train can carry the tender in two or more consecutive ORs. \
              A train with a tender can adds a town, harbor or mine to its route, regardless of \
              the range of the train. The tender is permanent. No company may purchase more than one tender.\
              If, due to an acquisition or because purchasing the private, a company has more than one tender,\
              it keeps one for itself and must put the other ones up for sale at pts80 in the open market. \
              Money for these sells goes to the bank.Companies that buy a tender to this private can do it\
              in any moment during its turn in an OR, and can also use it in the same OR.\
            It is not able to trade with the tender cars in other way that has been described.
            This company closes when is acquired by a minor or major company.",
            abilities: [
                      {
                        type: 'base',
                        owner_type: 'corporation',
                        description: 'Tender',
                        desc_detail: 'Allows to attach Tender to regular trains '\
                                     'extending their distance by one town, harbor or mine.',
                        when: 'owning_corp_or_turn',
                      },
                    ],
            color: nil,
          },
          {
            sym: 'P5',
            name: 'Alar del Rey - Santander',
            value: 100,
            revenue: 20,
            min_price: 1,
            desc: 'The major owning company (both North and '\
                  'South) can build the mountain pass of Alar del '\
                  'Rey for free, or any other mountain pass with '\
                  'a discount of pts40. This action closes this company.',
            abilities: [{
              type: 'choose_ability',
              owner_type: 'corporation',
              when: 'track',
              choices: { close: 'Close P5' },
            }],

          },
          {
            sym: 'P6',
            name: 'Zafra - Huelva',
            value: 160,
            revenue: 20,
            desc: 'It provides a 10% certificate from the Southern company CRB.',
            color: nil,
            abilities: [{ type: 'shares', shares: 'CRB_1' }],
          },
          {
            sym: 'P6',
            name: 'Ferrocarril Vasco-Navarro',
            value: 160,
            revenue: 20,
            desc: 'It provides a 10% certificate from the Southern company CRB.',
            color: nil,
            abilities: [{ type: 'shares', shares: 'random_share' }],
          },
          {
            sym: 'P7',
            name: 'Ferrocarril de Carreño',
            value: 190,
            revenue: 30,
            desc: 'President share of one Northern major company (randomly selected before the game starts).'\
                  'It closes when the major company buys its first train.',
            color: nil,
            abilities: [{ type: 'shares', shares: 'random_president' }, { type: 'no_buy' }],
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 40,
            sym: 'N',
            name: 'Compañía de los Caminos de Hierro del Norte de España',
            logo: '18_esp/N',
            coordinates: 'F24',
            city: 1,
            max_ownership_percent: 60,
            tokens: [0, 50, 50, 50, 50, 50],
            color: '#C29137',
            type: 'major',
            destination: 'E21',
          },
          {
            float_percent: 40,
            sym: 'MZA',
            name: 'Compañía de los ferrocarriles de Madrid a Zaragoza y Alicante ',
            logo: '18_esp/MZA',
            coordinates: 'F24',
            city: 2,
            max_ownership_percent: 60,
            tokens: [0, 50, 50, 50, 50, 50],
            color: '#FFD526',
            type: 'major',
            destination: 'J28',
          },
          {
            float_percent: 40,
            sym: 'A',
            name: 'Compañía de los Ferrocarriles Andaluces',
            logo: '18_esp/A',
            coordinates: 'E33',
            max_ownership_percent: 60,
            tokens: [0, 50, 50, 50, 50, 50],
            color: '#B75835',
            type: 'major',
            destination: 'C31',
          },
          {
            float_percent: 40,
            sym: 'CRB',
            name: 'Compañía de los Caminos de Hierro de Ciudad Real a Badajoz',
            logo: '18_esp/CRB',
            coordinates: 'B26',
            max_ownership_percent: 60,
            tokens: [0, 50, 50, 50, 50, 50],
            color: '#E96B28',
            type: 'major',
            destination: 'F28',
          },
          {
            float_percent: 40,
            sym: 'MCP',
            name: 'Compañía de los ferrocarriles de Madrid a Cáceres y Portugal',
            logo: '18_esp/MCP',
            coordinates: 'F24',
            city: 0,
            max_ownership_percent: 60,
            tokens: [0, 50, 50, 50, 50, 50],
            color: '#009AD5',
            type: 'major',
            destination: 'C25',
          },

          {
            float_percent: 40,
            sym: 'ZPB',
            name: 'Compañía de los Ferrocarriles de Zaragoza a Pamplona y
            Barcelona',
            logo: '18_esp/ZPB',
            coordinates: 'M21',
            city: 1,
            max_ownership_percent: 60,
            tokens: [0, 50, 50, 50, 50, 50],
            color: '#DA0A26',
            type: 'major',
            destination: 'J20',
          },

          {
            float_percent: 40,
            sym: 'FdSB',
            name: 'Ferrocarril de Santander a Bilbao',
            logo: '18_esp/FdSB',
            coordinates: 'I5',
            max_ownership_percent: 60,
            tokens: [0, 50, 50, 50, 50],
            color: '#009AD5',
            type: 'major',
            destination: 'K5',
          },

          {
            float_percent: 40,
            sym: 'CFEA',
            name: 'Compañía de los Ferrocarriles Económicos de Asturias',
            logo: '18_esp/CFEA',
            coordinates: 'D6',
            max_ownership_percent: 60,
            tokens: [0, 50, 50, 50, 50],
            color: '#E96B28',
            type: 'major',
            destination: 'G5',
          },

          {
            float_percent: 40,
            sym: 'CFLG',
            name: 'Compañía del Ferrocarril de Langreo en Asturias',
            logo: '18_esp/CFLG',
            coordinates: 'E3',
            max_ownership_percent: 60,
            tokens: [0, 50, 50, 50, 50],
            color: '#DA0A26',
            type: 'major',
            destination: 'E7',
          },

          {
            float_percent: 40,
            sym: 'FdLR',
            name: 'Ferrocarril de La Robla',
            logo: '18_esp/FdLR',
            coordinates: 'H8',
            max_ownership_percent: 60,
            tokens: [0, 50, 50, 50, 50],
            color: '#009141',
            type: 'major',
            destination: 'K5',
          },

          {
            sym: 'MS',
            name: 'Ferrocarril de Mérida a Sevilla',
            logo: '18_esp/MS',
            coordinates: 'C27',
            color: '#7DCCE5',
            tokens: [0],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
            startable: true,
          },
          {
            sym: 'CM',
            name: 'Compañía del Ferrocarril de Córdoba a Málaga',
            logo: '18_esp/CM',
            coordinates: 'E29',
            color: '#009141',
            tokens: [0],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
            startable: true,
          },
          {
            sym: 'SC',
            name: 'Compañía del Ferrocarril de Sevilla a Jerez y de Puerto Real a Cádiz',
            logo: '18_esp/SC',
            simple_logo: '18_esp/SC',
            coordinates: 'C31',
            color: '#FFF014',
            tokens: [0],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
            startable: true,
          },
          {
            sym: 'AC',
            name: 'Ferrocarril de Albacete a Cartagena',
            logo: '18_esp/AC',
            coordinates: 'H28',
            color: '#B75835',
            tokens: [0],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
            startable: true,
          },
          {
            sym: 'MZ',
            name: 'Ferrocarril de Madrid a Zaragoza',
            logo: '18_esp/MZ',
            coordinates: 'F24',
            city: 2,
            color: '#7E7F7E',
            tokens: [0],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
            startable: true,
            abilities: [{ type: 'token', hexes: ['F24'], cheater: true, when: 'track', price: 0 }],
          },
          {
            sym: 'ZP',
            name: 'Compañía del Ferrocarril de Zaragoza a Pamplona',
            logo: '18_esp/ZP',
            coordinates: 'J20',
            color: '#D90072',
            tokens: [0],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
            startable: true,
          },
        ].freeze

        EXTRA_CORPORATIONS = [
        {
          float_percent: 40,
          sym: 'SFVA',
          name: 'Sociedad General de Ferrocarriles Vasco Asturiana',
          logo: '18_esp/SFVA',
          coordinates: 'D6',
          color: '#AD539B',
          max_ownership_percent: 60,
          tokens: [0, 50, 50, 50, 50],
          type: 'major',
          destination: 'C1',
        },
        {
          float_percent: 40,
          sym: 'FdC',
          name: 'Ferrocarril del Cantábrico',
          logo: '18_esp/FdC',
          coordinates: 'I5',
          color: '#F78243',
          max_ownership_percent: 60,
          tokens: [0, 50, 50, 50, 50],
          type: 'major',
          destination: 'G5',
        },
        {
          float_percent: 40,
          sym: 'GSSR',
          name: 'Great Southern of Spain Railway Company Limited',
          logo: '18_esp/GSSR',
          coordinates: 'I29',
          city: 0,
          max_ownership_percent: 60,
          tokens: [0, 50, 50, 50, 50, 50],
          color: '#6D1D7D',
          type: 'major',
          destination: 'F32',
        },
        {
          float_percent: 40,
          sym: 'AVT',
          name: 'Sociedad de los Ferrocarriles de Almansa a Valencia y Tarragona',
          logo: '18_esp/AVT',
          coordinates: 'K25',
          city: 0,
          max_ownership_percent: 60,
          tokens: [0, 50, 50, 50, 50, 50],
          color: '#000000',
          type: 'major',
          destination: 'L22',
        },
        {
          float_percent: 40,
          sym: 'TBF',
          name: 'Compañía de los Ferrocarriles de Tarragona a Barcelona y Francia',
          logo: '18_esp/TBF',
          coordinates: 'L22',
          city: 0,
          max_ownership_percent: 60,
          tokens: [0, 50, 50, 50, 50, 50],
          color: '#338242',
          type: 'major',
          destination: 'N18',
        },
        {
          sym: 'CSE',
          name: 'Compañía de los Caminos de Hierro del Sur de España',
          logo: '18_esp/CSE',
          coordinates: 'H32',
          color: '#F5B776',
          tokens: [0],
          type: 'minor',
          shares: [100],
          float_percent: 100,
          max_ownership_percent: 100,
          startable: true,
        },

        {
          sym: 'MH',
          name: 'Ferrocarril de Madrid a Hendaya',
          logo: '18_esp/MH',
          coordinates: 'E21',
          color: '#F9D4FA',
          tokens: [0],
          type: 'minor',
          shares: [100],
          float_percent: 100,
          max_ownership_percent: 100,
          startable: true,
        },

        {
          sym: 'CA',
          name: 'Compañía del Ferrocarril Central de Aragón',
          logo: '18_esp/CA',
          coordinates: 'J20',
          color: '#EAF7B0',
          tokens: [0],
          type: 'minor',
          shares: [100],
          float_percent: 100,
          max_ownership_percent: 100,
          startable: true,
        },

      ].freeze
      end
    end
  end
end
