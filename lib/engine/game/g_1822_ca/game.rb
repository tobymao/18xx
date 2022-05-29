# frozen_string_literal: true

require_relative '../g_1822/game'
require_relative 'meta'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G1822CA
      class Game < G1822::Game
        include_meta(G1822CA::Meta)
        include G1822CA::Entities
        include G1822CA::Map

        BIDDING_BOX_START_MINOR = 'M6'
        BIDDING_BOX_START_CONCESSION = 'C2'
        BIDDING_BOX_START_PRIVATE = 'P1'

        COMPANY_SHORT_NAMES = {
          'P1' => 'P1 (5-Train)',
          'P2' => 'P2 (Perm. L Train)',
          'P3' => 'P3 (Permanent 2T)',
          'P4' => 'P4 (Permanent 2T)',
          'P5' => 'P5 (Pullman)',
          'P6' => 'P6 (Pullman)',
          'P7' => 'P7 (Double Cash)',
          'P8' => 'P8 ($10x Phase)',
          'P9' => 'P9 ($5x Phase)',
          'P10' => 'P10 (Winnipeg Token)',
          'P11' => 'P11 (Tax Haven)',
          'P12' => 'P12 (Adv. Tile Lay)',
          'P13' => 'P13 (Sawmill)',
          'P14' => 'P14 (Toronto Upgrade)',
          'P15' => 'P15 (Ottawa Upgrade)',
          'P16' => 'P16 (Montreal Upgrade)',
          'P17' => 'P17 (Quebec Upgrade)',
          'P18' => 'P18 (Winnipeg Upgrade)',
          'P19' => 'P19 (Crowsnest Pass)',
          'P20' => 'P20 (Yellowhead Pass)',
          'P21' => 'P21 (National Dream)',
          'P22' => 'P22 (National Mail Contract)',
          'P23' => 'P23 (National Mail Contract)',
          'P24' => 'P24 (Regional Mail Contract)',
          'P25' => 'P25 (Regional Mail Contract)',
          'P26' => 'P26 (Grain Train)',
          'P27' => 'P27 (Grain Train)',
          'P28' => 'P28 (Station Swap)',
          'P29' => 'P29 (Remove Town)',
          'P30' => 'P30 (Remove Town)',
          'C1' => 'CNoR',
          'C2' => 'CPR',
          'C3' => 'GNWR',
          'C4' => 'GT',
          'C5' => 'GTP',
          'C6' => 'GWR',
          'C7' => 'ICR',
          'C8' => 'NTR',
          'C9' => 'PGE',
          'C10' => 'QMOO',
          'M1' => '1',
          'M2' => '2',
          'M3' => '3',
          'M4' => '4',
          'M5' => '5',
          'M6' => '6',
          'M7' => '7',
          'M8' => '8',
          'M9' => '9',
          'M10' => '10',
          'M11' => '11',
          'M12' => '12',
          'M13' => '13',
          'M14' => '14',
          'M15' => '15',
          'M16' => '16',
          'M17' => '17',
          'M18' => '18',
          'M19' => '19',
          'M20' => '20',
          'M21' => '21',
          'M22' => '22',
          'M23' => '23',
          'M24' => '24',
          'M25' => '25',
          'M26' => '26',
          'M27' => '27',
          'M28' => '28',
          'M29' => '29',
          'M30' => '30',
        }.freeze

        CURRENCY_FORMAT_STR = '$%d'

        EXCHANGE_TOKENS = {
          'CNoR' => 3,
          'CPR' => 4,
          'GNWR' => 3,
          'GT' => 3,
          'GTP' => 3,
          'GWR' => 3,
          'ICR' => 3,
          'NTR' => 3,
          'PGE' => 3,
          'QMOO' => 3,
        }.freeze

        MARKET = [
          %w[5y 10y 15y 20y 25y 30y 35y 40y 45y 50p 60px 70px 80px 90px 100px 110 120 135 150 165 180 200 220
             245 270 300 330 360 400 450 500 550 600 650 700e],
        ].freeze

        MINOR_14_ID = '13'
        MINOR_14_HOME_HEX = 'AC21'

        PRIVATE_COMPANIES_ACQUISITION = {
          'P1' => { acquire: %i[major], phase: 5 },
          'P2' => { acquire: %i[major minor], phase: 1 },
          'P3' => { acquire: %i[major], phase: 2 },
          'P4' => { acquire: %i[major], phase: 2 },
          'P5' => { acquire: %i[major], phase: 5 },
          'P6' => { acquire: %i[major], phase: 5 },
          'P7' => { acquire: %i[major], phase: 3 },
          'P8' => { acquire: %i[major minor], phase: 2 },
          'P9' => { acquire: %i[major minor], phase: 2 },
          'P10' => { acquire: %i[major], phase: 3 },
          'P11' => { acquire: %i[none], phase: 0 },
          'P12' => { acquire: %i[major minor], phase: 1 },
          'P13' => { acquire: %i[major], phase: 3 },
          'P14' => { acquire: %i[major minor], phase: 1 },
          'P15' => { acquire: %i[major minor], phase: 1 },
          'P16' => { acquire: %i[major minor], phase: 1 },
          'P17' => { acquire: %i[major minor], phase: 1 },
          'P18' => { acquire: %i[major minor], phase: 1 },
          'P19' => { acquire: %i[major], phase: 3 },
          'P20' => { acquire: %i[major], phase: 3 },
          'P21' => { acquire: %i[major], phase: 3 },
          'P22' => { acquire: %i[major], phase: 3 },
          'P23' => { acquire: %i[major], phase: 3 },
          'P24' => { acquire: %i[major], phase: 3 },
          'P25' => { acquire: %i[major], phase: 3 },
          'P26' => { acquire: %i[major], phase: 3 },
          'P27' => { acquire: %i[major], phase: 3 },
          'P28' => { acquire: %i[major minor], phase: 3 },
          'P29' => { acquire: %i[major minor], phase: 1 },
          'P30' => { acquire: %i[major minor], phase: 1 },
        }.freeze

        STARTING_COMPANIES = %w[P1 P2 P3 P4 P5 P6 P7 P8 P9 P10 P11 P12 P13 P14 P15 P16 P17 P18 P19 P20 P21 P22 P23
                                P24 P25 P26 P27 P28 P29 P30 C1 C2 C3 C4 C5 C6 C7 C8 C9 C10
                                M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12 M13 M14 M15 M16 16 M17 M18 M19 M20 M21 M22
                                M23 M24 M25 M26 M27 M28 M29 M30].freeze

        STARTING_CORPORATIONS = %w[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
                                   CNoR CPR GNWR GT GTP GWR ICR NTR PGE QMOO].freeze

        def format_currency(val)
          return super if (val % 1).zero?

          format('$%.1<val>f', val: val)
        end

        def setup_destinations
          @corporations.each do |c|
            next unless c.destination_coordinates

            description = if c.id == 'CPR'
                            "Gets destination token at #{c.destination_coordinates} when floated"
                          else
                            "Connect to #{c.destination_coordinates} for your destination token"
                          end
            ability = Ability::Base.new(
              type: 'destination',
              description: description
            )
            c.add_ability(ability)
            c.tokens << Engine::Token.new(c, logo: "../#{c.destination_icon}.svg",
                                             simple_logo: "../#{c.destination_icon}.svg",
                                             type: :destination)
          end
        end
      end
    end
  end
end
