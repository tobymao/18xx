# frozen_string_literal: true

module Engine
  module Game
    module G1822MRS
      module Entities
        STARTING_COMPANIES = %w[P1 P2 P5 P6 P7 P8 P9 P10 P11 P12 P13 P14 P15 P16 P18
                                C1 C2 C3 C4 C6 C7 C9 M7 M8 M9 M10 M11 M12 M13 M14 M15
                                M16 16 M17 M18 M19 M20 M21 M24].freeze

        STARTING_COMPANIES_ADVANCED = %w[P1 P2 P3 P4 P5 P6 P7 P8 P9 P10 P11 P12
                                         C1 C2 C3 C4 C6 C7 C9 M7 M8 M9 M10 M11 M12 M13 M14 M15
                                         M16 16 M17 M18 M19 M20 M21 M24].freeze

        STARTING_COMPANIES_TWOPLAYER = %w[P1 P2 P3 P4 P5 P6 P7 P8 P9 P10 P11 P12
                                          C1 C2 C3 C4 C6 C7 C9 M7 M8 M9 M10 M11 M12 M13 M14 M15
                                          M16 16 M17 M18 M19 M20 M21 M24].freeze

        STARTING_CORPORATIONS = %w[7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 24
                                   LNWR GWR LBSCR SECR MR LYR SWR].freeze
      end
    end
  end
end
