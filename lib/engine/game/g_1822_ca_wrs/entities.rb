# frozen_string_literal: true

module Engine
  module Game
    module G1822CaWrs
      module Entities
        STARTING_COMPANIES = %w[P1 P2 P3 P4 P5 P6 P7 P8 P11 P18 P19 P20 P22 P24 P26 P27 P28 P29
                                C1 C2 C3 C5 C8 C9
                                M16 M17 M18 M19 M20 M21 M22 M23 M24 M25 M26 M27 M28 M29 M30].freeze

        STARTING_COMPANIES_TWOPLAYER = %w[P1 P2 P3 P5 P7 P9 P11 P12 P18 P19 P20 P26 P27 P28 P29
                                          C1 C2 C3 C5 C8 C9
                                          M16 M17 M18 M19 M20 M21 M22 M23 M24 M25 M26 M27 M28 M29 M30].freeze

        STARTING_CORPORATIONS = %w[16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
                                   CNoR CPR GNWR GTP NTR PGE].freeze

        STARTING_COMPANIES_OVERRIDE = {
          'M16' => { desc: 'A 50% director’s certificate in the associated minor company. Starting location is C17 (Seattle).' },

          'M17' => { desc: 'A 50% director’s certificate in the associated minor company. Starting location is K15 (Regina).' },

          'M18' => {
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is R16 (Thunder Bay).',
          },

          'M19' => { desc: 'A 50% director’s certificate in the associated minor company. Starting location is T12 (Moncton).' },

          'C2' => {
            desc: 'Has a face value of $100 and converts into the CPR’s 10% director certificate. CPR may also put '\
                  'its destination token into Vancouver when converted. Home: Montréal (T14). Destination: Vancouver (C15).',
          },
          'C8' => {
            desc: 'Has a face value of $100 and contributes $100 to conversion into the NTR director’s '\
                  'certificate. Home: Moncton (T12). Destination: SE Winnipeg (N16).',
          },
        }.freeze

        STARTING_CORPORATIONS_OVERRIDE = {
          '16' => { coordinates: 'C17', city: 0 },
          '17' => { coordinates: 'K15', city: 0 },
          '18' => { coordinates: 'R16', city: 0 },
          '19' => { coordinates: 'T12' },

          'CPR' => { coordinates: 'T14', city: 0 },
          'NTR' => { coordinates: 'T12' },
        }.freeze

        BIDDING_BOX_START_MINOR = nil

        MINOR_14_ID = nil
      end
    end
  end
end
