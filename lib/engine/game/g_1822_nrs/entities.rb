# frozen_string_literal: true

module Engine
  module Game
    module G1822NRS
      module Entities
        STARTING_COMPANIES = %w[P1 P2 P3 P4 P6 P7 P8 P9 P11 P12 P13 P14 P15 P16 P18 P19 P20 P21
                                C1 C5 C6 C7 C8 C10 M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M15
                                M16 M26 M27 M28 M29].freeze

        STARTING_CORPORATIONS = %w[1 2 3 4 5 6 7 8 9 10 15 16 26 27 28 29
                                   LNWR CR MR LYR NBR NER].freeze

        STARTING_COMPANIES_OVERRIDE = {
          'M15' => { desc: 'A 50% director’s certificate in the associated minor company. Starting location is N29.' },
          'M16' => { desc: 'A 50% director’s certificate in the associated minor company. Starting location is M30.' },
          'M29' => { desc: 'A 50% director’s certificate in the associated minor company. Starting location is E26.' },
        }.freeze

        STARTING_CORPORATIONS_OVERRIDE = {
          '15' => { coordinates: 'N29', city: 1 },
          '16' => { coordinates: 'M30', city: 0 },
          '29' => { coordinates: 'E26' },
          'LNWR' => { coordinates: 'N29', city: 0 },
        }.freeze

        MINOR_14_ID = nil
      end
    end
  end
end
