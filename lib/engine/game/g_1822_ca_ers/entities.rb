# frozen_string_literal: true

module Engine
  module Game
    module G1822CaErs
      module Entities
        STARTING_COMPANIES = %w[P1 P2 P3 P4 P5 P6 P7 P8 P9 P11 P12 P13 P14 P15
                                P16 P17 P22 P23 P24 P25 P28 P29 P30
                                C2 C4 C6 C7 C8 C10
                                M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12 M13 M14
                                M15 M16 M17 M18 M19].freeze

        STARTING_COMPANIES_TWOPLAYER = %w[P1 P2 P3 P9 P12 P13 P14 P15 P16 P17 P23 P24 P28 P29 P30
                                          C2 C4 C6 C7 C8 C10
                                          M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12 M13 M14
                                          M15 M16 M17 M18 M19].freeze

        STARTING_CORPORATIONS = %w[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19
                                   CPR GT GWR ICR NTR QMOO].freeze

        STARTING_COMPANIES_OVERRIDE = {
          'C2' => {
            desc: 'Has a face value of $100 and contributes $100 to conversion into the CPR director’s '\
                  'certificate. Home: Montréal (AF12). Destination: Vancouver (T12).',
          },
          'C8' => {
            desc: 'Has a face value of $100 and contributes $100 to conversion into the NTR director’s '\
                  'certificate. Home: Moncton (AO3). Destination: Winnipeg (T14).',
          },
        }.freeze

        STARTING_CORPORATIONS_OVERRIDE = {
          'CPR' => { destination_coordinates: 'T12', destination_icon_in_city_slot: [0, 0] },
          'NTR' => { destination_coordinates: 'T14', destination_icon_in_city_slot: [0, 2] },
        }.freeze
      end
    end
  end
end
